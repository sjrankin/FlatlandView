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
    
    func Remove2DEarthquakes()
    {
        RemoveNodeWithName(NodeNames2D.Earthquake.rawValue, FromParent: QuakePlane)
    }
    
    func GetUTC() -> Date
    {
        return Date()
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
    
    func PlotEarthquakes(_ RawQuakes: [Earthquake], RadialTime: Double, Replot: Bool = false)
    {
        
    }
    
    func PlotEarthquake(Quake: Earthquake, MapDiameter: CGFloat) -> SCNNode
    {
        return SCNNode()
    }
    
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
