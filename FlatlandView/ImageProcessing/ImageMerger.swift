//
//  ImageMerger.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageMerger
{
    public static func MergeImages(Background: NSImage, Sprite: NSImage, At Point: CGPoint) -> NSImage
    {
        let Target = NSImage(size: Background.size)
        Target.lockFocus()
        var TargetRect: CGRect = .zero
        TargetRect.size = Target.size
        Background.draw(in: TargetRect)
        var SpriteRect: CGRect = .zero
        SpriteRect.size = Sprite.size
        SpriteRect.origin = Point
        Sprite.draw(in: TargetRect)
        Target.unlockFocus()
        return Target
    }
}
