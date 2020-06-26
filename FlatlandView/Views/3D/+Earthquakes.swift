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
    
    /// Plot earthquakes on the globe.
    func PlotEarthquakes2()
    {
        if let Earth = EarthNode
        {
            PlotEarthquakes2(EarthquakeList2, On: Earth)
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
        PlottedEarthquakes.removeAll()
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
        PlottedEarthquakes.removeAll()
        PlotEarthquakes()
    }
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Returns: True if the lists have equal contents, false if not.
    func SameEarthquakes2(_ List1: [Earthquake2], _ List2: [Earthquake2]) -> Bool
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
    func NewEarthquakeList2(_ NewList: [Earthquake2])
    {
        if SameEarthquakes2(NewList, EarthquakeList2)
        {
            print("No new earthquakes")
            return
        }
        EarthquakeList2.removeAll()
        EarthquakeList2 = Earthquake2.LargestList(NewList)
        PlottedEarthquakes.removeAll()
        //PlotEarthquakes2()
    }
    
    /// Plot a passed list of earthquakes on the passed surface.
    /// - Parameter List: The list of earthquakes to plot.
    /// - Parameter On: The 3D surface upon which to plot the earthquakes.
    func PlotEarthquakes(_ List: [Earthquake], On Surface: SCNNode)
    {
        #if true
        if Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self, Default: .None) == .None
        {
            return
        }
        #else
        if !Settings.GetBool(.EnableEarthquakes)
        {
            return
        }
        #endif
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
            if let QNode = MakeEarthquakeNode(Quake)
            {
                if Settings.GetBool(.HighlightRecentEarthquakes)
                {
                    let RecentDefinition = Settings.GetDouble(.RecentEarthquakeDefinition, 24.0 * 60.0 * 60.0)
                    if Quake.GetAge() <= RecentDefinition
                    {
                        let Ind = HighlightEarthquake(Quake)
                        Surface.addChildNode(Ind)
                    }
                }
                var BaseColor = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
                let AgeRange = Settings.GetEnum(ForKey: .EarthquakeAge, EnumType: EarthquakeAges.self, Default: .Age30)
                if !InAgeRange(Quake, InRange: AgeRange)
                {
                    continue
                }
                if Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere) == .Magnitude
                {
                    BaseColor = NSColor.red
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
                            let Colors = Settings.GetMagnitudeColors()
                            for (Magnitude, Color) in Colors
                            {
                                if Magnitude == MagRange
                                {
                                    BaseColor = Color
                                }
                            }
                            
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
                if Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere) == .Arrow
                {
                    if let ANode = QNode as? SCNSimpleArrow
                    {
                        ANode.Color = BaseColor
                    }
                }
                else
                {
                    QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
                }
                Surface.addChildNode(QNode)
            }
        }
    }
    
    /// Plot a passed list of earthquakes on the passed surface.
    /// - Parameter List: The list of earthquakes to plot.
    /// - Parameter On: The 3D surface upon which to plot the earthquakes.
    func PlotEarthquakes2(_ List: [Earthquake2], On Surface: SCNNode)
    {
        #if true
        if Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self, Default: .None) == .None
        {
            return
        }
        #else
        if !Settings.GetBool(.EnableEarthquakes)
        {
            return
        }
        #endif
        print("Plotting \(List.count) earthquakes!!!!")
        let Oldest = OldestEarthquakeOccurence2(List)
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
            let QNode = MakeEarthquakeNode2(Quake)
            var BaseColor = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
            let AgeRange = Settings.GetEnum(ForKey: .EarthquakeAge, EnumType: EarthquakeAges.self, Default: .Age30)
            if !InAgeRange2(Quake, InRange: AgeRange)
            {
                continue
            }
            if Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere) == .Magnitude
            {
                BaseColor = NSColor.red
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
                        let Percent = CGFloat(Quake.GreatestMagnitude) / 10.0
                        BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                        
                    case .MagnitudeRange:
                        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
                        BaseColor = MagnitudeColors[MagRange.rawValue]!
                        
                    case .Population:
                        let ClosestPopulation = PopulationOfClosestCity2(To: Quake)
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
                            let Percent = CGFloat(Quake.GreatestMagnitude) / 10.0
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
            if Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere) == .Arrow
            {
                if let ANode = QNode as? SCNSimpleArrow
                {
                    ANode.Color = BaseColor
                }
            }
            else
            {
                QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
            }
            Surface.addChildNode(QNode)
        }
    }
    
    /// Create a shape for the passed earthquake.
    /// - Parameter Quake: The earthquake whose shape will be created.
    /// - Returns: `SCNNode` to be used to mark the earthquake.
    func MakeEarthquakeNode(_ Quake: Earthquake) -> SCNNode?
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
                #if false
                FinalNode = PlotMagnitudes2Y(Quake)
                FinalNode.name = "EarthquakeNode"
                return FinalNode
                return nil
                #else
                FinalNode = PlotMagnitudes(Quake)
                FinalNode.name = "EarthquakeNode"
                return FinalNode
                #endif
                
            case .Arrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: 2.0, Width: 0.85, Extrusion: 0.2,
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red))
                Arrow.LightMask = SunMask | MoonMask
                Arrow.scale = SCNVector3(0.75, 0.75, 0.75)
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let Rotate = SCNAction.rotateBy(x: 0.0, y: 1.0, z: 0.0, duration: 1.0)
                let RotateForever = SCNAction.repeatForever(Rotate)
                
                let BounceDistance: CGFloat = 0.5
                let BounceDuration = 1.0
                let BounceAway = SCNAction.move(by: SCNVector3(0.0, -BounceDistance, 0.0), duration: BounceDuration)
                BounceAway.timingMode = .easeOut
                let BounceTo = SCNAction.move(by: SCNVector3(0.0, BounceDistance, 0.0), duration: BounceDuration)
                BounceTo.timingMode = .easeIn
                let BounceSequence = SCNAction.sequence([BounceAway, BounceTo])
                let MoveForever = SCNAction.repeatForever(BounceSequence)
                
                let AnimationGroup = SCNAction.group([MoveForever, RotateForever])
                Arrow.runAction(AnimationGroup)
                Arrow.runAction(RotateForever)
                #if false
                FinalNode = Arrow
                #else
                let Encapsulate = SCNNode()
                Encapsulate.addChildNode(Arrow)
                FinalNode = Encapsulate
                #endif
                
            case .Pyramid:
                FinalNode = SCNNode(geometry: SCNPyramid(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5))
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Box:
                FinalNode = SCNNode(geometry: SCNBox(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5, chamferRadius: 0.1))
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cylinder:
                FinalNode = SCNNode(geometry: SCNCylinder(radius: CGFloat(Percent * 0.25), height: CGFloat(2.5 * Percent)))
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Capsule:
                FinalNode = SCNNode(geometry: SCNCapsule(capRadius: CGFloat(Percent * 0.25), height: CGFloat(2.5 * Percent)))
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
    
    /// Create a shape for the passed earthquake.
    /// - Parameter Quake: The earthquake whose shape will be created.
    /// - Returns: `SCNNode` to be used to mark the earthquake.
    func MakeEarthquakeNode2(_ Quake: Earthquake2) -> SCNNode
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
                FinalNode = PlotMagnitudes2(Quake)
                FinalNode.name = "EarthquakeNode"
                return FinalNode
                
            case .Arrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: 2.0, Width: 0.85, Extrusion: 0.2,
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red))
                Arrow.LightMask = SunMask | MoonMask
                Arrow.scale = SCNVector3(0.75, 0.75, 0.75)
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
                
                //let AnimationGroup = SCNAction.group([MoveForever, RotateForever])
                //Arrow.runAction(AnimationGroup)
                //Arrow.runAction(RotateForever)
                
                let EncapsulatedArrow = SCNNode()
                EncapsulatedArrow.addChildNode(EncapsulatedArrow)
                FinalNode = EncapsulatedArrow//Arrow
                
            case .Pyramid:
                FinalNode = SCNNode(geometry: SCNPyramid(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5))
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Box:
                FinalNode = SCNNode(geometry: SCNBox(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5, chamferRadius: 0.1))
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cylinder:
                FinalNode = SCNNode(geometry: SCNCylinder(radius: CGFloat(Percent * 0.25), height: CGFloat(2.5 * Percent)))
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Capsule:
                FinalNode = SCNNode(geometry: SCNCapsule(capRadius: CGFloat(Percent * 0.25), height: CGFloat(2.5 * Percent)))
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
    
    /// Determines if a given earthquake happened in the number of days prior to the instance.
    /// - Parameter Quake: The earthquake to test against `InRange`.
    /// - Parameter InRange: The range of allowable earthquakes.
    /// - Returns: True if `Quake` is within the age range specified by `InRange`, false if not.
    func InAgeRange2(_ Quake: Earthquake2, InRange: EarthquakeAges) -> Bool
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
    
    /// Returns the ages in seconds of the oldest earthquake in the list.
    /// - Parameter InList: The list of earthquakes to seach.
    /// - Returns: The age of the oldest earthquake in seconds.
    func OldestEarthquakeOccurence2(_ InList: [Earthquake2]) -> Double
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
    
    /// Returns the population of the closest city to the passed earthquake.
    /// - Parameter To: The earthquake whose closest city's population will be returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is returned.
    /// - Returns: The population of the closest earthquake to the passed city. If no population is
    ///            available (eg, the city does not have a listed population or there are no cities
    ///            being plotted), `0` is returned.
    func PopulationOfClosestCity2(To Quake: Earthquake2, UseMetroPopulation: Bool = true) -> Int
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
    
    func PlotMagnitudes2X(_ Quake: Earthquake, On Parent: SCNNode)
    {
        if PlottedEarthquakes.contains(Quake.Code)
        {
            return
        }
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        var MultipleQuakesSign = ""
        if Quake.Related != nil
        {
            MultipleQuakesSign = "+"
        }
        let Magnitude = "• M\(Quake.Magnitude.RoundedTo(2))\(MultipleQuakesSign)"
        let FontSize = CGFloat(15.0 + Quake.Magnitude)
        let EqFont = NSFont(name: "Avenir-Heavy", size: FontSize)
        Utility.MakeFloatingWord(Radius: Radius, Word: Magnitude, Scale: 0.03,
                                 Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                 Extrusion: CGFloat(Quake.Magnitude),
                                 Mask: MetalSunMask | MetalMoonMask,
                                 TextFont: EqFont,
                                 TextColor: NSColor.red, OnSurface: Parent)
        PlottedEarthquakes.insert(Quake.Code)
    }
    
    func NodesWithName(_ Name: String, In Parent: SCNNode) -> Int
    {
        var Count = 0
        for Child in Parent.childNodes
        {
            if Child.name == Name
            {
                Count = Count + 1
            }
        }
        return Count
    }
    
    func PlotMagnitudes2Y(_ Quake: Earthquake) -> SCNNode
    {
        let NodeCount = NodesWithName("EarthquakeNode", In: EarthNode!)
        print("Plotting magnitudes [\(NodeCount)]")
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        var MultipleQuakesSign = ""
        if Quake.Related != nil
        {
            MultipleQuakesSign = "+"
        }
        let Magnitude = "• M\(Quake.Magnitude.RoundedTo(2))\(MultipleQuakesSign)"
        let FontSize = CGFloat(15.0 + Quake.Magnitude)
        let EqFont = NSFont(name: "Avenir-Heavy", size: FontSize)
        let Final = Utility.MakeFloatingWord(Radius: Radius, Word: Magnitude, Scale: 0.03,
                                             Latitude: Quake.Latitude, Longitude: Quake.Longitude,
                                             Extrusion: CGFloat(Quake.Magnitude),
                                             Mask: MetalSunMask | MetalMoonMask,
                                             TextFont: EqFont, TextColor: NSColor.red)
        Final.name = "EarthquakeNode"
        return Final
    }
    
    /// Plot earthquakes as text indicating the magnitude of the earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Returns: Node with extruded text indicating the earthquake.
    func PlotMagnitudes(_ Quake: Earthquake) -> SCNNode
    {
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        var MultipleQuakesSign = ""
        if Quake.Related != nil
        {
            MultipleQuakesSign = "+"
        }
        let Magnitude = "• M\(Quake.Magnitude.RoundedTo(2))\(MultipleQuakesSign)"
        let MagText = SCNText(string: Magnitude, extrusionDepth: CGFloat(Quake.Magnitude))
        let FontSize = CGFloat(15.0 + Quake.Magnitude)
        MagText.font = NSFont(name: "Avenir-Heavy", size: FontSize)
        #if true
        let (X, Y, Z) = Utility.ToECEF(Quake.Latitude, Quake.Longitude,
                                       LatitudeOffset: -1.0, LongitudeOffset: -0.5,
                                       Radius: Radius)
        #else
        let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude,
                               Radius: Radius)
        #endif
        MagText.firstMaterial?.diffuse.contents = NSColor.red
        MagText.firstMaterial?.specular.contents = NSColor.white
        MagText.firstMaterial?.lightingModel = .physicallyBased
        let MagNode = SCNNode(geometry: MagText)
        MagNode.categoryBitMask = MetalSunMask | MetalMoonMask
        MagNode.scale = SCNVector3(0.03, 0.03, 0.03)
        MagNode.name = "EarthquakeNode"
        MagNode.position = SCNVector3(X, Y, Z)
        
        let YRotation = -Quake.Latitude
        let XRotation = Quake.Longitude
        let ZRotation = 0.0
        MagNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        
        return MagNode
    }
    
    /// Plot earthquakes as text indicating the magnitude of the earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Returns: Node with extruded text indicating the earthquake.
    func PlotMagnitudes2(_ Quake: Earthquake2) -> SCNNode
    {
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        var MultipleQuakesSign = ""
        if Quake.IsCluster
        {
            MultipleQuakesSign = "+"
        }
        let Magnitude = "• M\(Quake.Magnitude.RoundedTo(2))\(MultipleQuakesSign)"
        let MagText = SCNText(string: Magnitude, extrusionDepth: CGFloat(Quake.Magnitude))
        let FontSize = CGFloat(15.0 + Quake.Magnitude)
        MagText.font = NSFont(name: "Avenir-Heavy", size: FontSize)
        let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
        MagText.firstMaterial?.diffuse.contents = NSColor.red
        MagText.firstMaterial?.specular.contents = NSColor.white
        MagText.firstMaterial?.lightingModel = .physicallyBased
        let MagNode = SCNNode(geometry: MagText)
        MagNode.categoryBitMask = MetalSunMask | MetalMoonMask
        MagNode.scale = SCNVector3(0.03, 0.03, 0.03)
        MagNode.name = "EarthquakeNode"
        MagNode.position = SCNVector3(X, Y, Z)
        
        let YRotation = -Quake.Latitude
        let XRotation = Quake.Longitude
        let ZRotation = 0.0
        MagNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        
        return MagNode
    }
    
    /// Visually highlight the passed earthquake.
    /// - Parameter Quake: The earthquake to highlight.
    /// - Returns: An `SCNNode` to be used as an indicator of a recent earthquake.
    func HighlightEarthquake(_ Quake: Earthquake) -> SCNNode
    {
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
        let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
        let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.1)
        let Indicator = SCNNode(geometry: IndicatorShape)
        Indicator.geometry?.firstMaterial?.diffuse.contents = NSImage(named: "RedCheckerboardTextureTransparent") //EarthquakeHighlight2")
        Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
        Indicator.categoryBitMask = MetalSunMask | MetalMoonMask
        
        let Rotate = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                        y: CGFloat(360.0.Radians),
                                        z: CGFloat(0.0.Radians),
                                        duration: 1.0)
        let ScaleDuration = 1.0 - (Quake.Magnitude / 10.0)
        let ToScale = 1.2 + (0.3 * (1.0 - (Quake.Magnitude / 10.0)))
        let ScaleUp = SCNAction.scale(to: CGFloat(ToScale), duration: 1.0 + ScaleDuration)
        let ScaleDown = SCNAction.scale(to: 1.0, duration: 1.0 + ScaleDuration)
        let ScaleGroup = SCNAction.sequence([ScaleUp, ScaleDown])
        let ScaleForever = SCNAction.repeatForever(ScaleGroup)
        Indicator.runAction(ScaleForever)
        let Forever = SCNAction.repeatForever(Rotate)
        Indicator.runAction(Forever)
        let Final = SCNNode()
        let YRotation = Quake.Latitude + 90.0
        let XRotation = Quake.Longitude + 180.0
        let ZRotation = 0.0
        Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        Final.position = SCNVector3(X, Y, Z)
        Final.addChildNode(Indicator)
        Final.name = "EarthquakeNode"
        return Final
    }
}
