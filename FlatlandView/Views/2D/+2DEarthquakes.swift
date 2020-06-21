//
//  +2DEarthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainView
{
    /// Remove 2D earthquakes from the 2D view.
    func Remove2DEarthquakes()
    {
        if let SubLayers = CityView2D.layer?.sublayers
        {
        for Layer in SubLayers
        {
            if Layer.name == LayerNames.Earthquakes.rawValue
            {
                Layer.removeAllAnimations()
                Layer.removeFromSuperlayer()
            }
        }
        }
    }
    
    func Plot2DEarthquakes(_ Quakes: [Earthquake], Replot: Bool = false)
    {
        let Now = GetUTC()
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TimeZone(abbreviation: "UTC")!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(24 * 60 * 60)

        var FinalOffset = 0.0
        var Multiplier = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            FinalOffset = 180.0
            Multiplier = 1.0
        }
        let Radians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
        PlotEarthquakes(Quakes, RadialTime: Radians, Replot: Replot)
    }
    
    func PlotEarthquakes(_ Quakes: [Earthquake], RadialTime: Double, Replot: Bool = false)
    {
        if Quakes.isEmpty
        {
            return
        }
        if !Replot
        {
        if SameEarthquakes(Quakes, PreviousEarthquakes)
        {
            return
        }
        }
        PreviousEarthquakes = Quakes
        for Child in CityView2D.layer!.sublayers!
        {
            if Child.name == LayerNames.Earthquakes.rawValue
            {
                Child.removeFromSuperlayer()
            }
        }
        let LEarthquakeLayer = CAShapeLayer()
        LEarthquakeLayer.backgroundColor = NSColor.clear.cgColor
        LEarthquakeLayer.zPosition = CGFloat(LayerZLevels.EarthquakeLayer.rawValue)
        LEarthquakeLayer.name = LayerNames.Earthquakes.rawValue
        LEarthquakeLayer.bounds = FlatViewMainImage.bounds
        LEarthquakeLayer.frame = FlatViewMainImage.bounds
        
        for Quake in Quakes
        {
            let PlottedEarthquake = PlotEarthquake(Quake: Quake, MapDiameter: LEarthquakeLayer.bounds.width)
            PlottedEarthquake.name = LayerNames.Earthquake.rawValue
            LEarthquakeLayer.addSublayer(PlottedEarthquake)
        }
        
        let Rotation = CATransform3DMakeRotation(CGFloat(-RadialTime), 0.0, 0.0, 1.0)
        LEarthquakeLayer.transform = Rotation
        
        CityView2D.layer!.addSublayer(LEarthquakeLayer)
    }
    
    func PlotEarthquake(Quake: Earthquake, MapDiameter: CGFloat) -> CAShapeLayer
    {
        let Half = Double(MapDiameter / 2.0)
        var BaseSize = 5.0
        BaseSize = BaseSize + (2.0 * (Quake.Magnitude / 5.0))
        let BearingOffset = 180.0
        let Ratio: Double = Half / HalfCircumference
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = DistanceFromContextPole(To: GeoPoint2(Quake.Latitude, Quake.Longitude))
        Distance = Distance * Ratio
        let PointModifier = Double(CGFloat(Half) - CGFloat(BaseSize / 2.0))
        var LocationBearing = Bearing(Start: GeoPoint2(90.0, 0.0), End: GeoPoint2(Quake.Latitude, Quake.Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).Radians
        let PointX = Distance * cos(LocationBearing) + PointModifier
        let PointY = Distance * sin(LocationBearing) + PointModifier
        let Location = SCNStar.StarPath(VertexCount: 9, Height: BaseSize, Base: BaseSize / 2.0,
                                        XOffset: CGFloat(PointX), YOffset: CGFloat(PointY))
        let Layer = CAShapeLayer()
        Layer.frame = FlatViewMainImage.bounds
        Layer.bounds = FlatViewMainImage.bounds
        Layer.backgroundColor = NSColor.clear.cgColor
        
        let MagnitudeColors: [Double: NSColor] =
            [
                //0 to 4.9
                EarthquakeMagnitudes.Mag4.rawValue: NSColor.ArtichokeGreen,
                //5 to 5.9
                EarthquakeMagnitudes.Mag5.rawValue: NSColor.TeaGreen,
                //6 to 6.9
                EarthquakeMagnitudes.Mag6.rawValue: NSColor.PacificBlue,
                //7 to 7.9
                EarthquakeMagnitudes.Mag7.rawValue: NSColor.UltraPink,
                //8 to 8.9
                EarthquakeMagnitudes.Mag8.rawValue: NSColor.Sunglow,
                // 9 to 10
                EarthquakeMagnitudes.Mag9.rawValue: NSColor.Scarlet
        ]
        
        let MagRange = GetMagnitudeRange(For: Quake.Magnitude)
        let BaseColor = MagnitudeColors[MagRange.rawValue]!
        Layer.zPosition = CGFloat(Quake.Magnitude)
        Layer.fillColor = BaseColor.cgColor
        Layer.strokeColor = NSColor.Maroon.cgColor
        Layer.lineWidth = 0.5
        Layer.path = Location.cgPath
        return Layer
    }
    
    /// Return a range enum for the passed earthquake magnitude.
    /// - Parameter For: The magnitude whose range will be returned.
    /// - Returns: Enum from `EarthquakeMagnitudes` that indicates it's range.
    func GetMagnitudeRange(For: Double) -> EarthquakeMagnitudes
    {
        let InitialValue = EarthquakeMagnitudes.allCases[0].rawValue
        let Modified = For - InitialValue
        if Modified < 0.0
        {
            return EarthquakeMagnitudes.allCases[0]
        }
        let IModified = Int(Modified)
        if IModified > EarthquakeMagnitudes.allCases.count - 1
        {
            return EarthquakeMagnitudes.allCases.last!
        }
        return EarthquakeMagnitudes.allCases[IModified]
    }
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Returns: True if the lists have equal contents, false if not.
    func SameEarthquakes(_ List1: [Earthquake], _ List2: [Earthquake]) -> Bool
    {
        if List1.count != List2.count
        {
            return false
        }
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        return SList1 == SList2
    }
}
