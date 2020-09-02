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
import CoreImage
import CoreImage.CIFilterBuiltins

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
    /// - Parameter UNESCOSites: Plot UNESCO World Heritage Sites.
    /// - Parameter CalledBy: The name of the caller.
    /// - Parameter Status: Closure for handling status updates for drawing stencils. First parameter is a string
    ///                     describing the status and the second parameter is the number of seconds since the
    ///                     function was called.
    /// - Parameter FinalNotify: Closure passed to the completion handler.
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
                                   UNESCOSites: Bool = false,
                                   CalledBy: String? = nil,
                                   Status: ((String, Double) -> ())? = nil,
                                   FinalNotify: (() -> ())? = nil,
                                   Completed: ((NSImage, Double, String?, (() -> ())?) -> ())? = nil)
    {
        objc_sync_enter(StencilLock)
        defer{objc_sync_exit(StencilLock)}
        let MapRatio: Double = Double(Image.size.width) / 3600.0
        //Debug.Print("Stencil on image size: \(Image.size), MapRatio=\(MapRatio)")
        let StartTime = CACurrentMediaTime()
        if Quakes == nil && !ShowRegions && !PlotCities && !GridLines && !UNESCOSites
        {
            //Nothing to do - return the image unaltered.
            Completed?(Image, 0.0, CalledBy, FinalNotify)
            return
        }
        let LocalQuakes = Quakes
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Stencil Queue"
        Queue.addOperation
        {
            var Working = Image
            
            if ShowRegions
            {
                Status?("Creating regions", CACurrentMediaTime() - StartTime)
                let Regions = Settings.GetEarthquakeRegions()
                if Regions.count > 0
                {
                    let Blender = ImageBlender()
                    Working = DrawRegions(Image: Working, Regions: Regions, Ratio: MapRatio,
                                          Kernel: Blender)
                }
            }
            if GridLines
            {
                Status?("Adding grid lines", CACurrentMediaTime() - StartTime)
                Working = AddGridLines(To: Working, Ratio: MapRatio)
            }
            if UNESCOSites
            {
                Status?("Plotting UNESCO sites", CACurrentMediaTime() - StartTime)
                Working = AddWorldHeritageDecals(To: Working, Ratio: MapRatio)
            }
            
            var Rep = GetImageRep(From: Working)
            if PlotCities
            {
                Status?("Plotting cities", CACurrentMediaTime() - StartTime)
                Rep = AddCityNames(To: Rep, Ratio: MapRatio)
            }
            if let QuakeList = LocalQuakes
            {
                Status?("Plotting earthquakes", CACurrentMediaTime() - StartTime)
                Rep = AddMagnitudeValues(To: Rep, With: QuakeList, Ratio: MapRatio)
            }
            let Final = GetImage(From: Rep)
            let Duration = CACurrentMediaTime() - StartTime
            Status?("Finished", CACurrentMediaTime() - StartTime)
            Completed?(Final, Duration, CalledBy, FinalNotify)
        }
    }
    
    /// Add city names to the passed image representation.
    /// - Parameter To: The image representation where city names will be added.
    /// - Parameter Ratio: Ratio between the standard sized map and the passed map.
    /// - Returns: Image representation with city names.
    private static func AddCityNames(To Image: NSBitmapImageRep, Ratio: Double) -> NSBitmapImageRep
    {
        let ScaleFactor = NSScreen.main!.backingScaleFactor
        var Working = Image
        let CityList = Cities()
        let CitiesToPlot = CityList.FilteredCities()
        var PlotMe = [TextRecord]()
        let CityFontRecord = Settings.GetString(.CityFontName, "Avenir")
        let CityFontName = Settings.ExtractFontName(From: CityFontRecord)!
        let BaseFontSize = Settings.ExtractFontSize(From: CityFontRecord)!
        var FontMultiplier: CGFloat = 1.0
        if Image.size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        let FontSize = BaseFontSize * ScaleFactor * CGFloat(Ratio) * FontMultiplier
        for City in CitiesToPlot
        {
            let CityPoint = GeoPoint2(City.Latitude, City.Longitude)
            let CityPointLocation = CityPoint.ToEquirectangular(Width: Int(Image.size.width),
                                                                Height: Int(Image.size.height))
            let Location = NSPoint(x: CityPointLocation.X + Int(Constants.StencilCityTextOffset.rawValue),
                                   y: CityPointLocation.Y)
            let CityColor = Cities.ColorForCity(City)
            var LatitudeFontOffset = CGFloat(abs(City.Latitude) / 90.0)
            LatitudeFontOffset = CGFloat(Constants.StencilCitySize.rawValue) * LatitudeFontOffset
            let CityFont = NSFont(name: CityFontName, size: FontSize + LatitudeFontOffset)!
            let Record = TextRecord(Text: City.Name, Location: Location, Font: CityFont, Color: CityColor,
                                    OutlineColor: NSColor.black)
            PlotMe.append(Record)
        }
        
        Working = DrawOn(Rep: Working, Messages: PlotMe)
        return Working
    }
    
    /// Plot UNESCO World Heritage Sites as decals on the stencil.
    /// - Parameter To: The image upon which sites are plotted.
    /// - Parameter Ration: The ratio between the standard size map and the current image.
    /// - Returns: Update image with World Heritage Sites plotted.
    private static func AddWorldHeritageDecals(To Image: NSImage, Ratio: Double) -> NSImage
    {
        let Working = Image
        let TypeFilter = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: SiteTypeFilters.self, Default: .Either)
        MainView.InitializeWorldHeritageSites()
        let Sites = MainView.GetAllSites()
        var FinalList = [WorldHeritageSite]()
        for Site in Sites
        {
            switch TypeFilter
            {
                case .Either:
                    FinalList.append(Site)
                    
                case .Both:
                    if Site.Category == "Mixed"
                    {
                        FinalList.append(Site)
                    }
                    
                case .Natural:
                    if Site.Category == "Natural"
                    {
                        FinalList.append(Site)
                    }
                    
                case .Cultural:
                    if Site.Category == "Cultural"
                    {
                        FinalList.append(Site)
                    }
            }
        }
        Working.lockFocus()
        for Site in FinalList
        {
            var NodeColor = NSColor.black
            switch Site.Category
            {
                case "Mixed":
                    NodeColor = NSColor.systemPurple
                    
                case "Natural":
                    NodeColor = NSColor.systemGreen
                    
                case "Cultural":
                    NodeColor = NSColor.systemRed
                    
                default:
                    NodeColor = NSColor.white
            }
            let SitePoint = GeoPoint2(Site.Latitude, Site.Longitude)
            let SitePointLocation = SitePoint.ToEquirectangular(Width: Int(Image.size.width),
                                                                Height: Int(Image.size.height))
            let SiteShape = NSBezierPath()
            let YOffset: Double = Constants.WHSYOffset.rawValue
            let LeftX: Double = Constants.WHSLeftX.rawValue
            let RightX: Double = Constants.WHSRightX.rawValue
            SiteShape.move(to: NSPoint(x: SitePointLocation.X, y: SitePointLocation.Y))
            SiteShape.line(to: NSPoint(x: Double(SitePointLocation.X) + LeftX, y: Double(SitePointLocation.Y) - YOffset))
            SiteShape.line(to: NSPoint(x: Double(SitePointLocation.X) + RightX, y: Double(SitePointLocation.Y) - YOffset))
            SiteShape.line(to: NSPoint(x: SitePointLocation.X, y: SitePointLocation.Y))
            NSColor.black.setStroke()
            NodeColor.setFill()
            SiteShape.stroke()
            SiteShape.fill()
        }
        Working.unlockFocus()
        return Working
    }
    
    /// Add earthquake magnitude values to the map if the proper settings are true.
    /// - Parameter To: The map to add earthquake magnitude values.
    /// - Parameter With: List of earthquakes to add. This function assumes that all earthquakes in this
    ///                   list should be plotted.
    /// - Parameter Ratio: Ratio between the standard-sized map and the current map.
    /// - Returns: The map with earthquake magnitude values or the same image, depending on settings.
    private static func AddMagnitudeValues(To Image: NSBitmapImageRep, With Earthquakes: [Earthquake],
                                           Ratio: Double) -> NSBitmapImageRep
    {
        if Earthquakes.count < 1
        {
            return Image
        }
        let ScaleFactor = NSScreen.main!.backingScaleFactor
        var PlotMe = [TextRecord]()
        var Working = Image
        let QuakeFontRecord = Settings.GetString(.EarthquakeFontName, "Avenir")
        let QuakeFontName = Settings.ExtractFontName(From: QuakeFontRecord)!
        let BaseFontSize = Settings.ExtractFontSize(From: QuakeFontRecord)!
        var FontMultiplier: CGFloat = 1.0
        if Image.size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        let FontSize = BaseFontSize * CGFloat(Ratio) * ScaleFactor * FontMultiplier
        for Quake in Earthquakes
        {
            let Location = Quake.LocationAsGeoPoint2().ToEquirectangular(Width: Int(Image.size.width),
                                                                         Height: Int(Image.size.height))
            var LocationPoint = NSPoint(x: Location.X, y: Location.Y)
            let EqText = "\(Quake.Magnitude.RoundedTo(3))"
            var LatitudeFontOffset = abs(Quake.Latitude) / 90.0
            LatitudeFontOffset = Constants.StencilFontSize.rawValue * LatitudeFontOffset
            let FinalFontSize = FontSize + CGFloat(Quake.Magnitude) + CGFloat(LatitudeFontOffset)
            let QuakeFont = NSFont(name: QuakeFontName, size: FinalFontSize)!
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
            //Take care of text that is very close to the International Date Line/edge of
            //the image.
            let Length = Utility.StringWidth(TheString: EqText, TheFont: QuakeFont)
            if LocationPoint.x + Length > Image.size.width
            {
                LocationPoint = NSPoint(x: Image.size.width - Length,
                                        y: LocationPoint.y)
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
                    Attrs[NSAttributedString.Key.strokeWidth] = Constants.StencilTextStrokeWidth.rawValue as Any
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
    /// - Parameter Ratio: Ratio between the standard sized-map and the current map.
    /// - Return: New image with grid lines drawn.
    private static func AddGridLines(To Image: NSImage, Ratio: Double) -> NSImage
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
            let ImageWidth = Int(Image.size.width)
            let ImageHeight = Int(Image.size.height)
            var LineList = [LineDefinition]()
            let LineColor = Settings.GetColor(.GridLineColor, NSColor.red)
            let MinorLineColor = Settings.GetColor(.MinorGridLineColor, NSColor.yellow)
            
            if Settings.GetBool(.Show3DMinorGrid)
            {
                let Gap = Settings.GetDouble(.MinorGrid3DGap, .MinorGridGap)
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
                    X = -Line.Thickness
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
    
    /// Draw lines on the passed image.
    /// - Parameter Image: The image upon which lines will be drawn.
    /// - Parameter Lines: The set of lines to draw.
    /// - Parameter Kernel: The Metal kernel to use to draw lines.
    /// - Returns: New image with lines drawn on it.
    private static func DrawLine(Image: NSImage, Lines: [LineDefinition], Kernel: LinesDraw) -> NSImage
    {
        var Final = Image
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
        return Final
    }
    
    /// Draw regions on the stencil.
    /// - Parameter Image: The image on which regions will be drawn.
    /// - Parameter Regions: List of earthquake regions to draw.
    /// - Parameter Ratio: A ratio between the actual image size and the expected image size.
    /// - Parameter Kernel: Metal kernel wrapper to do the actual drawing.
    /// - Returns: New image with regions drawn.
    private static func DrawRegions(Image: NSImage, Regions: [EarthquakeRegion], Ratio: Double,
                                    Kernel: ImageBlender) -> NSImage
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
            var RegionWidth = GeoPoint2.HorizontalDistance(Longitude1: Region.UpperLeft.Longitude,
                                                           Longitude2: Region.LowerRight.Longitude,
                                                           Latitude: Region.UpperLeft.Latitude,
                                                           Width: ImageWidth, Height: ImageHeight)
            RegionWidth = RegionWidth * Ratio
            var RegionHeight = GeoPoint2.VerticalDistance(Latitude1: Region.UpperLeft.Latitude,
                                                          Latitude2: Region.LowerRight.Latitude,
                                                          Longitude: Region.UpperLeft.Longitude,
                                                          Width: ImageWidth, Height: ImageHeight)
            RegionHeight = RegionHeight * Ratio
            var XPercent: Double = 0.0
            var YPercent: Double = 0.0
            var (FinalX, FinalY) = GeoPoint2.TransformToImageCoordinates(Latitude: Region.UpperLeft.Latitude,
                                                                         Longitude: Region.UpperLeft.Longitude,
                                                                         Width: ImageWidth,
                                                                         Height: ImageHeight,
                                                                         XPercent: &XPercent,
                                                                         YPercent: &YPercent)
            FinalX = Int(Double(FinalX) * Ratio)
            FinalY = Int(Double(FinalY) * Ratio)
            Final = Kernel.MergeImages(Background: Final, Sprite: Region.RegionColor.withAlphaComponent(0.5),
                                       SpriteSize: NSSize(width: RegionWidth, height: RegionHeight),
                                       SpriteX: FinalX, SpriteY: FinalY)
        }
        return Final
    }
    
    /// Return an image representation from the passed `NSImage`. This is used to get the representation of the
    /// image once rather than each time something is drawn on the image. This increases performance significantly.
    /// - Note:
    ///   - Depending on the resolution of the screen, the image's size will be changed when it is created. In other
    ///     words, it may be larger or smaller. So far, only larger images have been encountered. In practice, what
    ///     this means is text drawn on the larger-than-expected image will be much smaller than desired when the
    ///     texture is reapplied to the sphere. To get around this undesired behavior, this function checkes for the
    ///     screen's scaling and rescales the intermediate image appropriately to ensure it will result in legible
    ///     text.
    ///   - See [Scaling an Image OSX Swift](https://stackoverflow.com/questions/43383331/scaling-an-image-osx-swift)
    /// - Parameter From: The image from which an `NSBitmapImageRep` will be returned.
    /// - Returns: Image representation from `From`.
    public static func GetImageRep(From: NSImage) -> NSBitmapImageRep
    {
        let ImgData = From.tiffRepresentation
        var CImg = CIImage(data: ImgData!)
        #if false
        let ScaleFactor = NSScreen.main!.backingScaleFactor
        if ScaleFactor == 2.0
        {
        let Scaling = CIFilter.bicubicScaleTransform()
        Scaling.inputImage = CImg
        Scaling.scale = Float(0.5)
        CImg = Scaling.outputImage
        }
        #endif
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
