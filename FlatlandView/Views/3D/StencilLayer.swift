//
//  StencilLayer.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Implementaiton of the stencil layer for 3D mode.
/// - Note: The stencil layer provides an alternative way to display text and some annotations to the
///         3D globe view.
class StencilLayer: SCNNode
{
    public weak var Parent: GlobeProtocol? = nil
    
    /// Default initializer.
    override init()
    {
        super.init()
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    /// Initialization common to all initializers.
    func CommonInitialization()
    {
        self.name = GlobeNodeNames.StencilNode.rawValue
        Sphere = SCNSphere(radius: GlobeRadius.StencilLayer.rawValue)
        Sphere?.segmentCount = 100
        self.geometry = Sphere!
        self.position = SCNVector3(0.0, 0.0, 0.0)
        ClearStencils()
    }
    
    var Sphere: SCNSphere? = nil
    
    /// Remove all stencils and create a transparent texture.
    func ClearStencils()
    {
        let SolidColor = SolidColorImage()
        StencilTexture = SolidColor.TransparentImage(Width: 3600, Height: 1800)
        self.geometry?.firstMaterial?.diffuse.contents = StencilTexture!
    }
    
    var StencilTexture: NSImage? = nil
    
    /// Add a new set of earthquakes.
    /// - Note: No action will be taken until `ApplyStencils` is called.
    /// - Parameter: Quakes: The new earthquakes to draw.
    func UpdateEarthquakes(_ Quakes: [Earthquake])
    {
        CurrentQuakes = Quakes
    }
    
    var CurrentQuakes: [Earthquake] = [Earthquake]()
    
    /// Add a set of cities to draw.
    /// - Note: No action will be taken until `ApplyStencils` is called.
    /// - Parameter: CityList: The set of city names to draw.
    func UpdateCities(_ CityList: [City])
    {
        CitiesToPlot = CityList
    }
    
    var CitiesToPlot = [City]()
    
    var StencilLock = NSObject()
    
    /// Apply stencils. The stencil layer is cleared before application.
    func ApplyStencils()
    {
        DoApplyStencils
        {
            Texture in
            self.Parent?.NewStencilTexture(Texture)
        }
    }
    
    /// Apply stencils.
    /// - Parameter Completed: Closure called when all stencils have been applied. The completed texture
    ///                        is passed as the first parameter.
    private func DoApplyStencils(Completed: ((NSImage) -> ())? = nil)
    {
        objc_sync_enter(StencilLock)
        defer{objc_sync_exit(StencilLock)}
        let SolidColor = SolidColorImage()
        StencilTexture = SolidColor.TransparentImage(Width: 3600, Height: 1800)
        DispatchQueue.main.async
        {
            var Working = self.StencilTexture!
            if Settings.GetBool(.ShowEarthquakeRegions)
            {
                let Regions = Settings.GetEarthquakeRegions()
                if Regions.count > 0
                {
                    let Blender = ImageBlender()
                    Working = self.DrawRegions(Image: Working, Regions: Regions, Kernel: Blender)
                }
            }
            if Settings.GetBool(.GridLinesDrawnOnMap)
            {
                Working = self.AddGridLines(To: Working)
            }
            var Rep = self.GetImageRep(From: Working)
            if Settings.GetBool(.CityNamesDrawnOnMap)
            {
                Rep = self.AddCityNames(To: Rep)
            }
            if Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews,
                                EnumType: EarthquakeMagnitudeViews.self,
                                Default: .No) == .Stenciled
            {
                Rep = self.AddMagnitudeValues(To: Rep, With: self.CurrentQuakes)
            }
            let Final = self.GetImage(From: Rep)
            OperationQueue.main.addOperation
            {
                self.StencilTexture = Final
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
    
    typealias LineDefinition = (IsHorizontal: Bool, At: Int, Thickness: Int, Color: NSColor)
    
    /// Add grid lines to the passed image.
    /// - Parameter To: The image to which to add gridlines.
    /// - Return: New image with grid lines drawn.
    func AddGridLines(To Image: NSImage) -> NSImage
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
            let Kernel = LineDraw()
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
            #if true
            let Final = DrawLine(Image: Image, Lines: LineList, Kernel: Kernel)
            #else
            let Equator: LineDefinition = (IsHorizontal: true,
                                           At: (ImageHeight / 2) - 4,
                                           Thickness: 8,
                                           Color: NSColor.red.withAlphaComponent(0.75))
            let Meridian1: LineDefinition = (IsHorizontal: false,
                                             At: (ImageWidth / 2) - 4,
                                             Thickness: 8,
                                             Color: NSColor.orange.withAlphaComponent(0.75))
            let Meridian2: LineDefinition = (IsHorizontal: false,
                                             At: 0,
                                             Thickness: 4,
                                             Color: NSColor.orange.withAlphaComponent(0.75))
            let Meridian3: LineDefinition = (IsHorizontal: false,
                                             At: ImageWidth - 4,
                                             Thickness: 4,
                                             Color: NSColor.orange.withAlphaComponent(0.75))
            let Final = DrawLine(Image: Image, Lines: [Equator, Meridian1, Meridian2, Meridian3],
                                 Kernel: Kernel)
            #endif
            return Final
        }
        else
        {
            return Image
        }
    }
    
    func DrawLine(Image: NSImage, Lines: [LineDefinition], Kernel: LineDraw) -> NSImage
    {
        var Final = Image
        for Line in Lines
        {
            Final = Kernel.DrawLine(Background: Final,
                                    IsHorizontal: Line.IsHorizontal,
                                    Thickness: Line.Thickness,
                                    At: Line.At,
                                    WithColor: Line.Color)
        }
        return Final
    }
    
    /// Draw regions on the stencil.
    /// - Parameter Image: The image on which regions will be drawn.
    /// - Parameter Regions: List of earthquake regions to draw.
    /// - Parameter Kernel: Metal kernel wrapper to do the actual drawing.
    /// - Returns: New image with regions drawn.
    func DrawRegions(Image: NSImage, Regions: [EarthquakeRegion], Kernel: ImageBlender) -> NSImage
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

