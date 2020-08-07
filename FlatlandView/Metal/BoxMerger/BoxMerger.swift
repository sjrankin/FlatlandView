//
//  BoxMerger.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd
import Metal
import MetalKit
import CoreImage

class BoxMerger
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
        {
            return self.ImageDevice?.makeCommandQueue()
        }()
    
    init()
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ImageMergeKernel2")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
    }
    
    func MergeImages(Background: NSImage, Sprite Color: NSColor, SpriteSize: NSSize,
                     SpriteX: Int, SpriteY: Int) -> NSImage
    {
        let SolidColor = SolidColorImage()
        let SpriteImage = SolidColor.Fill(Width: Int(SpriteSize.width), Height: Int(SpriteSize.height), With: Color)
        var Merged = MergeImages(Background: Background, Sprite: SpriteImage!,
                                 SpriteX: SpriteX, SpriteY: SpriteY)
        let Flipper = ImageFlipper()
        Merged = Flipper.FlipVertically(Source: Merged)!
        return Merged
    }
    
    func MergeImages(Background: NSImage, Sprite: NSImage, SpriteX: Int, SpriteY: Int) -> NSImage
    {
        var AdjustedBG: CGImage? = nil
        let BGTexture = MetalLibrary.MakeTexture(From: Background, ForWriting: true,
                                                 ImageDevice: ImageDevice!, AsCG: &AdjustedBG)
        var SpriteBG: CGImage? = nil
        let SPTexture = MetalLibrary.MakeTexture(From: Sprite, ForWriting: false,
                                                 ImageDevice: ImageDevice!, AsCG: &SpriteBG)
        let Parameter = ImageMergeParameters2(XOffset: simd_uint1(SpriteX),
                                              YOffset: simd_uint1(SpriteY))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<ImageMergeParameters2>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<ImageMergeParameters2>.stride)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(BGTexture, index: 0)
        CommandEncoder?.setTexture(SPTexture, index: 1)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let w = ImageComputePipelineState!.threadExecutionWidth
        let h = ImageComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadGroupCount = MTLSizeMake(w, h, 1)
        let ThreadGroups = MTLSize(width: BGTexture!.width, height: BGTexture!.height, depth: 1)
        
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
    
    func DrawBox(On Image: NSImage, X1: Int, Y1: Int, X2: Int, Y2: Int, With Color: NSColor) -> NSImage?
    {
        return DoDrawBox(On: Image, X1: X1, Y1: Y1, X2: X2, Y2: Y2, With: Color)
    }
    
    private func DoDrawBox(On Image: NSImage, X1: Int, Y1: Int, X2: Int, Y2: Int, With Color: NSColor) -> NSImage?
    {
        var AdjustedBG: CGImage? = nil
        let BGTexture = MetalLibrary.MakeTexture(From: Image, ForWriting: true,
                                                 ImageDevice: ImageDevice!, AsCG: &AdjustedBG)
        
        let FillColor = MetalLibrary.ToFloat4(Color)
        #if true
        let FinalX1 = X1
        let FinalY1 = Y1
        let FinalX2 = X2
        let FinalY2 = Y2
        #else
        var FinalY1 = Int(Image.size.height) - Y1
        var FinalY2 = Int(Image.size.height) - Y2
        if FinalY1 > FinalY2
        {
            swap(&FinalY1, &FinalY2)
        }
        var FinalX1 = X1
        var FinalX2 = X2
        if FinalX1 > FinalX2
        {
            swap(&FinalX1, &FinalX2)
        }
        #endif
 
        print("FinalX1=\(FinalX1), FinalX2=\(FinalX2)")
        let Parameter = BoxMergeParameters(FillColor: FillColor,
                                           X1: simd_uint1(FinalX1),
                                           Y1: simd_uint1(FinalY1),
                                           X2: simd_uint1(FinalX2),
                                           Y2: simd_uint1(FinalY2))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<BoxMergeParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<BoxMergeParameters>.stride)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(BGTexture, index: 0)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let w = ImageComputePipelineState!.threadExecutionWidth
        let h = ImageComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadGroupCount = MTLSizeMake(w, h, 1)
        let ThreadGroups = MTLSize(width: BGTexture!.width, height: BGTexture!.height, depth: 1)
        
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

