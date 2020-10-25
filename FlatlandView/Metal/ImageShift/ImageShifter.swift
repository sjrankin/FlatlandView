//
//  ImageShifter.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd
import Metal
import MetalKit
import CoreImage

class ImageShifter
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
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ImageShift")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
    }
    
    func ShiftImage(Source: NSImage, Horizontally: Int = 0, Vertically: Int = 0) -> NSImage
    {
        let Parameter = ImageShiftParameters(XOffset: simd_uint1(Horizontally),
                                             YOffset: simd_uint1(Vertically))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<SolidColorParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<SolidColorParameters>.stride)
        
        let Target = MetalLibrary.MakeEmptyTexture(Size: Source.size, ImageDevice: ImageDevice!,
                                                   ForWriting: true)
        var AdjustedCG: CGImage? = nil
        let AdjustedSource = MetalLibrary.MakeTexture(From: Source, ForWriting: false, ImageDevice: ImageDevice!,
                                                      AsCG: &AdjustedCG)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(AdjustedSource, index: 0)
        CommandEncoder?.setTexture(Target, index: 1)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let ThreadGroupCount = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(AdjustedSource!.width / ThreadGroupCount.width,
                                       AdjustedSource!.height / ThreadGroupCount.height,
                                       1)
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        let ImageSize = CGSize(width: Target!.width, height: Target!.height)
        let ImageByteCount = Int(ImageSize.width * ImageSize.height * 4)
        let BytesPerRow = (AdjustedCG?.bytesPerRow)!
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, Int(ImageSize.width), Int(ImageSize.height))
        Target!.getBytes(&ImageBytes, bytesPerRow: BytesPerRow, from: ORegion, mipmapLevel: 0)
        
        let CIOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                         CIImageOption.applyOrientationProperty: false,
                         CIContextOption.outputPremultiplied: true,
                         CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImg = CIImage(mtlTexture: Target!, options: CIOptions)
        let CImgRep = NSCIImageRep(ciImage: CImg!)
        let Final = NSImage(size: ImageSize)
        Final.addRepresentation(CImgRep)
        return Final
    }
}
