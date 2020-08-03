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
        #if true
        Quakes2D = Quakes
        #else
        Quakes2D = USGS.CombineEarthquakes(Quakes, Closeness: 500.0)
        #endif
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
        
        let AgeRange = Settings.GetEnum(ForKey: .EarthquakeAge, EnumType: EarthquakeAges.self, Default: .Age30)
        for Quake in Quakes2D
        {
            if !InAgeRange(Quake, InRange: AgeRange)
            {
                continue
            }
            let PlottedEarthquake = PlotEarthquake(Quake: Quake, MapDiameter: LEarthquakeLayer.bounds.width)
            PlottedEarthquake.name = LayerNames.Earthquake.rawValue
            LEarthquakeLayer.addSublayer(PlottedEarthquake)
        }
        
        let Rotation = CATransform3DMakeRotation(CGFloat(-RadialTime), 0.0, 0.0, 1.0)
        LEarthquakeLayer.transform = Rotation
        
        CityView2D.layer!.addSublayer(LEarthquakeLayer)
    }
    
    /// Determines if a given earthquake happened in the number of days prior to the instance.
    /// - Parameter Quake: The earthquake to test against `InRange`.
    /// - Parameter InRange: The range of allowable earthquakes.
    /// - Returns: True if `Quake` is within the age range specified by `InRange`, false if not.
    func InAgeRange(_ Quake: Earthquake, InRange: EarthquakeAges) -> Bool
    {
        let Index = EarthquakeAges.allCases.firstIndex(of: InRange)! + 1
        let Seconds = Index * (60 * 60 * 24)
        let Delta = Date().timeIntervalSinceReferenceDate - Quake.Time.timeIntervalSinceReferenceDate
        return Int(Delta) < Seconds
    }
    
    func PlotEarthquake(Quake: Earthquake, MapDiameter: CGFloat) -> CAShapeLayer
    {
        let HighlightHow = Settings.GetEnum(ForKey: .Earthquake2DStyles, EnumType: EarthquakeIndicators2D.self,
                                            Default: .None)
        let Half = Double(MapDiameter / 2.0)
        var BaseSize = 8.0
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
        
        var BaseColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.Magnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                BaseColor = Color
            }
        }
        Layer.zPosition = CGFloat(Quake.Magnitude)
        Layer.fillColor = BaseColor.withAlphaComponent(0.75).cgColor
        if Quake.IsCluster
        {
            #if true
            let SColor = BaseColor.Darker(By: 0.75).withAlphaComponent(0.75)
            Layer.strokeColor = SColor.cgColor
            #else
            Layer.strokeColor = NSColor.magenta.withAlphaComponent(0.75).cgColor
            #endif
            Layer.lineWidth = 2.0
        }
        else
        {
            Layer.strokeColor = NSColor.black.withAlphaComponent(0.75).cgColor
            Layer.lineWidth = 1.0
        }
        Layer.path = Location.cgPath
        
        if HighlightHow != .None
        {
            let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                             Default: .Day1)
            let RecentSeconds = RecentMap[HowRecent]!
            if Quake.GetAge() <= RecentSeconds
            {
                switch HighlightHow
                {
                    case .Ring:
                        let PointXI = PointX - BaseSize
                        let PointYI = PointY - BaseSize
                        let IndLayer = CAShapeLayer()
                        IndLayer.frame = FlatViewMainImage.bounds
                        IndLayer.bounds = FlatViewMainImage.bounds
                        IndLayer.backgroundColor = NSColor.clear.cgColor
                        IndLayer.zPosition = Layer.zPosition - 0.01
                        let RingRect = NSRect(x: PointXI, y: PointYI, width: BaseSize * 2.0, height: BaseSize * 2.0)
                        let Ring = CGPath(ellipseIn: RingRect, transform: nil)
                        IndLayer.strokeColor = NSColor.red.withAlphaComponent(0.85).cgColor
                        IndLayer.lineWidth = 2.5
                        IndLayer.fillColor = NSColor.clear.cgColor
                        IndLayer.path = Ring
                        Layer.addSublayer(IndLayer)
                        
                    case .None:
                        break
                }
            }
        }
        
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
