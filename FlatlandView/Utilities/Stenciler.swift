//
//  Stenciler.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd

/// Class that stencils text and shapes onto images.
class Stenciler
{
    /// Provides a lock from too many callers at once.
    private static let StencilLock = NSObject()
    
    /// Add stencils to the passed image.
    /// - Notes:
    ///   1. Most of the drawing is done in a background thread. Control is returned to the caller almost
    ///      immediately.
    ///   2. This function controls access such that only one caller at a time can execute this function.
    ///   3. The order of drawing of stencils is:
    ///      - Earthquake regions.
    ///      - Grid lines.
    ///      - City names.
    ///      - Earthquake magnitude values.
    /// - Parameter To: The base image upon which stencils will be added.
    /// - Parameter Quakes: List of earthquakes whose magnitudes will be plotted. If this parameter is nil,
    ///                     no magnitudes will be plotted. Defaults to `nil`.
    /// - Parameter ShowRegions: Determines if earthquake regions are shown or not drawn. Defaults to `false`.
    ///                          If true is passed, the regions in user settings are used.
    /// - Parameter PlotCities: Determines if city names are drawn or not drawn. Defaults to `false`. If true
    ///                         is passed, city names in the global city name database are used.
    /// - Parameter GridLines: Determines if grid lines are drawn or not drawn. Defaults to `false`. If true,
    ///                        which lines are drawn depend on user settings.
    /// - Parameter CalledBy: The name of the caller.
    /// - Parameter Status: Closure for handling status updates for drawing stencils. First parameter is a string
    ///                     describing the status and the second parameter is the number of seconds since the
    ///                     function was called.
    /// - Parameter Completed: Closure to accept the resultant image (`NSImage`) after all stencils have been
    ///                        drawn. If no stencils have been drawn (due to the values of parameters), the
    ///                        original image, unchanged, will be passed to this closure. The second parameter
    ///                        passed to the closure is the duration of execution for this function, in seconds.
    ///                        The third parameter is the name of the caller, passed directly and unchanged.
    ///                        The closure may be called from a background thread or the UI thread.
    public static func AddStencils(To Image: NSImage,
                                   Quakes: [Earthquake]? = nil,
                                   ShowRegions: Bool = false,
                                   PlotCities: Bool = false,
                                   GridLines: Bool = false,
                                   CalledBy: String? = nil,
                                   Status: ((String, Double) -> ())? = nil,
                                   Completed: ((NSImage, Double, String?) -> ())? = nil)
    {
        objc_sync_enter(StencilLock)
        defer{objc_sync_exit(StencilLock)}
        let StartTime = CACurrentMediaTime()
        if Quakes == nil && !ShowRegions && !PlotCities && !GridLines
        {
            //Nothing to do - return the image unaltered.
            Completed?(Image, 0.0, CalledBy)
            return
        }
        let LocalQuakes = Quakes
        DispatchQueue.global(qos: .background).async
        {
            var Working = Image
            Status?("Creating regions", CACurrentMediaTime() - StartTime)
            if ShowRegions
            {
                let Regions = Settings.GetEarthquakeRegions()
                if Regions.count > 0
                {
                    let Blender = ImageBlender()
                    Working = DrawRegions(Image: Working, Regions: Regions, Kernel: Blender)
                }
            }
            Status?("Adding grid lines", CACurrentMediaTime() - StartTime)
            if GridLines
            {
                Working = AddGridLines2(To: Working)
            }

            var Rep = GetImageRep(From: Working)
            Status?("Plotting cities", CACurrentMediaTime() - StartTime)
            if PlotCities
            {
                Rep = AddCityNames(To: Rep)
            }
            Status?("Plotting earthquakes", CACurrentMediaTime() - StartTime)
            if let QuakeList = LocalQuakes
            {
                Rep = AddMagnitudeValues(To: Rep, With: QuakeList)
            }
            let Final = GetImage(From: Rep)
            let Duration = CACurrentMediaTime() - StartTime
            Status?("Finished", CACurrentMediaTime() - StartTime)
            Completed?(Final, Duration, CalledBy)
        }
    }
    
    /// Add city names to the passed image representation.
    /// - Parameter To: The image representation where city names will be added.
    /// - Returns: Image representation with city names.
    private static func AddCityNames(To: NSBitmapImageRep) -> NSBitmapImageRep
    {
        var Working = To
        let CityList = Cities()
        let CitiesToPlot = CityList.TopNCities(N: 50, UseMetroPopulation: true)
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
    private static func AddMagnitudeValues(To Image: NSBitmapImageRep, With Earthquakes: [Earthquake]) -> NSBitmapImageRep
    {
        if Earthquakes.count < 1
        {
            return Image
        }
        var PlotMe = [TextRecord]()
        var Working = Image
        for Quake in Earthquakes
        {
            let Location = Quake.LocationAsGeoPoint2().ToEquirectangular(Width: Int(Image.size.width),
                                                                         Height: Int(Image.size.height))
            let LocationPoint = NSPoint(x: Location.X, y: Location.Y)
            let EqText = "\(Quake.Magnitude.RoundedTo(3))"
            let QuakeFont = NSFont.boldSystemFont(ofSize: CGFloat(36.0 + Quake.Magnitude))
            let MagRange = Utility.GetMagnitudeRange(For: Quake.Magnitude)
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
    
    /// Draw a set of strings on the passed image.
    /// - Parameter Image: The sourse image where to draw the text.
    /// - Parameter Messages: Array of tuples of strings and their location where to draw.
    /// - Parameter Font: The font to use to draw the text.
    /// - Parameter Color: The color of the text to draw.
    /// - Returns: Image with the text drawn on it.
    private static func DrawOn(Rep: NSBitmapImageRep, Messages: [TextRecord]) -> NSBitmapImageRep
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
    
    typealias LineDefinition = (IsHorizontal: Bool, At: Int, Thickness: Int, Color: NSColor)
    
    /// Add grid lines to the passed image.
    /// - Parameter To: The image to which to add gridlines.
    /// - Return: New image with grid lines drawn.
    private static func AddGridLines2(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
            //let Kernel = LineDraw()
            let ImageWidth = Int(Image.size.width)
            let ImageHeight = Int(Image.size.height)
            var LineList = [LineDefinition]()
            let LineColor = Settings.GetColor(.GridLineColor, NSColor.red)
            let MinorLineColor = Settings.GetColor(.MinorGridLineColor, NSColor.yellow)
            
            if Settings.GetBool(.Show3DMinorGrid)
            {
                let Gap = Settings.GetDouble(.MinorGrid3DGap, 15.0)
                for Longitude in stride(from: 0.0, to: 180.0, by: Gap)
                {
                    var Y = Int(Double(ImageHeight) * (Longitude / 180.0))
                    if Y + 4 > ImageHeight
                    {
                        Y = Y - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: true,
                                                At: Y,
                                                Thickness: 4,
                                                Color: MinorLineColor)
                    LineList.append(Line)
                }
                for Latitude in stride(from: 0.0, to: 360.0, by: Gap)
                {
                    var X = Int(Double(ImageWidth) * (Latitude / 360.0))
                    if X + 4 > ImageWidth
                    {
                        X = X - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: false,
                                                At: X,
                                                Thickness: 4,
                                                Color: MinorLineColor)
                    LineList.append(Line)
                }
            }
            
            for Longitude in Longitudes.allCases
            {
                if Settings.DrawLongitudeLine(Longitude)
                {
                    var Y = Int(Double(ImageHeight) * Longitude.rawValue)
                    if Y + 4 > ImageHeight
                    {
                        Y = Y - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: true,
                                                At: Y,
                                                Thickness: 4,
                                                Color: LineColor)
                    LineList.append(Line)
                }
            }
            for Latitude in Latitudes.allCases
            {
                if Settings.DrawLatitudeLine(Latitude)
                {
                    var X = Int(Double(ImageWidth) * Latitude.rawValue)
                    if X + 4 > ImageWidth
                    {
                        X = X - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: false,
                                                At: X,
                                                Thickness: 4,
                                                Color: LineColor)
                    LineList.append(Line)
                }
            }

            let Final = Image
            Final.lockFocus()
            for Line in LineList
            {
                var X = 0
                var Y = 0
                var LineWidth = 0
                var LineHeight = 0
                if Line.IsHorizontal
                {
                    Y = Line.At
                    LineWidth = Int(Image.size.width)
                    LineHeight = Line.Thickness
                }
                else
                {
                    X = Line.At
                    LineWidth = Line.Thickness
                    LineHeight = Int(Image.size.height)
                }
                let LineRect = NSRect(origin: CGPoint(x: X, y: Y), size: NSSize(width: LineWidth, height: LineHeight))
                let Path = NSBezierPath(rect: LineRect)
                Line.Color.setFill()
                Line.Color.setStroke()
                Path.stroke()
                Path.fill()
            }
            Final.unlockFocus()
            return Final
        }
        else
        {
            return Image
        }
    }
    
    /// Add grid lines to the passed image.
    /// - Parameter To: The image to which to add gridlines.
    /// - Return: New image with grid lines drawn.
    private static func AddGridLines(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
            //let Kernel = LineDraw()
            let Kernel = LinesDraw()
            let ImageWidth = Int(Image.size.width)
            let ImageHeight = Int(Image.size.height)
            var LineList = [LineDefinition]()
            let LineColor = Settings.GetColor(.GridLineColor, NSColor.red)
            let MinorLineColor = Settings.GetColor(.MinorGridLineColor, NSColor.yellow)
            
            if Settings.GetBool(.Show3DMinorGrid)
            {
                let Gap = Settings.GetDouble(.MinorGrid3DGap, 15.0)
                for Longitude in stride(from: 0.0, to: 180.0, by: Gap)
                {
                    var Y = Int(Double(ImageHeight) * (Longitude / 180.0))
                    if Y + 4 > ImageHeight
                    {
                        Y = Y - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: true,
                                                At: Y,
                                                Thickness: 4,
                                                Color: MinorLineColor)
                    LineList.append(Line)
                }
                for Latitude in stride(from: 0.0, to: 360.0, by: Gap)
                {
                    var X = Int(Double(ImageWidth) * (Latitude / 360.0))
                    if X + 4 > ImageWidth
                    {
                        X = X - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: false,
                                                At: X,
                                                Thickness: 4,
                                                Color: MinorLineColor)
                    LineList.append(Line)
                }
            }
            
            for Longitude in Longitudes.allCases
            {
                if Settings.DrawLongitudeLine(Longitude)
                {
                    var Y = Int(Double(ImageHeight) * Longitude.rawValue)
                    if Y + 4 > ImageHeight
                    {
                        Y = Y - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: true,
                                                At: Y,
                                                Thickness: 4,
                                                Color: LineColor)
                    LineList.append(Line)
                }
            }
            for Latitude in Latitudes.allCases
            {
                if Settings.DrawLatitudeLine(Latitude)
                {
                    var X = Int(Double(ImageWidth) * Latitude.rawValue)
                    if X + 4 > ImageWidth
                    {
                        X = X - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: false,
                                                At: X,
                                                Thickness: 4,
                                                Color: LineColor)
                    LineList.append(Line)
                }
            }
            let Final = DrawLine(Image: Image, Lines: LineList, Kernel: Kernel)
            return Final
        }
        else
        {
            return Image
        }
    }
    
    /// Draw lines on the passed image.
    /// - Parameter Image: The image upon which lines will be drawn.
    /// - Parameter Lines: The set of lines to draw.
    /// - Parameter Kernel: The Metal kernel to use to draw lines.
    /// - Returns: New image with lines drawn on it.
    private static func DrawLine(Image: NSImage, Lines: [LineDefinition], Kernel: LinesDraw) -> NSImage
    {
        var Final = Image
        #if true
        var LinesToDraw = [LineDrawParameters]()
        for Line in Lines
        {
            let LineToDraw = LineDrawParameters(IsHorizontal: simd_bool(Line.IsHorizontal),
                                                HorizontalAt: simd_uint1(Line.At),
                                                VerticalAt: simd_uint1(Line.At),
                                                Thickness: simd_uint1(Line.Thickness),
                                                LineColor: MetalLibrary.ToFloat4(Line.Color))
            LinesToDraw.append(LineToDraw)
        }
        Final = Kernel.DrawLines(Background: Image, Lines: LinesToDraw)
        #else
        for Line in Lines
        {
            Final = Kernel.DrawLine(Background: Final,
                                    IsHorizontal: Line.IsHorizontal,
                                    Thickness: Line.Thickness,
                                    At: Line.At,
                                    WithColor: Line.Color)
        }
        #endif
        return Final
    }
    
    /// Draw regions on the stencil.
    /// - Parameter Image: The image on which regions will be drawn.
    /// - Parameter Regions: List of earthquake regions to draw.
    /// - Parameter Kernel: Metal kernel wrapper to do the actual drawing.
    /// - Returns: New image with regions drawn.
    private static func DrawRegions(Image: NSImage, Regions: [EarthquakeRegion], Kernel: ImageBlender) -> NSImage
    {
        var Final = Image
        for Region in Regions
        {
            if Region.IsFallback
            {
                continue
            }
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
            Final = Kernel.MergeImages(Background: Final, Sprite: Region.RegionColor.withAlphaComponent(0.5),
                                       SpriteSize: NSSize(width: RegionWidth, height: RegionHeight),
                                       SpriteX: FinalX, SpriteY: FinalY)
        }
        return Final
    }
    
    /// Return an image representation from the passed `NSImage`.
    /// - Returns: Image representation from `From`.
    public static func GetImageRep(From: NSImage) -> NSBitmapImageRep
    {
        let ImgData = From.tiffRepresentation
        let CImg = CIImage(data: ImgData!)
        return NSBitmapImageRep(ciImage: CImg!)
    }
    
    /// Convert the passed image representation into an `NSImage`.
    /// - Returns: `NSImage` created from the passed image representation.
    public static func GetImage(From: NSBitmapImageRep) -> NSImage
    {
        let Final = NSImage(size: From.size)
        Final.addRepresentation(From)
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
