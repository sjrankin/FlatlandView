//
//  +RectangleEarthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RectangleView
{
    /// Add the earthquake layer. This layer is where all earthquake objects are placed.
    func AddEarthquakeLayer()
    {
        let Flat = SCNBox(width: CGFloat(RectMode.MapWidth.rawValue), height: CGFloat(RectMode.MapHeight.rawValue),
                          length: CGFloat(RectMode.MapDepth.rawValue), chamferRadius: 0.0)
        QuakePlane = SCNNode(geometry: Flat)
        QuakePlane.categoryBitMask = LightMasks3D.Sun.rawValue
        QuakePlane.name = NodeNames2D.EarthquakePlane.rawValue
        QuakePlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        QuakePlane.geometry?.firstMaterial?.isDoubleSided = true
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
        
        let Multiplier = -1.0
        let Radians = MakeRadialTime(From: Percent, With: 0.0) * Multiplier
        
        PlotEarthquakes(Quakes, RadialTime: Radians, Replot: Replot)
    }
    
    func PlotPrevious2DEarthquakes()
    {
        let Now = GetUTC()
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TimeZone(abbreviation: "UTC")!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(24 * 60 * 60)
        
            let Multiplier = -1.0
        let Radians = MakeRadialTime(From: Percent, With: 0.0) * Multiplier
        PlotPreviousEarthquakes(RadialTime: Radians)
    }
    
    func PlotPreviousEarthquakes(RadialTime: Double)
    {
        RemoveNodeWithName(NodeNames2D.Earthquake.rawValue, FromParent: QuakePlane)
        for Quake in Quakes2D
        {
            CommonQuakePlot(Quake: Quake, Radius: FlatConstants.FlatRadius.rawValue)
        }
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
        
        NodeTables.RemoveEarthquakes()
        for Quake in Quakes
        {
            NodeTables.AddEarthquake(Quake)
        }
        
        Quakes2D = Quakes
        PreviousEarthquakes = Quakes
        RemoveNodeWithName(NodeNames2D.Earthquake.rawValue, FromParent: QuakePlane)
        
        for Quake in Quakes2D
        {
            CommonQuakePlot(Quake: Quake, Radius: FlatConstants.FlatRadius.rawValue)
        }
    }
    
    /// Should be called by all functions that want to plot earthquakes in flat mode.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth.
    func CommonQuakePlot(Quake: Earthquake, Radius: Double)
    {
        let QuakeShape = Settings.GetEnum(ForKey: .EarthquakeShape2D, EnumType: QuakeShapes2D.self, Default: .Circle)
        var PlottedQuake = SCNNode2()
        switch QuakeShape
        {
            case .InvertedCone:
                PlottedQuake = PlotInvertedCone(Quake: Quake, Radius: Radius)
                
            case .SpikyCone:
                PlottedQuake = PlotSpikyCone(Quake: Quake, Radius: Radius)
                
            case .Cone:
                PlottedQuake = PlotInvertedCone(Quake: Quake, Radius: Radius, Invert: false)
                
            case .Pyramid:
                PlottedQuake = PlotPyramid(Quake: Quake, Radius: Radius)
                
            case .Circle:
                PlottedQuake = PlotEarthquakeCircle(Quake: Quake, Radius: Radius)
                
            case .Star:
                PlottedQuake = PlotEarthquakeStar(Quake: Quake, Radius: Radius)
        }
        PlottedQuake.NodeID = Quake.QuakeID
        PlottedQuake.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
        PlottedQuake.PropagateIDs()
        QuakePlane.addChildNode(PlottedQuake)
    }
    
    /// Plot one earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth where the earthquake will be displayed.
    /// - Returns: The earthquake node in the proper orientation and position.
    func PlotPyramid(Quake: Earthquake, Radius: Double, Invert: Bool = true) -> SCNNode2
    {
        let (PointX, PointY) = Geometry.PointFromGeo(Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                                    Width: RectMode.MapWidth.rawValue, Height: RectMode.MapHeight.rawValue)
        
        var BaseColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                BaseColor = Color
            }
        }
        
        let Pyramid = SCNPyramid(width: CGFloat(FlatConstants.MainEarthquakeNodeBase.rawValue),
                                 height: CGFloat(FlatConstants.MainEarthquakeNodeHeight.rawValue),
                                 length: CGFloat(FlatConstants.MainEarthquakeNodeBase.rawValue))
        Pyramid.firstMaterial?.diffuse.contents = BaseColor
        let ENode = SCNNode2(geometry: Pyramid)
        ENode.castsShadow = true
        ENode.name = NodeNames2D.Earthquake.rawValue
        ENode.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        if Invert
        {
            ENode.eulerAngles = SCNVector3(-90.0.Radians, 180.0.Radians, 0.0)
        }
        else
        {
            ENode.eulerAngles = SCNVector3(-90.0.Radians, 0.0, 0.0)
        }
        ENode.position = SCNVector3(PointX,
                                    PointY,
                                    0.0)
        return ENode
    }
    
    /// Plot one earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth where the earthquake will be displayed.
    /// - Returns: The earthquake node in the proper orientation and position.
    func PlotInvertedCone(Quake: Earthquake, Radius: Double, Invert: Bool = true) -> SCNNode2
    {
        let (PointX, PointY) = Geometry.PointFromGeo(Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                                    Width: RectMode.MapWidth.rawValue, Height: RectMode.MapHeight.rawValue)
        
        var BaseColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                BaseColor = Color
            }
        }
        
        let ConeHeight = CGFloat(FlatConstants.MainEarthquakeNodeHeight.rawValue)
        let CenterCone = SCNCone(topRadius: CGFloat(FlatConstants.MainEarthquakeNodeBase.rawValue),
                                 bottomRadius: 0.0,
                                 height: ConeHeight)
        CenterCone.firstMaterial?.diffuse.contents = BaseColor
        let ENode = SCNNode2(geometry: CenterCone)
        ENode.castsShadow = true
        ENode.name = NodeNames2D.Earthquake.rawValue
        ENode.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        if Invert
        {
            ENode.eulerAngles = SCNVector3(-90.0.Radians, 180.0.Radians, 0.0)
        }
        else
        {
            ENode.eulerAngles = SCNVector3(-90.0.Radians, 0.0, 0.0)
        }
        ENode.position = SCNVector3(PointX, PointY, 0.0 + Double(ConeHeight / 2.0))
        return ENode
    }
    
    /// Plot one earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth where the earthquake will be displayed.
    /// - Returns: The earthquake node in the proper orientation and position.
    func PlotEarthquakeCircle(Quake: Earthquake, Radius: Double) -> SCNNode2
    {
        let (PointX, PointY) = Geometry.PointFromGeo(Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                                    Width: RectMode.MapWidth.rawValue, Height: RectMode.MapHeight.rawValue)
        
        var BaseColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                BaseColor = Color
            }
        }
        
        let Circle = SCNCylinder(radius: 0.15, height: 0.1)
        Circle.firstMaterial?.diffuse.contents = BaseColor
        let ENode = SCNNode2(geometry: Circle)
        ENode.castsShadow = true
        ENode.name = NodeNames2D.Earthquake.rawValue
        ENode.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        ENode.eulerAngles = SCNVector3(-90.0.Radians, 180.0.Radians, 0.0)
        ENode.position = SCNVector3(PointX,
                                    PointY,
                                    0.0)
        return ENode
    }
    
    /// Plot a location as an extruded star.
    /// - Note: The size of the star is determined by the values in `FlatConstants`.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Radius: The radius of the flat Earth.
    /// - Parameter Scale: The scale of the shape.
    /// - Parameter WithColor: The color to use as the texture for the star.
    func PlotEarthquakeStar(Quake: Earthquake, Radius: Double) -> SCNNode2
    {
        let VCount = 3 + Int(Quake.GreatestMagnitude)
        let Star = SCNNode2(geometry: SCNStar.Geometry(VertexCount: VCount, Height: 7.0, Base: 3.5, ZHeight: 4.0))
        let Scale = 0.035
        Star.scale = SCNVector3(Scale, Scale, Scale)
        Star.castsShadow = true
        Star.name = NodeNames2D.Earthquake.rawValue
        Star.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        
        var BaseColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                BaseColor = Color
            }
        }
        
        Star.geometry?.firstMaterial?.diffuse.contents = BaseColor
        let SmallStar = SCNNode2(geometry: SCNStar.Geometry(VertexCount: VCount, Height: 5.0, Base: 2.5, ZHeight: 5.5))
        SmallStar.castsShadow = true
        SmallStar.name = NodeNames2D.Earthquake.rawValue
        SmallStar.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        let Opposite = BaseColor.OppositeColor()
        SmallStar.geometry?.firstMaterial?.diffuse.contents = Opposite
        Star.addChildNode(SmallStar)
        SmallStar.position = SCNVector3(0.0, 0.0, 0.0)

        let (PointX, PointY) = Geometry.PointFromGeo(Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                                    Width: RectMode.MapWidth.rawValue, Height: RectMode.MapHeight.rawValue)
        Star.position = SCNVector3(PointX, PointY, 0.0)//4.0 * Scale * 0.5)
        
        return Star
    }
    
    /// Plot one earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Parameter Radius: The radius of the flat Earth where the earthquake will be displayed.
    /// - Returns: The earthquake node in the proper orientation and position.
    func PlotSpikyCone(Quake: Earthquake, Radius: Double) -> SCNNode2
    {
        let (PointX, PointY) = Geometry.PointFromGeo(Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                                    Width: RectMode.MapWidth.rawValue, Height: RectMode.MapHeight.rawValue)
        
        var BaseColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
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
        
        let ENode = SCNNode2()
        ENode.castsShadow = true
        ENode.name = NodeNames2D.Earthquake.rawValue
        ENode.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        
        let CenterNode = SCNNode2(geometry: CenterCone)
        CenterNode.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        CenterNode.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
        ENode.addChildNode(CenterNode)
        
        let Node1 = SCNNode2(geometry: Cone1)
        Node1.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        Node1.position = SCNVector3(0.0, FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0)
        Node1.eulerAngles = SCNVector3(45.0.Radians, 0.0, 0.0)
        ENode.addChildNode(Node1)
        let Node2 = SCNNode2(geometry: Cone2)
        Node2.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        Node2.position = SCNVector3(0.0, -FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0)
        Node2.eulerAngles = SCNVector3(135.0.Radians, 0.0, 0.0)
        ENode.addChildNode(Node2)
        let Node3 = SCNNode2(geometry: Cone3)
        Node3.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        Node3.position = SCNVector3(-FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0, 0.0)
        Node3.eulerAngles = SCNVector3(45.0.Radians, 0.0, 90.0.Radians)
        ENode.addChildNode(Node3)
        let Node4 = SCNNode2(geometry: Cone4)
        Node4.categoryBitMask = LightMasks2D.Polar.rawValue | LightMasks2D.Sun.rawValue
        Node4.position = SCNVector3(FlatConstants.SubEarthquakeNodeShift.rawValue, 0.0, 0.0)
        Node4.eulerAngles = SCNVector3(135.0.Radians, 0.0, 90.0.Radians)
        ENode.addChildNode(Node4)
        let FinalZ = (FlatConstants.MainEarthquakeNodeHeight.rawValue / 2.0) * 0.7
        ENode.scale = SCNVector3(NodeScales2D.EarthquakeScale.rawValue)
        ENode.position = SCNVector3(PointX, PointY, FinalZ)
        ENode.eulerAngles = SCNVector3(0.0.Radians, 0.0.Radians, 90.0.Radians)
        ENode.RotateOnX = false
        ENode.RotateOnY = false
        ENode.RotateOnZ = true
        
        let Direction = Quake.Latitude >= 0.0 ? -1.0 : 1.0
        
        let Rotation = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat(360.0.Radians * Direction), duration: 5.0)
        let Forever = SCNAction.repeatForever(Rotation)
        ENode.runAction(Forever)
        
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
