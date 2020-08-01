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
    
    /// Add grid lines to the map if the proper settings are true.
    /// - Parameter To: The map to add grid lines.
    /// - Returns: The map with grid lines or the same image, depending on settings.
    func AddGridLines(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
         return Image
        }
        else
        {
            return Image
        }
    }
    
    /// Add earthquake regions to the map if the proper settings are true.
    /// - Parameter To: The map to add earthquake regions.
    /// - Returns: The map with earthquake regions or the same image, depending on settings.
    func AddRegions(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.DrawEarthquakeRegions)
        {
            let Drawer = BoxDrawer()
            let RegionList = Settings.GetEarthquakeRegions()
            return DrawRegions(Image: Image, Regions: RegionList, Kernel: Drawer)
        }
        else
        {
            return Image
        }
    }
    
    /// Add city names to the map if the proper settings are true.
    /// - Parameter To: The map to add city names.
    /// - Returns: The map with city names or the same image, depending on settings.
    func AddCityNames(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.CityNamesDrawnOnMap)
        {
            return Image
        }
        else
        {
            return Image
        }
    }
    
    /// Add earthquake magnitude values to the map if the proper settings are true.
    /// - Parameter To: The map to add earthquake magnitude values.
    /// - Returns: The map with earthquake magnitude values or the same image, depending on settings.
    func AddMagnitudeValues(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
        {
            return Image
        }
        else
        {
            return Image
        }
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
    
    /// Draw a region with a color rectangle on the passed image.
    /// - Parameter Image: The image where regions will be drawn.
    /// - Parameter Regions: Array of regions to draw.
    /// - Parameter Kernel: The Metal kernel to use to draw the regions.
    /// - Returns: Image with regions drawn on it.
    func DrawRegions(Image: NSImage, Regions: [EarthquakeRegion], Kernel: BoxDrawer) -> NSImage
    {
        let BorderColor = Settings.GetColor(.EarthquakeRegionBorderColor)!
        let BorderWidth = Settings.GetDouble(.EarthquakeRegionBorderWidth)
        var Final = Image
        for Region in Regions
        {
            let UL = Region.UpperLeft.ToEquirectangular(Width: Int(Image.size.width), Height: Int(Image.size.height))
            let LR = Region.LowerRight.ToEquirectangular(Width: Int(Image.size.width), Height: Int(Image.size.height))
            let RegionWidth = LR.X - UL.X
            let RegionHeight = LR.Y - UL.Y
            
            let TopX1 = Int(UL.X)
            let TopY1 = Int(UL.Y)
            Final = Kernel.DrawBox(On: Final, X: TopX1, Y: TopY1,
                                   Width: RegionWidth, Height: Int(BorderWidth),
                                   With: BorderColor)!
            
            let BottomX1 = Int(UL.X)
            let BottomY1 = Int(UL.Y + RegionHeight - Int(BorderWidth))
            Final = Kernel.DrawBox(On: Final, X: BottomX1, Y: BottomY1,
                                   Width: RegionWidth, Height: Int(BorderWidth),
                                   With: BorderColor)!
            
            let LeftX1 = Int(UL.X)
            let LeftY1 = Int(UL.Y + Int(BorderWidth) - 2)
            Final = Kernel.DrawBox(On: Final, X: LeftX1, Y: LeftY1,
                                   Width: Int(BorderWidth), Height: (RegionHeight - Int(BorderWidth) * 2 + 1),
                                   With: BorderColor)!
            
            let RightX1 = Int(UL.X + RegionWidth - Int(BorderWidth))
            let RightY1 = Int(UL.Y + Int(BorderWidth) - 3)
            Final = Kernel.DrawBox(On: Final, X: RightX1, Y: RightY1,
                                   Width: Int(BorderWidth), Height: (RegionHeight - Int(BorderWidth) * 2 + 2),
                                   With: BorderColor)!
        }
        return Final
    }
}
