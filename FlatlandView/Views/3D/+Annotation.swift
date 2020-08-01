//
//  +Annotation.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Code to annotate 3D globe images.
extension GlobeView
{
    /// Draw annotations on the passed image.
    /// - Parameters To: The image to draw on.
    /// - Returns: Image with annotations drawn.
    func AddAnnotation(To Image: NSImage) -> NSImage
    {
        let GridAnnotation = AddGridLines(To: Image)
        let RegionAnnotation = AddRegions(To: GridAnnotation)
        let NameAnnotation = AddCityNames(To: RegionAnnotation)
        let MagnitudeAnnotation = AddMagnitudeValues(To: NameAnnotation)
        return MagnitudeAnnotation
    }
    
    func AddGridLines(To Image: NSImage) -> NSImage
    {
        return NSImage()
    }
    
    func AddRegions(To Image: NSImage) -> NSImage
    {
        return NSImage()
    }
    
    func AddCityNames(To Image: NSImage) -> NSImage
    {
        return NSImage()
    }
    
    func AddMagnitudeValues(To Image: NSImage) -> NSImage
    {
        return NSImage()
    }
    
    /// Draw text on the passed image.
    /// - Parameter Image: The source image to draw on.
    /// - Parameter Text: The string to draw.
    /// - Parameter Font: The font to use to draw the text.
    /// - Parameter Color: The color of the text to draw.
    /// - Parameter Location: The location where to draw the text.
    /// - Returns: Image with the text drawn on it.
    func DrawOn(Image: NSImage, Text: String, Font: NSFont, Color: NSColor, Location: NSPoint) -> NSImage
    {
        Image.lockFocus()
        var Attrs = [NSAttributedString.Key: Any]()
        Attrs[NSAttributedString.Key.font] = Font as Any
        Attrs[NSAttributedString.Key.foregroundColor] = Color as Any
        let AttrString = NSAttributedString(string: Text, attributes: Attrs)
        AttrString.draw(at: Location)
        Image.unlockFocus()
        return Image
    }
    
    /// Draw a set of strings on the passed image.
    /// - Parameter Image: The sourse image where to draw the text.
    /// - Parameter Messages: Array of tuples of strings and their location where to draw.
    /// - Parameter Font: The font to use to draw the text.
    /// - Parameter Color: The color of the text to draw.
    /// - Returns: Image with the text drawn on it.
    func DrawOn(Image: NSImage, Messages: [(String, NSPoint)], Font: NSFont, Color: NSColor) -> NSImage
    {
        Image.lockFocus()
        for (Text, Location) in Messages
        {
            var Attrs = [NSAttributedString.Key: Any]()
            Attrs[NSAttributedString.Key.font] = Font as Any
            Attrs[NSAttributedString.Key.foregroundColor] = Color as Any
            let AttrString = NSAttributedString(string: Text, attributes: Attrs)
            AttrString.draw(at: Location)
        }
        Image.unlockFocus()
        return Image
    }
}
