//
//  +FlatViewStenciling.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension FlatView
{
    func StencilCities(On Image: NSImage) -> NSImage
    {
        let Rep = Stenciler.GetImageRep(From: Image)
        var CitiesToPlot = CityManager.FilteredCities()
        if let UserCities = CityManager.OtherCities
        {
            CitiesToPlot.append(contentsOf: UserCities)
        }
        if CitiesToPlot.isEmpty
        {
            Debug.Print("No cities to plot.")
            return Image
        }
        var Records = [TextRecord]()
        var CitySet = Set<String>()
        for City in CitiesToPlot
        {
            if CitySet.contains(City.Name)
            {
                continue
            }
            CitySet.insert(City.Name)
            let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
            var LongitudeAdjustment = -1.0
            if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
            {
                LongitudeAdjustment = 1.0
            }
            var Distance = Geometry.DistanceFromContextPole(To: GeoPoint(City.Latitude, City.Longitude))
 //           let Ratio = FlatConstants.FlatRadius.rawValue / PhysicalConstants.HalfEarthCircumference.rawValue
 //           let Ratio = FlatConstants.StencilRadius.rawValue / (PhysicalConstants.HalfEarthCircumference.rawValue / 2)
 //           Distance = Distance * Ratio
            var LocationBearing = Geometry.Bearing(Start: GeoPoint(90.0, 0.0),
                                                   End: GeoPoint(City.Latitude, City.Longitude * LongitudeAdjustment))
            LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
            let PointX = Distance * cos(LocationBearing)
            let PointY = Distance * sin(LocationBearing)
            let Record = TextRecord(Text: City.Name, Location: NSPoint(x: PointX, y: PointY),
                                    Font: NSFont.systemFont(ofSize: 50.0), Color: NSColor.red,
                                    OutlineColor: NSColor.black, QRCode: nil, Quake: nil)
            Records.append(Record)
        }
        let Working = StencilText(Records, On: Rep)
//        let Working = StencilText([Records.first!], On: Rep)
        let Final = Stenciler.GetImage(From: Working)
        return Final
    }
    
    /// Stencil the text in the set of `TextRecords` onto the passed image.
    /// - Parameter Records: Array of text records to draw.
    /// - Parameter On: NSImage bitmap representation where the drawing will take place.
    /// - Returns: Updated NSImage bitmap representation.
    func StencilText(_ Records: [TextRecord], On Rep: NSBitmapImageRep) -> NSBitmapImageRep
    {
        guard let Context = NSGraphicsContext(bitmapImageRep: Rep) else
        {
            Debug.FatalError("Error returned from NSGraphicsContext")
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = Context
        for Message in Records
        {
            autoreleasepool
            {
                print("Drawing \(Message.Text)")
                let WorkingText: NSString = NSString(string: Message.Text)
                var Attrs = [NSAttributedString.Key: Any]()
                Attrs[NSAttributedString.Key.font] = Message.Font as Any
                Attrs[NSAttributedString.Key.foregroundColor] = Message.Color as Any
                WorkingText.draw(at: NSPoint(x: Message.Location.x, y: Message.Location.y),
                                 withAttributes: Attrs)
            }
        }
        NSGraphicsContext.restoreGraphicsState()
        return Rep
    }
    
    /// Create an image with a radial grid for the flat view of the Earth.
    /// - Note: The image created and returned is much larger than the final 3D surface where it will be
    ///         displayed. This is intentional to decrease blurriness when rendered in 3D.
    /// - Returns: Mostly transparent image with grid lines drawn on it.
    func StencilGrid() -> NSImage
    {
        let Surface = NSImage.init(Color: NSColor.clear,
                                   Size: NSSize(width: FlatConstants.StencilRadius.rawValue * 2.0,
                                                height: FlatConstants.StencilRadius.rawValue * 2.0))
        Surface.lockFocus()
        if Settings.GetBool(.ShowWallClockSeparators)
        {
            let DashPattern: [CGFloat] =
                [
                    CGFloat(FlatConstants.LineDash0.rawValue),
                    CGFloat(FlatConstants.LineDash1.rawValue)
                ]
            let LineColor = Settings.GetColor(.WallClockGridLineColor, NSColor.Maroon)
            for Angle in stride(from: 0.0, to: 359.9, by: 15.0)
            {
                let FinalAngle = Angle + 7.5
                let X = FlatConstants.StencilRadius.rawValue * cos(FinalAngle.Radians)
                let Y = FlatConstants.StencilRadius.rawValue * sin(FinalAngle.Radians)
                let Line = NSBezierPath()
                LineColor.set()
                LineColor.setStroke()
                Line.lineWidth = CGFloat(FlatConstants.WallClockLineWidth.rawValue)
                Line.lineCapStyle = .round
                Line.setLineDash(DashPattern, count: DashPattern.count, phase: 0.0)
                Line.lineCapStyle = .round
                Line.move(to: NSPoint(x: FlatConstants.StencilRadius.rawValue,
                                      y: FlatConstants.StencilRadius.rawValue))
                Line.line(to: NSPoint(x: X + FlatConstants.StencilRadius.rawValue,
                                      y: Y + FlatConstants.StencilRadius.rawValue))
                Line.stroke()
                Line.fill()
            }
        }

        let LineColor = Settings.GetColor(.PrimaryGridLineColor, NSColor.black)
        for Angle in stride(from: 0.0, to: 359.9, by: 90.0)
        {
            let X = FlatConstants.StencilRadius.rawValue * cos(Angle.Radians)
            let Y = FlatConstants.StencilRadius.rawValue * sin(Angle.Radians)
            let Line = NSBezierPath()
            LineColor.set()
            LineColor.setStroke()
            Line.lineWidth = CGFloat(FlatConstants.GridLineWidth.rawValue)
            Line.lineCapStyle = .round
            Line.move(to: NSPoint(x: FlatConstants.StencilRadius.rawValue,
                                  y: FlatConstants.StencilRadius.rawValue))
            Line.line(to: NSPoint(x: X + FlatConstants.StencilRadius.rawValue,
                                  y: Y + FlatConstants.StencilRadius.rawValue))
            Line.stroke()
            Line.fill()
        }
        for Latitude in Latitudes.allCases
        {
            let Side = FlatConstants.StencilRadius.rawValue * 2.0 * Latitude.rawValue
            LineColor.set()
            LineColor.setStroke()
            let Container = NSRect(x: FlatConstants.StencilRadius.rawValue - Side / 2.0,
                                   y: FlatConstants.StencilRadius.rawValue - Side / 2.0,
                                   width: Side,
                                   height: Side)
            let Circle = NSBezierPath(ovalIn: Container)
            Circle.lineWidth = CGFloat(FlatConstants.GridLineWidth.rawValue)
            Circle.stroke()
        }
 
        Surface.unlockFocus()
        return Surface
    }
}
