//
//  +Earthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    /// Plot earthquakes on the globe.
    func PlotEarthquakes()
    {
        if let Earth = EarthNode
        {
            PlotEarthquakes(EarthquakeList, On: Earth)
        }
    }
    
    /// Remove all earthquake nodes from the globe.
    func ClearEarthquakes()
    {
        if let Earth = EarthNode
        {
            for Node in Earth.childNodes
            {
                if Node.name == "EarthquakeNode"
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
            }
        }
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
    
    /// Called when a new list of earthquakes was obtained from the remote source.
    /// - Parameter NewList: New list of earthquakes. If the new list has the same contents as the
    ///                      previous list, no action is taken.
    func NewEarthquakeList(_ NewList: [Earthquake])
    {
        if SameEarthquakes(NewList, EarthquakeList)
        {
            print("No new earthquakes")
            return
        }
        EarthquakeList.removeAll()
        EarthquakeList = NewList
        PlotEarthquakes()
    }
    
    /// Plot a passed list of earthquakes on the passed surface.
    /// - Parameter List: The list of earthquakes to plot.
    /// - Parameter On: The 3D surface upon which to plot the earthquakes.
    func PlotEarthquakes(_ List: [Earthquake], On Surface: SCNNode)
    {
        if !Settings.GetBool(.EnableEarthquakes)
        {
            return
        }
        print("Plotting \(List.count) earthquakes")
        let Oldest = OldestEarthquakeOccurence(List)
        let Biggest = Cities.MostPopulatedCityPopulation(In: CitiesToPlot, UseMetroPopulation: true)
        var MaxSignificance = 0
        for Quake in List
        {
            if Quake.Significance > MaxSignificance
            {
                MaxSignificance = Quake.Significance
            }
        }
        for Quake in List
        {
            let QNode = MakeEarthquakeNode(Quake)
            var BaseColor = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
            let AgeRange = Settings.GetEnum(ForKey: .EarthquakeAge, EnumType: EarthquakeAges.self, Default: .Age30)
            if !InAgeRange(Quake, InRange: AgeRange)
            {
                continue
            }
            if Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere) == .Magnitude
            {
                BaseColor = NSColor.red
                QNode.geometry?.firstMaterial?.emission.contents = NSColor.systemRed
            }
            else
            {
                QNode.geometry?.firstMaterial?.emission.contents = nil
            switch Settings.GetEnum(ForKey: .ColorDetermination, EnumType: EarthquakeColorMethods.self, Default: .Magnitude)
            {
                case .Age:
                    let QuakeAge = Quake.GetAge()
                    let Percent = CGFloat(QuakeAge / Oldest)
                    let (H, S, B) = BaseColor.HSB
                    BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                
                case .Magnitude:
                    let (H, S, B) = BaseColor.HSB
                    let Percent = CGFloat(Quake.Magnitude) / 10.0
                    BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                
                case .MagnitudeRange:
                    let MagRange = GetMagnitudeRange(For: Quake.Magnitude)
                    BaseColor = MagnitudeColors[MagRange.rawValue]!
                
                case .Population:
                    let ClosestPopulation = PopulationOfClosestCity(To: Quake)
                    if ClosestPopulation == 0 || Biggest == 0
                    {
                        BaseColor = BaseColor.withAlphaComponent(0.5)
                    }
                    else
                    {
                        if Biggest > 0
                        {
                            let Percent = ClosestPopulation / Biggest
                            let (H, S, B) = BaseColor.HSB
                            BaseColor = NSColor(hue: H, saturation: S, brightness: B * CGFloat(Percent), alpha: 0.5)
                        }
                }
                
                case .Significance:
                    let Significance = Quake.Significance
                    if Significance <= 0
                    {
                        let (H, S, B) = BaseColor.HSB
                        let Percent = CGFloat(Quake.Magnitude) / 10.0
                        BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                    }
                    else
                    {
                        let Percent = Significance / MaxSignificance
                        let (H, S, B) = NSColor.red.HSB
                        BaseColor = NSColor(hue: H, saturation: CGFloat(Percent) * S, brightness: B, alpha: 0.8)
                }
            }
            }
            QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
            Surface.addChildNode(QNode)
        }
    }
    
    /// Create a shape for the passed earthquake.
    /// - Parameter Quake: The earthquake whose shape will be created.
    /// - Returns: `SCNNode` to be used to mark the earthquake.
    func MakeEarthquakeNode(_ Quake: Earthquake) -> SCNNode
    {
        let QuakeRadius = 6371.0 - Quake.Depth
        let Percent = QuakeRadius / 6371.0
        let FinalRadius = Double(GlobeRadius.Primary.rawValue) * Percent
        var FinalNode: SCNNode!
        var YRotation: Double = 0.0
        var XRotation: Double = 0.0
        var RadialOffset: Double = 0.0
        switch Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
        {
            case .Magnitude:
                FinalNode = PlotMagnitudes(Quake)
            return FinalNode
            
            case .Arrow:
                RadialOffset = 0.7
                FinalNode = SCNSimpleArrow(Length: 2.0, Width: 0.85, Extrusion: 0.2,
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red))
                FinalNode.scale = SCNVector3(0.75, 0.75, 0.75)
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let Rotate = SCNAction.rotateBy(x: 0.0, y: 1.0, z: 0.0, duration: 0.25)
                let RotateForever = SCNAction.repeatForever(Rotate)
                
                let BounceDistance: CGFloat = 0.5
                let BounceDuration = 0.8
                let BounceAway = SCNAction.move(by: SCNVector3(0.0, -BounceDistance, 0.0), duration: BounceDuration)
                BounceAway.timingMode = .easeOut
                let BounceTo = SCNAction.move(by: SCNVector3(0.0, BounceDistance, 0.0), duration: BounceDuration)
                BounceTo.timingMode = .easeIn
                let BounceSequence = SCNAction.sequence([BounceAway, BounceTo])
                let MoveForever = SCNAction.repeatForever(BounceSequence)
                
                let AnimationGroup = SCNAction.group([MoveForever, RotateForever])
                FinalNode.runAction(AnimationGroup)
            
            case .Pyramid:
                FinalNode = SCNNode(geometry: SCNPyramid(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5))
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
            
            case .Box:
                FinalNode = SCNNode(geometry: SCNBox(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5, chamferRadius: 0.1))
                 YRotation = Quake.Latitude + 90.0
                 XRotation = Quake.Longitude + 180.0
                
            case .Sphere:
                let ERadius = Quake.Magnitude * 0.1
                let QSphere = SCNSphere(radius: CGFloat(ERadius))
                FinalNode = SCNNode(geometry: QSphere)
        }
        
                let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: FinalRadius + RadialOffset)
        FinalNode.name = "EarthquakeNode"
        FinalNode.categoryBitMask = SunMask | MoonMask
        FinalNode.position = SCNVector3(X, Y, Z)
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        return FinalNode
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
    
    /// Returns the ages in seconds of the oldest earthquake in the list.
    /// - Parameter InList: The list of earthquakes to seach.
    /// - Returns: The age of the oldest earthquake in seconds.
    func OldestEarthquakeOccurence(_ InList: [Earthquake]) -> Double
    {
        let Now = Date()
        var Oldest = Now
        for Quake in InList
        {
            if Quake.Time < Oldest
            {
                Oldest = Quake.Time
            }
        }
        return Now.timeIntervalSinceReferenceDate - Oldest.timeIntervalSinceReferenceDate
    }
    
    /// Returns the population of the closest city to the passed earthquake.
    /// - Parameter To: The earthquake whose closest city's population will be returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is returned.
    /// - Returns: The population of the closest earthquake to the passed city. If no population is
    ///            available (eg, the city does not have a listed population or there are no cities
    ///            being plotted), `0` is returned.
    func PopulationOfClosestCity(To Quake: Earthquake, UseMetroPopulation: Bool = true) -> Int
    {
        var ClosestCity: City? = nil
        var Distance: Double = Double.greatestFiniteMagnitude
        for SomeCity in CitiesToPlot
        {
            let (QX, QY, QZ) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let (CX, CY, CZ) = ToECEF(SomeCity.Latitude, SomeCity.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let PDistance = Utility.Distance3D(X1: QX, Y1: QY, Z1: QZ, X2: CX, Y2: CY, Z2: CZ)
            if PDistance < Distance
            {
                Distance = PDistance
                ClosestCity = SomeCity
            }
        }
        if let CloseCity = ClosestCity
        {
            return CloseCity.GetPopulation(UseMetroPopulation)
        }
        return 0
    }
    
    func PlotMagnitudes(_ Quake: Earthquake) -> SCNNode
    {
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        let Magnitude = "M\(Quake.Magnitude.RoundedTo(2))"
        let MagText = SCNText(string: Magnitude, extrusionDepth: 2.0)
        MagText.font = NSFont(name: "Avenir-Heavy", size: 20.0)
        let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
        MagText.firstMaterial?.diffuse.contents = NSColor.red
        MagText.firstMaterial?.specular.contents = NSColor.white
        let MagNode = SCNNode(geometry: MagText)
        MagNode.categoryBitMask = SunMask | MoonMask
        MagNode.scale = SCNVector3(0.03, 0.03, 0.03)
        MagNode.name = "EarthquakeNode"
        MagNode.position = SCNVector3(X, Y, Z)
        
        #if true
        let YRotation = Quake.Latitude
        let XRotation = Quake.Longitude + 180.0
        let ZRotation = 0.0
        #else
        let YRotation = -Quake.Latitude //+ 90.0
        let XRotation = Quake.Longitude //+ 180.0
        let ZRotation = 0.0
        #endif
        MagNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        
        //let TextRotation = (90.0 - Quake.Longitude).Radians
        //MagNode.eulerAngles = SCNVector3(0.0, TextRotation, 0.0)
        return MagNode
    }
}
