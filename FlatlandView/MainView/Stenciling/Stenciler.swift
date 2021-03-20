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
    static var StencilingQueue: OperationQueue? = nil
    
    /// Run the stencil pipeline on the supplied map.
    /// - Note: Pipeline is in the order:
    ///   - 1: Regions.
    ///   - 2: Grid lines.
    ///   - 3: UNESCO sites.
    ///   - 4: City names.
    ///   - 5: Earthquake magnitudes.
    /// - Note: The subscriber closure is called after each pipeline stage has completed.
    /// - Warning: If the caller has not subscribed to pipeline notifications, control will return immediately
    ///            with no changes to the image.
    /// - Parameter To: The image to draw stencils on.
    /// - Parameter Quakes: List of earthquakes to plot. If this array is empty or nil, no earthquakes will
    ///                     be plotted even if `Stages` contains `.Earthquakes`.
    /// - Parameter Stages: Array of pipeline stages to perform. If this array is empty, no action is taken
    ///                     and the image is returned unchanged.
    /// - Parameter Caller: The caller. Must implement `StencilPipelineProtocol`.
    public static func RunStencilPipeline(To Image: NSImage,
                                          Quakes: [Earthquake]? = nil,
                                          Stages: [StencilStages],
                                          Caller: StencilPipelineProtocol)
    {
        objc_sync_enter(StencilLock)
        MemoryDebug.Open("RunStencilPipeLine")
        defer
        {
            MemoryDebug.Close("RunStencilPipeLine")
            objc_sync_exit(StencilLock)
        }
        Debug.Print("RunStencilPipeline: \(Stages)")
        if Quakes == nil && Stages.count < 1
        {
            //Nothing to do - return the image unaltered.
            Caller.StageCompleted(nil, nil, nil)
            Caller.StencilPipelineCompleted(Time: 0, Final: nil)
            return
        }
        let MapRatio: Double = Double(Image.size.width) / 3600.0
        let LocalQuakes = Quakes
        StencilingQueue = OperationQueue()
        StencilingQueue?.qualityOfService = .background
        StencilingQueue?.name = "Stencil Queue"
        StencilingQueue?.addOperation
        {
            Caller.StencilPipelineStarted(Time: CACurrentMediaTime())
            var Working = Image
            if Stages.contains(.GridLines)
            {
                Working = AddGridLines(To: Working, Ratio: MapRatio)
                Caller.StageCompleted(Working, .GridLines, CACurrentMediaTime())
            }
            if Stages.contains(.UNESCOSites)
            {
                Working = AddWorldHeritageDecals(To: Working, Ratio: MapRatio)
                Caller.StageCompleted(Working, .UNESCOSites, CACurrentMediaTime())
            }
            var Rep = GetImageRep(From: Working)
            if Stages.contains(.CityNames)
            {
                Rep = AddCityNames(To: Rep, Ratio: MapRatio)
                Caller.StageCompleted(GetImage(From: Rep), .CityNames, CACurrentMediaTime())
            }
            if Stages.contains(.Earthquakes)
            {
                if let QuakeList = LocalQuakes
                {
                    if QuakeList.count > 0
                    {
                        Rep = AddMagnitudeValues(To: Rep, With: QuakeList, Ratio: MapRatio)
                        Caller.StageCompleted(GetImage(From: Rep), .Earthquakes, CACurrentMediaTime())
                    }
                }
            }
            Caller.StencilPipelineCompleted(Time: CACurrentMediaTime(), Final: GetImage(From: Rep))
        }
    }
    
    /// Provides a lock from too many callers at once.
    private static let StencilLock = NSObject()
    
    /// Create a stencil layer.
    /// - Parameter Layer: Determines the contents of the image of the stencil layer.
    /// - Parameter LayerData: Data a given layer may need.
    /// - Parameter Completion: Closure that takes the final image and layer type.
    public static func AddStencils2(_ Layer: GlobeLayers,
                                    _ LayerData: Any? = nil,
                                    Completion: ((NSImage?, GlobeLayers) -> ())? = nil)
    {
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Thread for \(Layer.rawValue)"
        Queue.addOperation
        {
            var LayerImage: NSImage? = nil
            switch Layer
            {
                case .CityNames:
                    break
                    
                case .GridLines:
                    LayerImage = ApplyGridLines()
                    
                case .Lines:
                    break
                    
                case .Magnitudes:
                    if let Quakes = LayerData as? [Earthquake]
                    {
                        LayerImage = ApplyMagnitudes(Earthquakes: Quakes)
                    }
                    
                    #if false
                case .Regions:
                    let Regions = Settings.GetEarthquakeRegions()
                    LayerImage = ApplyRectangles(Regions: Regions)
                    #endif
                    
                case .WorldHeritageSites:
                    break
                    
                #if true
                case .Test:
                    let RandomCircles = MakeRandomCircles()
                    LayerImage = ApplyCircles(Circles: RandomCircles)
                #endif
                
                default:
                    break
            }
            Completion?(LayerImage, Layer)
        }
    }
    
    /// Create an array of random circles.
    /// - Returns: Attay of circle records.
    private static func MakeRandomCircles() -> [CircleRecord]
    {
        var CircleList = [CircleRecord]()
        let Count = Int.random(in: 10 ... 20)
        for _ in 0 ..< Count
        {
            let RandomX = Int.random(in: 0 ... 3600)
            let RandomY = Int.random(in: 0 ... 1800)
            let Where = NSPoint(x: RandomX, y: RandomY)
            let RandomRadius = CGFloat.random(in: 50 ... 200)
            let RandomBorderWidth = CGFloat.random(in: 5 ... 15)
            let RandomColor = Utility.RandomColor()
            let RandomBorder = Utility.RandomColor()
            let SomeCircle = CircleRecord(Location: Where, Radius: RandomRadius,
                                          Color: RandomColor,
                                          OutlineColor: RandomBorder,
                                          OutlineWidth: RandomBorderWidth)
            CircleList.append(SomeCircle)
        }
        return CircleList
    }
    
    /// Add city names to the passed image representation.
    /// - Note: Determining the font size is dependent on several factors.
    /// - Parameter To: The image representation where city names will be added.
    /// - Parameter Ratio: Ratio between the standard sized map and the passed map.
    /// - Returns: Image representation with city names.
    private static func AddCityNames(To Image: NSBitmapImageRep, Ratio: Double) -> NSBitmapImageRep
    {
        var FontMultiplier: CGFloat = 1.0
        let ScaleFactor = NSScreen.main!.backingScaleFactor
        var Working = Image
        var CitiesToPlot = CityManager.FilteredCities()
        if let UserCities = CityManager.OtherCities
        {
            CitiesToPlot.append(contentsOf: UserCities)
        }
        var PlotMe = [TextRecord]()
        let BaseFontSize = ScaleFactor >= 2.0 ? 32.0 : 16.0
        if Image.size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if MapManager.CategoryFor(Map: MapType) == .Satellite
        {
            FontMultiplier = 0.8
        }
        let FontSize = CGFloat(BaseFontSize) * ScaleFactor * CGFloat(Ratio) * FontMultiplier
        
        for City in CitiesToPlot
        {
            let CityPoint = GeoPoint(City.Latitude, City.Longitude)
            let CityPointLocation = CityPoint.ToEquirectangular(Width: Int(Image.size.width),
                                                                Height: Int(Image.size.height))
            let Location = NSPoint(x: CityPointLocation.X + Int(Constants.StencilCityTextOffset.rawValue),
                                   y: CityPointLocation.Y)
            let CityColor = CityManager.ColorForCity(City)
            var LatitudeFontOffset = CGFloat(abs(City.Latitude) / 90.0)
            LatitudeFontOffset = CGFloat(Constants.StencilCitySize.rawValue) * LatitudeFontOffset
            let CityFont = NSFont.GetFont(InOrder: ["SFProText-Bold", "HelveticaNeue-Bold", "Avenir-Black", "ArialMT"],
                                          Size: FontSize + LatitudeFontOffset)
            let Record = TextRecord(Text: City.Name, Location: Location, Font: CityFont, Color: CityColor,
                                    OutlineColor: NSColor.black, QRCode: nil, Quake: nil)
            PlotMe.append(Record)
        }
        
        Working = DrawOn(Rep: Working, Messages: PlotMe, ForQuakes: false)
        return Working
    }
    
    /// Plot UNESCO World Heritage Sites as decals on the stencil.
    /// - Parameter To: The image upon which sites are plotted.
    /// - Parameter Ration: The ratio between the standard size map and the current image.
    /// - Returns: Update image with World Heritage Sites plotted.
    private static func AddWorldHeritageDecals(To Image: NSImage, Ratio: Double) -> NSImage
    {
        let Working = Image
        let TypeFilter = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self, Default: .AllSites)
        let Sites = MainController.GetAllSites()
        var FinalList = [WorldHeritageSite]()
        for Site in Sites
        {
            switch TypeFilter
            {
                case .AllSites:
                    FinalList.append(Site)
                    
                case .Mixed:
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
            let SitePoint = GeoPoint(Site.Latitude, Site.Longitude)
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
    /// - Note: Magnitudes are plotted in lowest-to-highest order to make sure the earhtquakes with the
    ///         greatest magnitudes are shown most prominently.
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
        let QuakeSource = Earthquakes.sorted(by: {$0.Magnitude < $1.Magnitude})
        let ScaleFactor = NSScreen.main!.backingScaleFactor
        var PlotMe = [TextRecord]()
        var Working = Image
        let QuakeFontRecord = Settings.GetString(.EarthquakeFontName, "Avenir")
        let QuakeFontName = Settings.ExtractFontName(From: QuakeFontRecord)!
        let BaseFontSize = 24.0
        var FontMultiplier: CGFloat = 1.0
        if Image.size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if MapManager.CategoryFor(Map: MapType) == .Satellite
        {
            FontMultiplier = 1.0
        }
        let FontSize = CGFloat(BaseFontSize) * CGFloat(Ratio) * ScaleFactor * FontMultiplier
        for Quake in QuakeSource
        {
            let Location = Quake.LocationAsGeoPoint().ToEquirectangular(Width: Int(Image.size.width),
                                                                        Height: Int(Image.size.height))
            var LocationPoint = NSPoint(x: Location.X, y: Location.Y)
            let Greatest = Quake.GreatestMagnitude
            let EqText = "\(Greatest.RoundedTo(3))"
            var LatitudeFontOffset = (abs(Quake.Latitude) / 90.0)
            LatitudeFontOffset = Constants.StencilFontSize.rawValue * LatitudeFontOffset
            let Mag = Quake.IsCluster ? Quake.GreatestMagnitude : Quake.Magnitude
            let FinalFontSize = FontSize + CGFloat(Mag) + CGFloat(LatitudeFontOffset)
            let QuakeFont = NSFont(name: QuakeFontName, size: FinalFontSize)!
            let MagRange = Utility.GetMagnitudeRange(For: Greatest)
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
            let QRImage: NSImage? = Barcodes.QRCode(With: Quake.EventPageURL,
                                                    FinalSize: NSSize(width: 100, height: 100))
            let Record = TextRecord(Text: EqText, Location: LocationPoint,
                                    Font: QuakeFont, Color: BaseColor, OutlineColor: NSColor.black,
                                    QRCode: QRImage, Quake: Quake)
            PlotMe.append(Record)
        }
        Working = DrawOn(Rep: Working, Messages: PlotMe, ForQuakes: true)
        return Working
    }
    
    /// Draw a set of strings on the passed image.
    /// - Parameter Rep: Image representation on which text is drawn.
    /// - Parameter Messages: Array of text records to display.
    /// - Parameter ForQuakes: If true, the text is drawn for earthquakes. Otherwise, normal text is assumed.
    /// - Returns: Image with the text drawn on it.
    private static func DrawOn(Rep: NSBitmapImageRep, Messages: [TextRecord], ForQuakes: Bool) -> NSBitmapImageRep
    {
        guard let Context = NSGraphicsContext(bitmapImageRep: Rep) else
        {
            fatalError("Error returned from NSGraphicsContext")
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = Context
        let UsePlainText = Settings.GetBool(.StencilPlainText)
        for Message in Messages
        {
            autoreleasepool
            {
                var MessageWidth: CGFloat = 0.0
                var MagLocation: NSPoint = NSPoint.zero
                if UsePlainText
                {
                    let WorkingText: NSString = NSString(string: Message.Text)
                    var Attrs = [NSAttributedString.Key: Any]()
                    Attrs[NSAttributedString.Key.font] = Message.Font as Any
                    Attrs[NSAttributedString.Key.foregroundColor] = Message.Color as Any
                    WorkingText.draw(at: NSPoint(x: Message.Location.x, y: Message.Location.y),
                                     withAttributes: Attrs)
                    MagLocation = Message.Location
                    let TextSize = WorkingText.size(withAttributes: Attrs)
                    MessageWidth = TextSize.width
                }
                else
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
                    MagLocation = FinalLocation
                    AttrString.draw(at: FinalLocation)
                    let TextSize = AttrString.size()
                    MessageWidth = TextSize.width
                }
                if ForQuakes
                {
                    if Settings.GetBool(.ShowMagnitudeBarCode)
                    {
                        if let QRCode = Message.QRCode
                        {
                            var FinalX = MagLocation.x + MessageWidth + 5
                            if FinalX + QRCode.size.width > Rep.size.width
                            {
                                FinalX = Rep.size.width - (QRCode.size.width + 20)
                            }
                            var FinalY = MagLocation.y
                            if FinalY + QRCode.size.height > Rep.size.height
                            {
                                FinalY = Rep.size.height - (QRCode.size.height - 5)
                            }
                            let Location = NSRect(x: FinalX, y: FinalY, width: 150, height: 150)
                            QRCode.draw(in: Location)
                        }
                    }
                }
            }
        }
        NSGraphicsContext.restoreGraphicsState()
        return Rep
    }
    
    /// Draw text strings on a surface.
    /// - Parameter Messages: List of strings to draw.
    /// - ImageSize: Size of the target surface to draw on
    /// - ForQuakes: Determines the context of the text.
    /// - Returns: Image with text drawn on it.
    private static func DrawText(Messages: [TextRecord],
                                 ImageSize: NSSize = NSSize(width: 3600, height: 1800),
                                 ForQuakes: Bool) -> NSImage
    {
        let Surface = MakeNewImage(Size: ImageSize)
        let SurfaceRep = GetImageRep(From: Surface)
        let NewRep = DrawOn(Rep: SurfaceRep, Messages: Messages, ForQuakes: ForQuakes)
        let Final = GetImage(From: NewRep)
        return Final
    }
    
    /// Defines a line definition.
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
            var LineThickness = 4
            let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
            if MapManager.CategoryFor(Map: MapType) == .Satellite
            {
                LineThickness = 1
            }
            
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
                                                Thickness: LineThickness,
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
                                                Thickness: LineThickness,
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
                                                Thickness: LineThickness,
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
                                                Thickness: LineThickness,
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
    
    //Synchronization locks.
    static var DrawRectangleLock = NSObject()
    static var DrawCircularLock = NSObject()
    static var DrawLinesLock = NSObject()
    static var DrawTextLock = NSObject()
    
    /// Draw earthquake magnitudes to the map.
    /// - Parameter Earthquakes: Array of earthquakes whose magnitudes will be drawn.
    /// - Parameter Size: Size of the target surface. Defaults to 3600 x 1800.
    /// - Returns: Image with earthquake magnitudes drawn on it. Nil if no earthquakes supplied.
    public static func ApplyMagnitudes(Earthquakes: [Earthquake],
                                       Size: NSSize = NSSize(width: 3600, height: 1800)) -> NSImage?
    {
        if Earthquakes.count < 1
        {
            return nil
        }
        let Ratio = Size.width / 3600.0
        let ScaleFactor = NSScreen.main!.backingScaleFactor
        var PlotMe = [TextRecord]()
        let QuakeFontRecord = Settings.GetString(.EarthquakeFontName, "Avenir")
        let QuakeFontName = Settings.ExtractFontName(From: QuakeFontRecord)!
        let BaseFontSize = Settings.ExtractFontSize(From: QuakeFontRecord)!
        var FontMultiplier: CGFloat = 1.0
        if Size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        FontMultiplier = 1.0
        let QuakeSize = Settings.GetEnum(ForKey: .QuakeScales, EnumType: MapNodeScales.self, Default: .Normal)
        var UserScale: CGFloat = 1.0
        switch QuakeSize
        {
            case .Small:
                UserScale = 0.5
                
            case .Normal:
                UserScale = 1.0
                
            case .Large:
                UserScale = 1.3
        }
        let FontSize = BaseFontSize * CGFloat(Ratio) * ScaleFactor * FontMultiplier * UserScale
        for Quake in Earthquakes
        {
            let Location = Quake.LocationAsGeoPoint().ToEquirectangular(Width: Int(Size.width),
                                                                        Height: Int(Size.height))
            var LocationPoint = NSPoint(x: Location.X, y: Location.Y)
            #if false
            let Greatest = Quake.GreatestMagnitudeValue
            let EqText = "\(Greatest.RoundedTo(3))"
            #else
            let Greatest = Quake.GreatestMagnitude
            let EqText = "\(Greatest.RoundedTo(3))"
            #endif
            var LatitudeFontOffset = abs(Quake.Latitude) / 90.0
            LatitudeFontOffset = Constants.StencilFontSize.rawValue * LatitudeFontOffset
            let Mag = Quake.IsCluster ? Quake.GreatestMagnitude : Quake.Magnitude
            let FinalFontSize = FontSize + CGFloat(Mag) + CGFloat(LatitudeFontOffset)
            let QuakeFont = NSFont(name: QuakeFontName, size: FinalFontSize)!
            let MagRange = Utility.GetMagnitudeRange(For: Greatest)// Quake.GreatestMagnitude)
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
            if LocationPoint.x + Length > Size.width
            {
                LocationPoint = NSPoint(x: Size.width - Length,
                                        y: LocationPoint.y)
            }
            let QRImage: NSImage? = Barcodes.QRCode(With: Quake.EventPageURL,
                                                    FinalSize: NSSize(width: 100, height: 100),
                                                    Digit: Quake.Magnitude)
            let Record = TextRecord(Text: EqText, Location: LocationPoint,
                                    Font: QuakeFont, Color: BaseColor, OutlineColor: NSColor.black,
                                    QRCode: QRImage, Quake: Quake)
            PlotMe.append(Record)
        }
        let Final = DrawText(Messages: PlotMe, ImageSize: Size, ForQuakes: true)
        return Final
    }

    /// Draw grid lines on the map.
    /// - Parameter Size: Size of the surface on which to draw the grid lines. Defaults to 3600 x 1800.
    /// - Returns: Image with grid lines applied.
    public static func ApplyGridLines(Size: NSSize = NSSize(width: 3600, height: 1800)) -> NSImage
    {
        objc_sync_enter(DrawLinesLock)
        defer{objc_sync_exit(DrawLinesLock)}
        let Image = MakeNewImage(Size: Size)
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
    
    /// Draw circles on the map.
    /// - Note: Since the map is rectangular, circles will appear distorted if the map is applied to a globe.
    /// - Parameter Size: Size of the map on which to draw circles. Defaults to 3600 x 1800.
    /// - Parameter Circles: Array of circles to draw.
    /// - Returns: Image with circles drawn on it.
    public static func ApplyCircles(Size: NSSize = NSSize(width: 3600, height: 1800),
                                    Circles: [CircleRecord]) -> NSImage
    {
        objc_sync_enter(DrawCircularLock)
        defer{objc_sync_exit(DrawCircularLock)}
        var Image = MakeNewImage(Size: Size)
        let MetalShape = Metal2DShapeGenerator()
        var DrawnCircles = [(CircleRecord, NSImage)]()
        for Circle in Circles
        {
            autoreleasepool
            {
                let CircleSize = NSSize(width: Circle.Radius * 2, height: Circle.Radius * 2)
                var BorderWidth = 0
                if let Border = Circle.OutlineWidth
                {
                    BorderWidth = Int(Border)
                }
                let CircleImage = MetalShape.DrawCircle(BaseSize: CircleSize,
                                                        Radius: Int(Circle.Radius) - BorderWidth - 1,
                                                        Interior: Circle.Color,
                                                        Background: NSColor.clear,
                                                        BorderColor: NSColor.black,
                                                        BorderWidth: BorderWidth)
                DrawnCircles.append((Circle, CircleImage!))
            }
        }
        let B = ImageBlender()
        Image = B.MergeImages(Background: Image, Sprite: DrawnCircles[0].1,
                              SpriteX: Int(DrawnCircles[0].0.Location.x),
                              SpriteY: Int(DrawnCircles[0].0.Location.y))!
        return Image
    }
    
    /// Apply rectangular decals for earthquake regions onto a transparent image.
    /// - Parameter Size: The size of the image. Defaults to 3600x1800. The size should always have the ratio
    ///                   2:1 for width to hight.
    /// - Parameter Regions: List of earthquake regions to plot.
    /// - Returns: Image of the earthquake regions.
    public static func ApplyRectangles(Size: NSSize = NSSize(width: 3600, height: 1800),
                                       Regions: [UserRegion]) -> NSImage
    {
        objc_sync_enter(DrawRectangleLock)
        defer{objc_sync_exit(DrawRectangleLock)}
        let Blender = ImageBlender()
        let MapRatio: Double = Double(Size.width) / 3600.0
        var Surface = MakeNewImage(Size: Size)
        
        for Region in Regions
        {
            if Region.IsFallback
            {
                continue
            }
            var RegionWidth = GeoPoint.HorizontalDistance(Longitude1: Region.UpperLeft.Longitude,
                                                          Longitude2: Region.LowerRight.Longitude,
                                                          Latitude: Region.UpperLeft.Latitude,
                                                          Width: Int(Size.width), Height: Int(Size.height))
            RegionWidth = RegionWidth * MapRatio
            var RegionHeight = GeoPoint.VerticalDistance(Latitude1: Region.UpperLeft.Latitude,
                                                         Latitude2: Region.LowerRight.Latitude,
                                                         Longitude: Region.UpperLeft.Longitude,
                                                         Width: Int(Size.width), Height: Int(Size.height))
            RegionHeight = RegionHeight * MapRatio
            var XPercent: Double = 0.0
            var YPercent: Double = 0.0
            var (FinalX, FinalY) = GeoPoint.TransformToImageCoordinates(Latitude: Region.UpperLeft.Latitude,
                                                                        Longitude: Region.UpperLeft.Longitude,
                                                                        Width: Int(Size.width),
                                                                        Height: Int(Size.height),
                                                                        XPercent: &XPercent,
                                                                        YPercent: &YPercent)
            FinalX = Int(Double(FinalX) * MapRatio)
            FinalY = Int(Double(FinalY) * MapRatio)
            Surface = Blender.MergeImages(Background: Surface, Sprite: Region.RegionColor.withAlphaComponent(0.5),
                                          SpriteSize: NSSize(width: RegionWidth, height: RegionHeight),
                                          SpriteX: FinalX, SpriteY: FinalY)
        }
        
        return Surface
    }
    
    /// Creates and returns a transparent image of the given size.
    /// - Parameter Size: The size of the image to return.
    /// - Returns: Transparent image of the given size.
    private static func MakeNewImage(Size: NSSize) -> NSImage
    {
        let SolidColor = SolidColorImage()
        let Transparent = SolidColor.Fill(Width: Int(Size.width), Height: Int(Size.height), With: NSColor.clear)!
        return Transparent
    }
}

/// Defines a rectangle to draw.
struct RectangleRecord
{
    /// Upper left point of the rectangle.
    let UpperLeft: NSPoint
    /// Lower right point of the rectangle.
    let LowerRight: NSPoint
    /// Fill color of the rectangle.
    let FillColor: NSColor
    /// If present, the border color of the rectangle. If not present, no border is drawn.
    let BorderColor: NSColor?
    /// If present, the border width of the rectangle. If not present, no border is drawn.
    let BorderWidth: CGFloat?
}

/// Used to define a line to draw.
struct LineRecord
{
    /// Starting point.
    let Start: NSPoint
    /// Ending point.
    let End: NSPoint
    /// Width of the line.
    let Width: CGFloat
    /// Color of the line.
    let Color: NSColor
    /// If present, the outline color of the line. If not present, no outline drawn.
    let OutlineColor: NSColor?
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
    /// If present, an image of a QR code to display.
    let QRCode: NSImage?
    /// If present, an earthquake associated with the text.
    let Quake: Earthquake?
}

/// Used to define a circle.
struct CircleRecord
{
    /// Location of the center of the circle.
    let Location: NSPoint
    /// Radius of the circle.
    let Radius: CGFloat
    /// Fill color of the circle.
    let Color: NSColor
    /// Color of the outline. If nil, no outline is drawn.
    let OutlineColor: NSColor?
    /// Width of the outline. If nil, no outline is drawn.
    let OutlineWidth: CGFloat?
}
