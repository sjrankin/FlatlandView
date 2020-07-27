//
//  Imaging.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreImage

class Imaging
{
    /// Creates a new image with the given size and color. Intended to be used for imaging purposes, mainly
    /// as a tile base for NASA images.
    public static func InitializeImage(Width: Int, Height: Int, Background Color: NSColor = NSColor.black) -> NSImage
    {
        let NewImage = NSImage(size: NSSize(width: Width, height: Height))
        NewImage.lockFocus()
        Color.drawSwatch(in: NSRect(origin: .zero, size: NewImage.size))
        NewImage.unlockFocus()
        return NewImage
    }
    
    public static func PasteImage(Target: inout NSImage, Tile: NSImage, In Rectangle: NSRect)
    {
        Target.lockFocus()
        Tile.draw(in: Rectangle)
        Target.unlockFocus()
    }
}
