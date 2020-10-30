//
//  MTLTexture.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import Metal
import MetalKit

extension MTLTexture
{
    // MARK: - MTLTexture extensions
    
    /// Returns the instance texture as an image.
    /// - Returns: Texture as an `NSImage` on success, nil on error.
    public func GetImage() -> NSImage?
    {
        let Width = self.width
        let Height = self.height
        let BytesPerRow = Width * 4
        let ImageByteCount = Width * Height * 4
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let TextureRegion = MTLRegionMake2D(0, 0, Int(Width), Int(Height))
        self.getBytes(&ImageBytes,
                      bytesPerRow: BytesPerRow,
                      from: TextureRegion,
                      mipmapLevel: 0)
        
        let CIOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                         CIImageOption.applyOrientationProperty: false,
                         CIContextOption.outputPremultiplied: true,
                         CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImg = CIImage(mtlTexture: self, options: CIOptions)
        let CImgRep = NSCIImageRep(ciImage: CImg!)
        let Final = NSImage(size: NSSize(width: Width, height: Height))
        Final.addRepresentation(CImgRep)
        return Final
    }
}
