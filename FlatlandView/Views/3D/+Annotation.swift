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
    /// Add annotations to the image (which is presumed to be a map texture for the sphere for the Earth
    /// in 3D mode).
    /// - Note:
    ///   - Various annotations on the map occur based on user settings. It is entirely possible that the user
    ///     has disabled all annotations and this function will return the original image unchanged (but slowly,
    ///     since some overhead will always occur).
    ///   - In order to process the image efficiently, the image representation data is first extracted and used
    ///     in all text-related functions. That way, the relatively slow image data extraction (which occurs even
    ///     if you use the normal .draw functions - it's just hidden) happens only once. Additionally, boxes and
    ///     lines are drawn on the image using Metal kernels written for this purpose.
    /// - Parameter To: The Earth map texture.
    /// - Parameter With: Array of earthquakes to plot.
    /// - Returns: Annotated map image.
    func AddAnnotation(To Image: NSImage, With Earthquakes: [Earthquake]) -> NSImage
    {
        var Working = Image
        let Regions = Settings.GetEarthquakeRegions()
        if Regions.count > 0
        {
            let Blender = ImageBlender()
            Working = DrawRegions(Image: Image, Regions: Regions, Kernel: Blender)
        }
        var Rep = GetImageRep(From: Working)
        if Settings.GetBool(.CityNamesDrawnOnMap)
        {
            Rep = AddCityNames(To: Rep)
        }
        if Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No) == .Stenciled
        {
            Rep = AddMagnitudeValues(To: Rep, With: Earthquakes)
        }
        let Final = GetImage(From: Rep)
        return Final
    }
    
    /// Add annotations to the image (which is presumed to be a map texture for the sphere for the Earth
    /// in 3D mode).
    /// - Note:
    ///   - Various annotations on the map occur based on user settings. It is entirely possible that the user
    ///     has disabled all annotations and this function will return the original image unchanged (but slowly,
    ///     since some overhead will always occur).
    ///   - In order to process the image efficiently, the image representation data is first extracted and used
    ///     in all text-related functions. That way, the relatively slow image data extraction (which occurs even
    ///     if you use the normal .draw functions - it's just hidden) happens only once. Additionally, boxes and
    ///     lines are drawn on the image using Metal kernels written for this purpose.
    /// - Parameter To: The Earth map texture.
    /// - Parameter With: Array of earthquakes to plot.
    /// - Parameter Completed: Closure called upon completion. The final image is passed to the closure. The
    ///                        closure is run on the main thread.
    func AddAnnotation(To Image: NSImage, With Quakes: [Earthquake], Completed: ((NSImage) -> ())? = nil)
    {
        DispatchQueue.main.async
        {
            var Rep = self.GetImageRep(From: Image)
            if Settings.GetBool(.CityNamesDrawnOnMap)
            {
                Rep = self.AddCityNames(To: Rep)
            }
            if Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No) == .Stenciled
            {
                Rep = self.AddMagnitudeValues(To: Rep, With: Quakes)
            }
            let Final = self.GetImage(From: Rep)
            OperationQueue.main.addOperation
            {
                Completed?(Final)
            }
        }
    }
    
    /// Add city names to the passed image representation.
    /// - Parameter To: The image representation where city names will be added.
    /// - Returns: Image representation with city names.
    func AddCityNames(To: NSBitmapImageRep) -> NSBitmapImageRep
    {
        var Working = To
        let CityList = Cities()
        CitiesToPlot = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        var PlotMe = [TextRecord]()
        let CityFont = NSFont.boldSystemFont(ofSize: 24.0)
        for City in CitiesToPlot
        {
            let CityPoint = GeoPoint2(City.Latitude, City.Longitude)
            let CityPointLocation = CityPoint.ToEquirectangular(Width: Int(To.size.width),
                                                                Height: Int(To.size.height))
            let Location = NSPoint(x: CityPointLocation.X + 15, y: CityPointLocation.Y)
            let CityColor = Cities.ColorForCity(City)
            let Record = TextRecord(Text: City.Name, Location: Location, Font: CityFont, Color: CityColor,
                                    OutlineColor: NSColor.black)
            PlotMe.append(Record)
        }
        
        Working = DrawOn(Rep: Working, Messages: PlotMe)
        return Working
    }
    
    /// Add earthquake magnitude values to the map if the proper settings are true.
    /// - Parameter To: The map to add earthquake magnitude values.
    /// - Returns: The map with earthquake magnitude values or the same image, depending on settings.
    func AddMagnitudeValues(To Image: NSBitmapImageRep, With Earthquakes: [Earthquake]) -> NSBitmapImageRep
    {
        var PlotMe = [TextRecord]()
        var Working = Image
        for Quake in Earthquakes
        {
            let Location = Quake.LocationAsGeoPoint2().ToEquirectangular(Width: Int(Image.size.width),
                                                                         Height: Int(Image.size.height))
            let LocationPoint = NSPoint(x: Location.X, y: Location.Y)
            let EqText = "\(Quake.Magnitude.RoundedTo(3))"
            let QuakeFont = NSFont.boldSystemFont(ofSize: CGFloat(36.0 + Quake.Magnitude))
            let MagRange = GetMagnitudeRange(For: Quake.Magnitude)
            var BaseColor = NSColor.systemYellow
            let Colors = Settings.GetMagnitudeColors()
            for (Magnitude, Color) in Colors
            {
                if Magnitude == MagRange
                {
                    BaseColor = Color
                }
            }
            let Record = TextRecord(Text: EqText, Location: LocationPoint,
                                    Font: QuakeFont, Color: BaseColor, OutlineColor: NSColor.black)
            PlotMe.append(Record)
        }
        Working = DrawOn(Rep: Working, Messages: PlotMe)
        return Working
    }
    
    /// Return an image representation from the passed `NSImage`.
    /// - Returns: Image representation from `From`.
    func GetImageRep(From: NSImage) -> NSBitmapImageRep
    {
        let ImgData = From.tiffRepresentation
        let CImg = CIImage(data: ImgData!)
        return NSBitmapImageRep(ciImage: CImg!)
    }
    
    /// Convert the passed image representation into an `NSImage`.
    /// - Returns: `NSImage` created from the passed image representation.
    func GetImage(From: NSBitmapImageRep) -> NSImage
    {
        let Final = NSImage(size: From.size)
        Final.addRepresentation(From)
        return Final
    }
    
    /// Draw a set of strings on the passed image.
    /// - Parameter Image: The sourse image where to draw the text.
    /// - Parameter Messages: Array of tuples of strings and their location where to draw.
    /// - Parameter Font: The font to use to draw the text.
    /// - Parameter Color: The color of the text to draw.
    /// - Returns: Image with the text drawn on it.
    func DrawOn(Rep: NSBitmapImageRep, Messages: [TextRecord]) -> NSBitmapImageRep
    {
        guard let Context = NSGraphicsContext(bitmapImageRep: Rep) else
        {
            fatalError("Error returned from NSGraphicsContext")
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = Context
        for Message in Messages
        {
            autoreleasepool
            {
                var Attrs = [NSAttributedString.Key: Any]()
                Attrs[NSAttributedString.Key.font] = Message.Font as Any
                Attrs[NSAttributedString.Key.foregroundColor] = Message.Color as Any
                if let Outline = Message.OutlineColor
                {
                    Attrs[NSAttributedString.Key.strokeColor] = Outline as Any
                    Attrs[NSAttributedString.Key.strokeWidth] = -2.0 as Any
                }
                let AttrString = NSAttributedString(string: Message.Text, attributes: Attrs)
                let FinalLocation = NSPoint(x: Message.Location.x, y: Message.Location.y - (AttrString.size().height / 2.0))
                AttrString.draw(at: FinalLocation)
            }
        }
        NSGraphicsContext.restoreGraphicsState()
        return Rep
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
            #if true
            let Blender = ImageBlender()
            let RegionList = Settings.GetEarthquakeRegions()
            return DrawRegions(Image: Image, Regions: RegionList, Kernel: Blender)
            #else
            let Merger = BoxMerger()
            let RegionList = Settings.GetEarthquakeRegions()
            return DrawRegions(Image: Image, Regions: RegionList, Kernel: Merger)
            #endif
        }
        else
        {
            return Image
        }
    }
    
    func DrawRegions(Image: NSImage, Regions: [EarthquakeRegion], Kernel: ImageBlender) -> NSImage
    {
        var Final = Image
        for Region in Regions
        {
            if Region.IsFallback
            {
                continue
            }
            let UL = Region.UpperLeft.ToEquirectangular(Width: Int(Image.size.width),
                                                        Height: Int(Image.size.height))
            let ImageWidth = Int(Image.size.width)
            let ImageHeight = Int(Image.size.height)
            let RegionWidth = GeoPoint2.HorizontalDistance(Longitude1: Region.UpperLeft.Longitude,
                                                           Longitude2: Region.LowerRight.Longitude,
                                                           Latitude: Region.UpperLeft.Latitude,
                                                           Width: ImageWidth, Height: ImageHeight)
            let RegionHeight = GeoPoint2.VerticalDistance(Latitude1: Region.UpperLeft.Latitude,
                                                          Latitude2: Region.LowerRight.Latitude,
                                                          Longitude: Region.UpperLeft.Longitude,
                                                          Width: ImageWidth, Height: ImageHeight)
            var XPercent: Double = 0.0
            var YPercent: Double = 0.0
            let (FinalX, FinalY) = GeoPoint2.TransformToImageCoordinates(Latitude: Region.UpperLeft.Latitude,
                                                                         Longitude: Region.UpperLeft.Longitude,
                                                                         Width: ImageWidth,
                                                                         Height: ImageHeight,
                                                                         XPercent: &XPercent,
                                                                         YPercent: &YPercent)
            Final = Kernel.MergeImages(Background: Final, Sprite: Region.BorderColor.withAlphaComponent(0.5),
                               SpriteSize: NSSize(width: RegionWidth, height: RegionHeight),
                               SpriteX: FinalX, SpriteY: FinalY)
        }
        return Final
    }
}

/// Used to send information to the text plotter for drawing text on images.
struct TextRecord
{
    /// The text to draw.
    let Text: String
    /// The location of the text to draw.
    let Location: NSPoint
    /// The font to use to draw the text.
    let Font: NSFont
    /// The color of the text.
    let Color: NSColor
    /// If present, the outline color of the text. If not present, no outline is drawn.
    let OutlineColor: NSColor?
}
