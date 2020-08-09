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
            #if false
            if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            {
                if let BaseMap = GlobalBaseMap
                {
                    AddAnnotation(To: BaseMap, With: EarthquakeList)
                    {
                        [self] NewMap in
                        ChangeEarthBaseMap(To: NewMap)
                    }
                }
            }
            #else
            if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            {
                UpdateStencils(EarthquakeList)
            }
            #endif
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
                if Node.name == GlobeNodeNames.EarthquakeNodes.rawValue ||
                    Node.name == GlobeNodeNames.IndicatorNode.rawValue
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
            }
            IndicatorAgeMap.removeAll()
        }
        UpdateStencils()
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
        
        let Set1 = Set<String>(List1.map{$0.Code})
        let Set2 = Set<String>(List2.map{$0.Code})
        let DeltaSet = Set1.subtracting(Set2)
        if DeltaSet.count > 0
        {
            print("DeltaSet.count=\(DeltaSet.count)")
            
        }
        
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        for Index in 0 ..< SList1.count
        {
            if SList1[Index].Code != SList2[Index].Code
            {
                for Idx in 0 ..< SList1.count
                {
                    print("SList1[\(Idx)]=\(SList1[Idx].Code), SList2[\(Idx)]=\(SList2[Idx].Code)")
                }
                return false
            }
        }
        return true
    }
    
    /// Called when a new list of earthquakes was obtained from the remote source.
    /// - Parameter NewList: New list of earthquakes. If the new list has the same contents as the
    ///                      previous list, no action is taken.
    func NewEarthquakeList(_ NewList: [Earthquake])
    {
        RemoveExpiredIndicators(NewList)
        let FilteredList = EarthquakeFilterer.FilterList(NewList)
        if FilteredList.count == 0
        {
            print("No earthquakes found.")
            return
        }
        print("Have \(FilteredList.count) earthquakes")
        if SameEarthquakes(FilteredList, EarthquakeList)
        {
            #if DEBUG
            print("No new earthquakes")
            #endif
            return
        }
        ClearEarthquakes()
        EarthquakeList.removeAll()
        EarthquakeList = FilteredList
        PlottedEarthquakes.removeAll()
        PlotEarthquakes()
    }
    
    /// Go through all current earthquakes and remove indicators for those earthquakes that are no longer
    /// "recent" (as defined by the user).
    /// - Parameter Quakes: The list of earthquakes to check for which indicators to remove.
    func RemoveExpiredIndicators(_ Quakes: [Earthquake])
    {
        let HighlightHow = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                            Default: .None)
        if HighlightHow == .None
        {
            for (_, Node) in IndicatorAgeMap
            {
                Node.removeAllActions()
                Node.removeFromParentNode()
            }
            IndicatorAgeMap.removeAll()
            return
        }
        else
        {
            let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                             Default: .Day1)
            for Quake in Quakes
            {
                if let RecentSeconds = RecentMap[HowRecent]
                {
                    if Quake.GetAge() > RecentSeconds
                    {
                        if let INode = IndicatorAgeMap[Quake.Code]
                        {
                            INode.removeAllActions()
                            INode.removeFromParentNode()
                            IndicatorAgeMap.removeValue(forKey: Quake.Code)
                        }
                    }
                }
            }
        }
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
            let (QShape, MagShape) = MakeEarthquakeNode(Quake)
//            if let QNode = MakeEarthquakeNode(Quake)
            if let QNode = QShape
            {
                var BaseColor = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
                //let AgeRange = Settings.GetEnum(ForKey: .EarthquakeAge, EnumType: EarthquakeAges.self, Default: .Age30)
                /*
                if !InAgeRange(Quake, InRange: AgeRange)
                {
                    continue
                }
 */
                
                let HighlightHow = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                                    Default: .None)
                if HighlightHow != .None
                {
                    let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                                     Default: .Day1)
                    if let RecentSeconds = RecentMap[HowRecent]
                    {
                        if Quake.GetAge() <= RecentSeconds
                        {
                            let Ind = HighlightEarthquake(Quake)
                            Ind.name = GlobeNodeNames.IndicatorNode.rawValue
                            Surface.addChildNode(Ind)
                        }
                    }
                }
                
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
                
                let Shape = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
                if  Shape == .Arrow || Shape == .StaticArrow
                {
                    if let ANode = QNode.childNodes.first as? SCNSimpleArrow
                    {
                        ANode.Color = BaseColor
                    }
                }
                else
                {
                    QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
                }
                
                if MagShape != nil
                {
                MagShape?.geometry?.firstMaterial?.diffuse.contents = BaseColor
                MagShape?.geometry?.firstMaterial?.specular.contents = NSColor.white
                Surface.addChildNode(MagShape!)
                }
                
                Surface.addChildNode(QNode)
            }
        }
    }
    
    /// Create a shape for the passed earthquake. Additionally, an extruded text shape may be returned.
    /// - Parameter Quake: The earthquake whose shape will be created.
    /// - Returns: Tuple of two `SCNNode`s. The first is a shape to be used to indicate an earthquake and the
    ///            second (which may not be present, depending on the value of `.EarthquakeMagnitudeViews`)
    ///            is extruded text with the value of the magntiude of the earthquake.
    func MakeEarthquakeNode(_ Quake: Earthquake) -> (Shape: SCNNode?, Magnitude: SCNNode?)
    {
        let QuakeRadius = 6371.0 - Quake.Depth
        let Percent = QuakeRadius / 6371.0
        let FinalRadius = Double(GlobeRadius.Primary.rawValue) * Percent
        var FinalNode: SCNNode!
        var YRotation: Double = 0.0
        var XRotation: Double = 0.0
        var RadialOffset: Double = 0.0
        
        var MagNode: SCNNode? = nil
        switch Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No)
        {
            case .No:
                break
                
            case .Horizontal:
                MagNode = PlotMagnitudes(Quake)
                MagNode?.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .Vertical:
                MagNode = PlotMagnitudes(Quake, Vertically: true)
                MagNode?.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .Stenciled:
                break
        }

        switch Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
        {
            case .Arrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: 2.0, Width: 0.85, Extrusion: 0.2,
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red))
                Arrow.LightMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                Arrow.scale = SCNVector3(NodeScales.ArrowScale.rawValue,
                                         NodeScales.ArrowScale.rawValue,
                                         NodeScales.ArrowScale.rawValue)
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
                
            case .StaticArrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: 2.0, Width: 0.85, Extrusion: 0.2,
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red))
                Arrow.LightMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                Arrow.scale = SCNVector3(NodeScales.StaticArrow.rawValue,
                                         NodeScales.StaticArrow.rawValue,
                                         NodeScales.StaticArrow.rawValue)
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let Encapsulate = SCNNode()
                Encapsulate.addChildNode(Arrow)
                FinalNode = Encapsulate
                
            case .Pyramid:
                FinalNode = SCNNode(geometry: SCNPyramid(width: 0.5, height: CGFloat(2.5 * Percent), length: 0.5))
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cone:
                FinalNode = SCNNode(geometry: SCNCone(topRadius: 0.0, bottomRadius: 0.5, height: CGFloat(3.5 * Percent)))
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
        FinalNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        FinalNode.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
        FinalNode.position = SCNVector3(X, Y, Z)
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        return (FinalNode, MagNode)
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
    
    /// Plot earthquakes as text indicating the magnitude of the earthquake.
    /// - Parameter Quake: The earthquake to plot.
    /// - Returns: Node with extruded text indicating the earthquake.
    func PlotMagnitudes(_ Quake: Earthquake, Vertically: Bool = false) -> SCNNode
    {
        let Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        #if false
        let Magnitude = "M\(Quake.Magnitude.RoundedTo(2))"
        #else
        let Magnitude = "• M\(Quake.Magnitude.RoundedTo(2))"
        #endif
        
        #if false
        //var YOffset = (MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) * NodeScales.EarthquakeText.rawValue
        //YOffset = MagNode.boundingBox.max.y * NodeScales.EarthquakeText.rawValue * 3.5
        //let XOffset = ((MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) / 2.0) * NodeScales.EarthquakeText.rawValue -
        //    (MagNode.boundingBox.min.y * NodeScales.EarthquakeText.rawValue)
        let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
        let FontSize = CGFloat(15.0 + Quake.Magnitude)
        let MagFont = NSFont(name: EqFont.PostscriptName, size: FontSize)
        let MagNodes = Utility.MakeFloatingWord2(Radius: Radius, Word: Magnitude, Scale: NodeScales.EarthquakeText.rawValue,
                                                 Latitude: Quake.Latitude, Longitude: Quake.Longitude, //LatitudeOffset: -YOffset,
                                                 /*LongitudeOffset: XOffset,*/ Extrusion: CGFloat(Quake.Magnitude),
                                                 Mask: MetalSunMask | MetalMoonMask, TextFont: MagFont, TextColor: NSColor.black,
                                                 TextSpecular: NSColor.white, IsMetallic: true)
        let MagNode = SCNNode()
        MagNode.position = SCNVector3(0.0, 0.0, 0.0)
        MagNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        MagNodes.forEach({MagNode.addChildNode($0)})
        #else
        let MagText = SCNText(string: Magnitude, extrusionDepth: CGFloat(Quake.Magnitude))
        let FontSize = CGFloat(15.0 + Quake.Magnitude)
        let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
        MagText.font = NSFont(name: EqFont.PostscriptName, size: FontSize)
        
        MagText.firstMaterial?.specular.contents = NSColor.black
        MagText.firstMaterial?.specular.contents = NSColor.white
        MagText.firstMaterial?.lightingModel = .physicallyBased
        let MagNode = SCNNode(geometry: MagText)
        MagNode.categoryBitMask = LightMasks.MetalSun.rawValue | LightMasks.MetalMoon.rawValue
        MagNode.scale = SCNVector3(NodeScales.EarthquakeText.rawValue,
                                   NodeScales.EarthquakeText.rawValue,
                                   NodeScales.EarthquakeText.rawValue)
        MagNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        var YOffset = (MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) * NodeScales.EarthquakeText.rawValue
        YOffset = MagNode.boundingBox.max.y * NodeScales.EarthquakeText.rawValue * 3.5
        let XOffset = ((MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) / 2.0) * NodeScales.EarthquakeText.rawValue -
            (MagNode.boundingBox.min.y * NodeScales.EarthquakeText.rawValue)
        let (X, Y, Z) = Utility.ToECEF(Quake.Latitude, Quake.Longitude,
                                       LatitudeOffset: Double(-YOffset), LongitudeOffset: Double(XOffset),
                                       Radius: Radius)
        MagNode.position = SCNVector3(X, Y, Z)
        #endif

        if Quake.IsCluster
        {
            let LowerShape = SCNBox(width: MagNode.boundingBox.max.x, height: 4.0, length: 1.0, chamferRadius: 0.0)
            let Lower = SCNNode(geometry: LowerShape)
            Lower.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
            Lower.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.CombinedEarthquakeColor, NSColor.systemRed)
            Lower.geometry?.firstMaterial?.specular.contents = NSColor.white
            let WidthOffset = MagNode.boundingBox.max.x / 2.0
            Lower.position = SCNVector3(MagNode.boundingBox.min.x + WidthOffset, 3.5, 0.0)
            MagNode.addChildNode(Lower)
            
            let UpperShape = SCNBox(width: MagNode.boundingBox.max.x, height: 4.0, length: 1.0, chamferRadius: 0.0)
            let Upper = SCNNode(geometry: UpperShape)
            Upper.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
            Upper.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.CombinedEarthquakeColor, NSColor.systemRed)
            Upper.geometry?.firstMaterial?.specular.contents = NSColor.white
            Upper.position = SCNVector3(MagNode.boundingBox.min.x + WidthOffset,
                                        MagNode.boundingBox.max.y + 3.5, 0.0)
            MagNode.addChildNode(Upper)
        }
        
        var YRotation = -Quake.Latitude
        var XRotation = Quake.Longitude
        var ZRotation = 0.0
        if Vertically
        {
            YRotation = Quake.Latitude //+ 90.0
            XRotation = Quake.Longitude + 270.0
            YRotation = 0.0
            //XRotation = 0.0
            ZRotation = 0.0
        }
        MagNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        
        return MagNode
    }
    
    /// Visually highlight the passed earthquake.
    /// - Note: If the indicator is already present, it is not redrawn.
    /// - Parameter Quake: The earthquake to highlight.
    /// - Returns: An `SCNNode` to be used as an indicator of a recent earthquake.
    func HighlightEarthquake(_ Quake: Earthquake) -> SCNNode
    {
        let Final = SCNNode()
        if IndicatorAgeMap[Quake.Code] != nil
        {
            return Final
        }
        let IndicatorType = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                             Default: .None)
        switch IndicatorType
        {
            case .AnimatedRing:
                let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
                let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.1)
                let Indicator = SCNNode(geometry: IndicatorShape)
                let TextureType = Settings.GetEnum(ForKey: .EarthquakeTextures, EnumType: EarthquakeTextures.self, Default: .Gradient1)
                guard let TextureName = TextureMap[TextureType] else
                {
                    fatalError("Error getting texture \(TextureType)")
                }
                if TextureName.isEmpty
                {
                    let SolidColor = Settings.GetColor(.EarthquakeColor, NSColor.red)
                    Indicator.geometry?.firstMaterial?.diffuse.contents = SolidColor
                }
                else
                {
                    Indicator.geometry?.firstMaterial?.diffuse.contents = NSImage(named: TextureName)
                }
                Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
                Indicator.categoryBitMask = LightMasks.MetalSun.rawValue | LightMasks.MetalMoon.rawValue
                
                let Rotate = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                                y: CGFloat(360.0.Radians),
                                                z: CGFloat(0.0.Radians),
                                                duration: 1.0)
                let ScaleDuration = 1.0 - (Quake.Magnitude / 10.0)
                var ToScale = (0.3 * (1.0 - (Quake.Magnitude / 10.0)))
                ToScale = ToScale + Double(NodeScales.AnimatedRingBase.rawValue)
                let ScaleUp = SCNAction.scale(to: CGFloat(ToScale), duration: 1.0 + ScaleDuration)
                let ScaleDown = SCNAction.scale(to: 1.0, duration: 1.0 + ScaleDuration)
                let ScaleGroup = SCNAction.sequence([ScaleUp, ScaleDown])
                let ScaleForever = SCNAction.repeatForever(ScaleGroup)
                Indicator.runAction(ScaleForever)
                let Forever = SCNAction.repeatForever(Rotate)
                Indicator.runAction(Forever)
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .StaticRing:
                let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
                let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.1)
                let Indicator = SCNNode(geometry: IndicatorShape)
                let StaticColor = Settings.GetColor(.EarthquakeColor, NSColor.red)
                Indicator.geometry?.firstMaterial?.diffuse.contents = StaticColor
                Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
                Indicator.categoryBitMask = LightMasks.MetalSun.rawValue | LightMasks.MetalMoon.rawValue
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .GlowingSphere:
                let Radius = Double(GlobeRadius.Primary.rawValue)
                let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNSphere(radius: 0.75)
                let Indicator = SCNNode(geometry: IndicatorShape)
                let Color = Settings.GetColor(.EarthquakeColor, NSColor.red).withAlphaComponent(0.45)
                Indicator.geometry?.firstMaterial?.diffuse.contents = Color
                Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
                Indicator.categoryBitMask = LightMasks.MetalSun.rawValue | LightMasks.MetalMoon.rawValue
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .RadiatingRings:
                let Radius = Double(GlobeRadius.Primary.rawValue)
                let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let IndicatorShape = SCNTorus(ringRadius: 0.9, pipeRadius: 0.15)
                let Indicator = SCNNode(geometry: IndicatorShape)
                let InitialAlpha: CGFloat = 0.8
                let TextureType = Settings.GetEnum(ForKey: .EarthquakeTextures, EnumType: EarthquakeTextures.self, Default: .Gradient1)
                guard let TextureName = TextureMap[TextureType] else
                {
                    fatalError("Error getting texture \(TextureType)")
                }
                if TextureName.isEmpty
                {
                    let SolidColor = Settings.GetColor(.EarthquakeColor, NSColor.red)
                    Indicator.geometry?.firstMaterial?.diffuse.contents = SolidColor.withAlphaComponent(InitialAlpha)
                }
                else
                {
                    Indicator.geometry?.firstMaterial?.diffuse.contents = NSImage(named: TextureName)
                }
                Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
                Indicator.geometry?.firstMaterial?.lightingModel = .physicallyBased
                Indicator.categoryBitMask = LightMasks.MetalSun.rawValue | LightMasks.MetalMoon.rawValue
                Indicator.scale = SCNVector3(NodeScales.RadiatingRings.rawValue,
                                             NodeScales.RadiatingRings.rawValue,
                                             NodeScales.RadiatingRings.rawValue)
                
                let ScaleDuration = 1.0 + (1.0 - (Quake.Magnitude / 10.0))
                let ToScale = Double(NodeScales.RadiatingRingBase.rawValue) + (0.3 * (1.0 - (Quake.Magnitude / 10.0)))
                let ScaleUp = SCNAction.scale(to: CGFloat(ToScale), duration: ScaleDuration)
                let FinalFade = SCNAction.fadeOut(duration: 0.1)
                let Wait2 = SCNAction.wait(duration: ScaleDuration - 0.1)
                let FadeSequence2 = SCNAction.sequence([Wait2, FinalFade])
                let Group = SCNAction.group([ScaleUp, FadeSequence2])
                let ResetAction = SCNAction.run
                {
                    Node in
                    Node.scale = SCNVector3(NodeScales.RadiatingRings.rawValue,
                                            NodeScales.RadiatingRings.rawValue,
                                            NodeScales.RadiatingRings.rawValue)
                    Node.opacity = InitialAlpha
                }
                let Sequence = SCNAction.sequence([Group, ResetAction])
                let Forever = SCNAction.repeatForever(Sequence)
                Indicator.runAction(Forever)
                
                let YRotation = Quake.Latitude + 90.0
                let XRotation = Quake.Longitude + 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(Indicator)
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .TriangleRingIn, .TriangleRingOut:
                let Radius = Double(GlobeRadius.Primary.rawValue) + 0.3
                let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radius)
                let InnerRadius: CGFloat = 0.8
                let OuterRadius: CGFloat = 1.6
                let TRing = SCNTriangleRing(Count: 13, Inner: InnerRadius, Outer: OuterRadius, Extrusion: 0.15,
                                            Mask: LightMasks.MetalSun.rawValue | LightMasks.MetalMoon.rawValue)
                TRing.PointsOut = IndicatorType == .TriangleRingOut ? true: false
                TRing.Color = Settings.GetColor(.EarthquakeColor, NSColor.red)
                TRing.TriangleRotationDuration = 10.0 - Quake.Magnitude + 2.0
                TRing.position = SCNVector3(0.0, -OuterRadius / 4.0, 0.0)
                TRing.scale = SCNVector3(NodeScales.TriangleRing.rawValue,
                                         NodeScales.TriangleRing.rawValue,
                                         NodeScales.TriangleRing.rawValue)

                let YRotation = Quake.Latitude
                let XRotation = Quake.Longitude - 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(TRing)
                
                let Rotate = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                                y: CGFloat(0.0.Radians),
                                                z: CGFloat(360.0.Radians),
                                                duration: 5.0)
                let Forever = SCNAction.repeatForever(Rotate)
                //let TB = TRing.boundingBox
                //print("TB.width=\(TB.max.x - TB.min.x), TB.height=\(TB.max.y - TB.min.y)")
                //print("Original pivot point: \(TRing.pivot)")
                //let XPivot: CGFloat = 0.5//1.0 / (TB.max.x - TB.min.x) * 0.25
                //let YPivot: CGFloat = 0.5//1.0 / (TB.max.y - TB.min.y) * 0.5
                //TRing.pivot = SCNMatrix4MakeTranslation(XPivot, YPivot, 0.0)
                //TRing.runAction(Forever)
                
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .None:
                return SCNNode()
        }
        
        if !IndicatorAgeMap.contains(where: {$0.key == Quake.Code})
        {
            IndicatorAgeMap[Quake.Code] = Final
        }
        return Final
    }
}
