//
//  +FlatViewEarthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    /// Add the earthquake layer. This layer is where all earthquake objects are placed.
    func AddEarthquakeLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        QuakePlane = SCNNode(geometry: Flat)
        QuakePlane.categoryBitMask = LightMasks3D.Sun.rawValue
        QuakePlane.name = NodeNames2D.EarthquakePlane.rawValue
        QuakePlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        QuakePlane.geometry?.firstMaterial?.isDoubleSided = true
        QuakePlane.scale = SCNVector3(1.0, 1.0, 1.0)
        QuakePlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        QuakePlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(QuakePlane)
    }
    
    /// Remove earthquake nodes from the "2D" view.
    func Remove2DEarthquakes()
    {
        RemoveNodeWithName(NodeNames2D.Earthquake.rawValue, FromParent: QuakePlane)
    }
    
    /// Returns the UTC date (which is just a normal `Date`).
    func GetUTC() -> Date
    {
        return Date()
    }
    
    /// Plot earthquakes on the "2D" view.
    /// - Parameter Quakes: Set of unfiltered quakes from the USGS. 
    /// - Parameter Replot: If false, all existing earthquakes are removed. If true, existing earthquakes are
    ///                     left in place as long as the set of filtered passed earthquakes is the same as
    ///                     the previous set.
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
    
    /// Plot earthquakes on the "2D" view.
    /// - Parameter RawQuakes: Set of unfiltered quakes from the USGS. This function will use user settings to
    ///                        filter the quakes before displaying them.
    /// - Parameter RadialTime: The current time as radians.
    /// - Parameter Replot: If false, all existing earthquakes are removed. If true, existing earthquakes are
    ///                     left in place as long as the set of filtered passed earthquakes is the same as
    ///                     the previous set.
    func PlotEarthquakes(_ RawQuakes: [Earthquake], RadialTime: Double, Replot: Bool = false)
    {
        let Quakes = EarthquakeFilterer.FilterList(RawQuakes)
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
        Quakes2D = Quakes
        PreviousEarthquakes = Quakes
        RemoveNodeWithName(NodeNames2D.Earthquake.rawValue, FromParent: QuakePlane)
        
        for Quake in Quakes2D
        {
            let PlottedQuake = PlotEarthquake(Quake: Quake, Radius: FlatConstants.FlatRadius.rawValue)
            QuakePlane.addChildNode(PlottedQuake)
        }
    }
    
    /// Plot one earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth where the earthquake will be displayed.
    /// - Returns: The earthquake node in the proper orientation and position.
    func PlotEarthquake(Quake: Earthquake, Radius: Double) -> SCNNode
    {
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Quake.Latitude, Quake.Longitude))
        let Ratio: Double = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Quake.Latitude, Quake.Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).Radians
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        
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
        
        let CenterCone = SCNCone(topRadius: CGFloat(FlatConstants.MainEarthquakeNodeBase.rawValue),
                                 bottomRadius: 0.0,
                                 height: CGFloat(FlatConstants.MainEarthquakeNodeHeight.rawValue))
        CenterCone.firstMaterial?.diffuse.contents = BaseColor
        let ENode = SCNNode(geometry: CenterCone)
        ENode.name = NodeNames2D.Earthquake.rawValue
        ENode.categoryBitMask = LightMasks2D.Polar.rawValue
        ENode.eulerAngles = SCNVector3(-90.0.Radians, 180.0.Radians, 0.0)
        ENode.position = SCNVector3(PointX,
                                    PointY,
                                    Double(FlatConstants.MainEarthquakeNodeHeight.rawValue) * 0.5 *
                                        Double(NodeScales2D.EarthquakeScale.rawValue))
        return ENode
    }
    
    /// Plot one earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth where the earthquake will be displayed.
    /// - Returns: The earthquake node in the proper orientation and position.
    func PlotEarthquake2(Quake: Earthquake, Radius: Double) -> SCNNode
    {
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Quake.Latitude, Quake.Longitude))
        let Ratio: Double = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Quake.Latitude, Quake.Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).Radians
        let PointX = Distance * cos(LocationBearing)// + PointModifier
        let PointY = Distance * sin(LocationBearing)// + PointModifier
        
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
        
        let CenterCone = SCNCone(topRadius: 0.0,
                                 bottomRadius: CGFloat(FlatConstants.MainEarthquakeNodeBase.rawValue),
                                 height: CGFloat(FlatConstants.MainEarthquakeNodeHeight.rawValue))
        CenterCone.firstMaterial?.diffuse.contents = BaseColor
        let Cone1 = SCNCone(topRadius: 0.0,
                            bottomRadius: 0.1,
                            height: 0.5)
        Cone1.firstMaterial?.diffuse.contents = BaseColor
        let Cone2 = SCNCone(topRadius: 0.0,
                            bottomRadius: CGFloat(FlatConstants.SubEarthquakeNodeBase.rawValue),
                            height: CGFloat(FlatConstants.SubEarthquakeNodeHeight.rawValue))
        Cone2.firstMaterial?.diffuse.contents = BaseColor
        let Cone3 = SCNCone(topRadius: 0.0,
                            bottomRadius: CGFloat(FlatConstants.SubEarthquakeNodeBase.rawValue),
                            height: CGFloat(FlatConstants.SubEarthquakeNodeHeight.rawValue))
        Cone3.firstMaterial?.diffuse.contents = BaseColor
        let Cone4 = SCNCone(topRadius: 0.0,
                            bottomRadius: CGFloat(FlatConstants.SubEarthquakeNodeBase.rawValue),
                            height: CGFloat(FlatConstants.SubEarthquakeNodeHeight.rawValue))
        Cone4.firstMaterial?.diffuse.contents = BaseColor
        
        let ENode = SCNNode()
        ENode.name = NodeNames2D.Earthquake.rawValue
        ENode.categoryBitMask = LightMasks2D.Polar.rawValue
        let CenterNode = SCNNode(geometry: CenterCone)
        CenterNode.categoryBitMask = LightMasks2D.Polar.rawValue
        CenterNode.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
        ENode.addChildNode(CenterNode)
        let Node1 = SCNNode(geometry: Cone1)
        Node1.categoryBitMask = LightMasks2D.Polar.rawValue
        Node1.position = SCNVector3(0.0, FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0)
        Node1.eulerAngles = SCNVector3(45.0.Radians, 0.0, 0.0)
        ENode.addChildNode(Node1)
        let Node2 = SCNNode(geometry: Cone2)
        Node2.categoryBitMask = LightMasks2D.Polar.rawValue
        Node2.position = SCNVector3(0.0, -FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0)
        Node2.eulerAngles = SCNVector3(135.0.Radians, 0.0, 0.0)
        ENode.addChildNode(Node2)
        let Node3 = SCNNode(geometry: Cone3)
        Node3.categoryBitMask = LightMasks2D.Polar.rawValue
        Node3.position = SCNVector3(-FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0, 0.0)
        Node3.eulerAngles = SCNVector3(45.0.Radians, 0.0, 90.0.Radians)
        ENode.addChildNode(Node3)
        let Node4 = SCNNode(geometry: Cone4)
        Node4.categoryBitMask = LightMasks2D.Polar.rawValue
        Node4.position = SCNVector3(FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0, 0.0)
        Node4.eulerAngles = SCNVector3(135.0.Radians, 0.0, 90.0.Radians)
        ENode.addChildNode(Node4)
        
        ENode.scale = SCNVector3(NodeScales2D.EarthquakeScale.rawValue)
        ENode.position = SCNVector3(PointX,
                                    PointY,
                                    Double(FlatConstants.MainEarthquakeNodeHeight.rawValue) * 0.5 *
                                        Double(NodeScales2D.EarthquakeScale.rawValue))
        
        return ENode
    }
    
    /// Determines if the passed earthquake is within the passed range of earthquake ages.
    /// - Parameter Quake: The earthquake to test against the passed age range.
    /// - Parameter InRange: The age range tested against `Quake`.
    /// - Returns: True if `Quake` is within the range of `InRange`, false if not.
    func InAgeRange(_ Quake: Earthquake, InRange: EarthquakeAges) -> Bool
    {
        let Index = EarthquakeAges.allCases.firstIndex(of: InRange)! + 1
        let Seconds = Index * (60 * 60 * 24)
        let Delta = Date().timeIntervalSinceReferenceDate - Quake.Time.timeIntervalSinceReferenceDate
        return Int(Delta) < Seconds
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
