//
//  ImageBlender.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd
import Metal
import MetalKit
import CoreImage

/// Wrapper class around the `ImageBlender` metal kernel to merge two images together.
class ImageBlender
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
        {
            return self.ImageDevice?.makeCommandQueue()
        }()
    
    /// Initializer.
    init()
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ImageBlender")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
    }
    
    /// Merge the background image with a color sprite block generated in this function.
    /// - Warning: The the generated color sprite block has any part that falls outside of the bounds of the
    ///            `Background` image, a fatal error will be generated.
    /// - Note: Pixel blending follows these rules.
    ///   1. If the sprite pixel has an alpha value of 1.0, it overwrites the background pixel
    ///                       in the same location.
    ///   2. If the sprite pixel has an alpha value of 0.0, no action is taken (eg, the background remains
    ///      unchanged).
    ///   3. If the sprite pixel has an alpha value greater than 0.0 and less than 1.0, standard
    ///                       alpha pixel blending takes place.
    ///   4. If the background pixel has an alpha of 0.0, the sprite pixel is unconditionally placed on the
    ///      background pixel.
    /// - Parameter Background: The background image over which a colored, rectangular sprite will be blended.
    /// - Parameter Sprite: The color of the rectangle that will be merged with the background. The blending
    ///                     of the sprite with the background depends on the alpha level of the sprite pixel.
    /// - Parameter SpriteSize: The size of the color sprite rectangle. If the size falls outside the area of
    ///                         the image, a fatal error will be generated.
    /// - Parameter SpriteX: The horiztonal coordinate of the upper-left corner of the sprite.
    /// - Parameter SpriteY: The vertical coordinate of the upper-left corner of the sprite.
    /// - Returns: The `Background` image with the color rectangle sprite merged onto it, blended as per
    ///            alpha level rules.
    func MergeImages(Background: NSImage, Sprite Color: NSColor, SpriteSize: NSSize,
                     SpriteX: Int, SpriteY: Int) -> NSImage
    {
        if SpriteX + Int(SpriteSize.width) > Int(Background.size.width)
        {
            fatalError("Sprite will extend past the horizontal bounds of the background image.")
        }
        if SpriteY + Int(SpriteSize.height) > Int(Background.size.height)
        {
            fatalError("Sprite will extend past the vertical bounds of the background image.")
        }
        let SolidColor = SolidColorImage()
        let SpriteImage = SolidColor.Fill(Width: Int(SpriteSize.width), Height: Int(SpriteSize.height), With: Color)
        var Merged = DoMergeImages(Background: Background, Sprite: SpriteImage!,
                                   SpriteX: SpriteX, SpriteY: SpriteY)
        let Flipper = ImageFlipper()
        Merged = Flipper.FlipVertically(Source: Merged)!
        return Merged
    }
    
    /// Merge the background image with the passed sprite image. This function takes no account of the content
    /// of the sprite image.
    /// - Warning: The the sprite image has any part that falls outside of the bounds of the `Background`
    ///            image, a fatal error will be generated.
    /// - Note: Pixel blending follows these rules.
    ///   1. If the sprite pixel has an alpha value of 1.0, it overwrites the background pixel
    ///                       in the same location.
    ///   2. If the sprite pixel has an alpha value of 0.0, no action is taken - the background remains
    ///      unchanged.
    ///   3. If the sprite pixel has an alpha value greater than 0.0 and less than 1.0, standard
    ///                       alpha pixel blending takes place.
    ///   4. If the background pixel has an alpha of 0.0, the sprite pixel is unconditionally placed on the
    ///      background pixel.
    /// - Parameter Background: The background image over which sprite will be blended.
    /// - Parameter Sprite: The color of the rectangle that will be merged with the background. The blending
    ///                     of the sprite with the background depends on the alpha level of the sprite pixel.
    /// - Parameter SpriteX: The horiztonal coordinate of the upper-left corner of the sprite.
    /// - Parameter SpriteY: The vertical coordinate of the upper-left corner of the sprite.
    /// - Returns: The `Background` image with the sprite image merged onto it, blended as per
    ///            alpha level rules.
    func MergeImages(Background: NSImage, Sprite: NSImage, SpriteX: Int, SpriteY: Int) -> NSImage
    {
        if SpriteX + Int(Sprite.size.width) > Int(Background.size.width)
        {
            fatalError("Sprite will extend past the horizontal bounds of the background image.")
        }
        if SpriteY + Int(Sprite.size.height) > Int(Background.size.height)
        {
            fatalError("Sprite will extend past the vertical bounds of the background image.")
        }
        var Merged = DoMergeImages(Background: Background, Sprite: Sprite, SpriteX: SpriteX, SpriteY: SpriteY)
        let Flipper = ImageFlipper()
        Merged = Flipper.FlipVertically(Source: Merged)!
        return Merged
    }
    
    /// Set up and run the kernel to merge a sprite image with the background image.
    /// - Parameter Background: The background image upon which the `Sprite` image will be drawn (with appropriate
    ///                         alpha blending).
    /// - Parameter Sprite: The (presumably) smaller image to merge with the `Background` image.
    /// - Parameter SpriteX: The horizontal coordinate of the upper-left corner of `Sprite`.
    /// - Parameter SpriteY: The vertical coordinate of the upper-left corner of `Sprite`.
    /// - Returns: New image with `Sprite` merged with `Background`.
    private func DoMergeImages(Background: NSImage, Sprite: NSImage, SpriteX: Int, SpriteY: Int) -> NSImage
    {
        var AdjustedBG: CGImage? = nil
        let BGTexture = MetalLibrary.MakeTexture(From: Background, ForWriting: true,
                                                 ImageDevice: ImageDevice!, AsCG: &AdjustedBG)
        var SpriteBG: CGImage? = nil
        let SPTexture = MetalLibrary.MakeTexture(From: Sprite, ForWriting: true,
                                                 ImageDevice: ImageDevice!, AsCG: &SpriteBG)
        let Parameter = ImageBlendParameters(XOffset: simd_uint1(SpriteX),
                                              YOffset: simd_uint1(SpriteY))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<ImageBlendParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<ImageBlendParameters>.stride)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(SPTexture, index: 0)
        CommandEncoder?.setTexture(BGTexture, index: 1)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let w = ImageComputePipelineState!.threadExecutionWidth
        let h = ImageComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadGroupCount = MTLSizeMake(w, h, 1)
        let ThreadGroups = MTLSize(width: SPTexture!.width, height: SPTexture!.height, depth: 1)
        
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        let ImageSize = CGSize(width: BGTexture!.width, height: BGTexture!.height)
        let ImageByteCount = Int(BGTexture!.width * BGTexture!.height * 4)
        let BytesPerRow = AdjustedBG!.bytesPerRow
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, BGTexture!.width, BGTexture!.height)
        BGTexture!.getBytes(&ImageBytes, bytesPerRow: BytesPerRow, from: ORegion, mipmapLevel: 0)
        
        //https://stackoverflow.com/questions/49713008/pixel-colors-change-as-i-save-mtltexture-to-cgimage
        let CIOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                         CIContextOption.outputPremultiplied: true,
                         CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImg = CIImage(mtlTexture: BGTexture!, options: CIOptions)
        let CImgRep = NSCIImageRep(ciImage: CImg!)
        let Final = NSImage(size: ImageSize)
        Final.addRepresentation(CImgRep)
        return Final
    }
}

