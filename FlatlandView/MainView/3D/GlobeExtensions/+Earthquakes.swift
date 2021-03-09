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
    /// - Parameter From: Name of the caller. Defaults to nil.
    /// - Parameter FromCache: If true, earthquakes are from the cache.
    /// - Parameter Final: Completion block called after plot functions have been called. Defaults to nil.
    func PlotEarthquakes(_ From: String? = nil, FromCache: Bool = false, _ Final: (() -> ())? = nil)
    {
        if let Earth = EarthNode
        {
            if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            {
                if let FromWhere = From
                {
                    print("Called from \(FromWhere)")
                }
                if let AlreadyDone = InitialStenciledMap
                {
                    ApplyEarthquakeStencils(InitialMap: AlreadyDone, Caller: #function)
                }
                else
                {
                    ApplyAllStencils(Caller: #function)
                }
            }
            MemoryDebug.Block("PlotEarthquakesCall")
            {
                self.PlotEarthquakes(self.EarthquakeList, IsCached: FromCache, On: Earth)
            }
            Final?()
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
                    Node.removeAllAnimations()
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                    Node.geometry = nil
                }
            }
            IndicatorAgeMap.removeAll()
        }
        PlottedEarthquakes.removeAll()
    }
    
    func GetDeltas(_ List1: [Earthquake], _ List2: [Earthquake]) -> [Earthquake]
    {
        let Set1 = Set<Earthquake>(List1.map{$0})
        let Set2 = Set<Earthquake>(List2.map{$0})
        let Difference = Array(Set1.subtracting(Set2))
        return Difference
    }
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Parameter Delta: The difference between `List1` and `List2`.
    /// - Returns: True if the lists have equal contents, false if not.
    func SameEarthquakes(_ List1: [Earthquake], _ List2: [Earthquake],
                         Delta: inout [Earthquake]) -> Bool
    {
        if List1.count != List2.count
        {
            return false
        }
        
        let Set1 = Set<String>(List1.map{$0.Code})
        let Set2 = Set<String>(List2.map{$0.Code})
        let DeltaSet = Set1.subtracting(Set2)
        
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        Delta = GetDeltas(SList1, SList2)
        for Index in 0 ..< SList1.count
        {
            if SList1[Index].Code != SList2[Index].Code
            {
                #if false
                for Idx in 0 ..< SList1.count
                {
                    print("SList1[\(Idx)]=\(SList1[Idx].Code), SList2[\(Idx)]=\(SList2[Idx].Code)")
                }
                #endif
                return false
            }
        }
        return true
    }
    
    /// Called when a new list of earthquakes was obtained from the remote source.
    /// - Parameter NewList: New list of earthquakes. If the new list has the same contents as the
    ///                      previous list, no action is taken.
    /// - Parameter FromCache: If true, the set of earthquakes is from the cache.
    /// - Parameter Final: Completion handler.
    func NewEarthquakeList(_ NewList: [Earthquake], FromCache: Bool = false, Final: (() -> ())? = nil)
    {
        RemoveExpiredIndicators(NewList)
        let FilteredList = EarthquakeFilterer.FilterList(NewList)
        if FilteredList.count == 0
        {
            return
        }
        var NewQuakes = [Earthquake]()
        if SameEarthquakes(FilteredList, EarthquakeList, Delta: &NewQuakes)
        {
            #if DEBUG
            //Debug.Print("No new earthquakes")
            #endif
            return
        }
        NewQuakes.sort(by: {$0.Magnitude > $1.Magnitude})
        if let Biggest = NewQuakes.max(by: {$0.Magnitude > $1.Magnitude})
        {
            MainDelegate?.PushStatusMessage("New quake: \(Biggest.Title)", PersistFor: 600.0)
        }
        ClearEarthquakes()
        EarthquakeList.removeAll()
        EarthquakeList = FilteredList
        PlottedEarthquakes.removeAll()
        PlotEarthquakes(#function, FromCache: FromCache, Final)
        
        Settings.CacheEarthquakes(EarthquakeList) 
        NodeTables.RemoveEarthquakes()
        for Quake in EarthquakeList
        {
            NodeTables.AddEarthquake(Quake)
        }
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
                Node.removeAllAnimations()
                Node.removeAllActions()
                Node.removeFromParentNode()
                Node.geometry = nil
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
                            INode.removeAllAnimations()
                            INode.removeAllActions()
                            INode.removeFromParentNode()
                            INode.geometry = nil
                            IndicatorAgeMap.removeValue(forKey: Quake.Code)
                        }
                    }
                }
            }
        }
    }
    
    /// Plot a passed list of earthquakes on the passed surface.
    /// - Parameter List: The list of earthquakes to plot.
    /// - Parameter IsCached: Flag that determines if the earthquakes are from the cache.
    /// - Parameter On: The 3D surface upon which to plot the earthquakes.
    func PlotEarthquakes(_ List: [Earthquake], IsCached: Bool = false, On Surface: SCNNode2)
    {
        if !Settings.GetBool(.EnableEarthquakes)
        {
            return
        }
        let Oldest = OldestEarthquakeOccurence(List)
        let Biggest = CityManager.MostPopulatedCityPopulation(In: CitiesToPlot, UseMetroPopulation: true)
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
            let (QShape, MagShape, InfoNode) = MakeEarthquakeNode(Quake, IsCached: IsCached)
            if let INode = InfoNode
            {
                Surface.addChildNode(INode)
            }
            if let QNode = QShape
            {
                var BaseColor = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
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
                        let Percent = CGFloat(Quake.GreatestMagnitude) / 10.0
                        BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                        
                    case .MagnitudeRange:
                        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
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
                
                let Shape = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
                #if true
                switch Shape
                {
                    case .Arrow, .StaticArrow:
                        if let ANode = QNode.childNodes.first as? SCNSimpleArrow
                        {
                            ANode.Color = BaseColor
                        }
                        
                    case .PulsatingSphere:
                        QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor.withAlphaComponent(0.6)
                        
                    default:
                        QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
                }
                #else
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
                #endif
                
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
    /// - Note: If extruded magnitude values are specified as the node, node shapes are not drawn - just the
    ///         extruded number.
    /// - Parameter Quake: The earthquake whose shape will be created.
    /// - Parameter IsCached: If true, the earthquake is from the cache.
    /// - Returns: Tuple of three `SCNNode2`s. The first is a shape to be used to indicate an earthquake and the
    ///            second (which may not be present, depending on the value of `.EarthquakeMagnitudeViews`)
    ///            is extruded text with the value of the magntiude of the earthquake. The third node is an
    ///            invisible info node to interact with the mouse.
    func MakeEarthquakeNode(_ Quake: Earthquake, IsCached: Bool = false) -> (Shape: SCNNode2?, Magnitude: SCNNode2?, InfoNode: SCNNode2?)
    {
        let FinalRadius = GlobeRadius.Primary.rawValue
        let Percent = 1.0
        var FinalNode: SCNNode2!
        var YRotation: Double = 0.0
        var XRotation: Double = 0.0
        var RadialOffset: Double = 0.5
        
        var ScaleMultiplier = 1.0
        switch Settings.GetEnum(ForKey: .QuakeScales, EnumType: MapNodeScales.self, Default: .Normal)
        {
            case .Small:
                ScaleMultiplier = 0.5
                
            case .Normal:
                ScaleMultiplier = 1.0
                
            case .Large:
                ScaleMultiplier = 1.5
        }
        
        var MagNode: SCNNode2? = nil
        switch Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No)
        {
            case .No:
                break
                
            case .Horizontal:
                MagNode = PlotMagnitudes(Quake)
                MagNode?.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                MagNode?.NodeID = Quake.QuakeID
                MagNode?.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .Vertical:
                MagNode = PlotMagnitudes(Quake, Vertically: true)
                MagNode?.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                MagNode?.NodeID = Quake.QuakeID
                MagNode?.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .Stenciled:
                break
        }
        
        let Radiusp = Double(FinalRadius) + RadialOffset - Quake3D.InvisibleEarthquakeOffset.rawValue
        let (Xp, Yp, Zp) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Radiusp)
        let ERadius = (Quake.GreatestMagnitude * Quake3D.SphereMultiplier.rawValue) * Quake3D.SphereConstant.rawValue
        let QSphere = SCNSphere(radius: CGFloat(ERadius))
        let InfoNode = SCNNode2(geometry: QSphere)
        InfoNode.CanShowBoundingShape = true
        InfoNode.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        InfoNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
        InfoNode.NodeID = Quake.QuakeID
        InfoNode.position = SCNVector3(Xp, Yp, Zp)
        var Addendum: SCNNode2? = nil
        
        switch Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
        {
            case .Arrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: CGFloat(Quake3D.ArrowLength.rawValue),
                                           Width: CGFloat(Quake3D.ArrowWidth.rawValue),
                                           Extrusion: CGFloat(Quake3D.ArrowExtrusion.rawValue),
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.systemYellow))
                Arrow.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                Arrow.NodeID = Quake.QuakeID
                Arrow.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                let FinalScale = NodeScales3D.ArrowScale.rawValue * CGFloat(ScaleMultiplier)
                Arrow.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                Arrow.CanSwitchState = true
                Arrow.SetLocation(Quake.Latitude, Quake.Longitude)
                if IsCached
                {
                    Arrow.SetState(ForDay: true, Color: NSColor.lightGray,
                                   Emission: nil, Model: .physicallyBased, Metalness: nil, Roughness: nil)
                    Arrow.SetState(ForDay: false, Color: NSColor.darkGray,
                                   Emission: NSColor.darkGray,
                                   Model: .physicallyBased, Metalness: nil, Roughness: nil)
                }
                else
                {
                    Arrow.SetState(ForDay: true, Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red),
                                   Emission: nil, Model: .physicallyBased, Metalness: nil, Roughness: nil)
                    Arrow.SetState(ForDay: false, Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.systemYellow),
                                   Emission: Settings.GetColor(.BaseEarthquakeColor, NSColor.orange),
                                   Model: .physicallyBased, Metalness: nil, Roughness: nil)
                }
                if let InDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    Arrow.IsInDaylight = InDay
                }
                
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let RotateDirection = Quake.Latitude >= 0.0 ? 1.0 : -1.0
                let Rotate = SCNAction.rotateBy(x: 0.0, y: CGFloat(RotateDirection), z: 0.0,
                                                duration: Quake3D.ArrowRotationDuration.rawValue)
                let RotateForever = SCNAction.repeatForever(Rotate)
                let BounceDistance: CGFloat = CGFloat(Quake3D.ArrowBounceDistance.rawValue)
                let BounceDuration = (10.0 - Quake.GreatestMagnitude) / Quake3D.ArrowBounceDurationDivisor.rawValue
                let BounceAway = SCNAction.move(by: SCNVector3(0.0, -BounceDistance, 0.0), duration: BounceDuration)
                BounceAway.timingMode = .easeOut
                let BounceTo = SCNAction.move(by: SCNVector3(0.0, BounceDistance, 0.0), duration: BounceDuration)
                BounceTo.timingMode = .easeIn
                let BounceSequence = SCNAction.sequence([BounceAway, BounceTo])
                let MoveForever = SCNAction.repeatForever(BounceSequence)
                let AnimationGroup = SCNAction.group([MoveForever, RotateForever])
                Arrow.runAction(AnimationGroup)
                Arrow.runAction(RotateForever)
                
                let Encapsulate = SCNNode2()
                Encapsulate.CanSwitchState = true
                Encapsulate.SetLocation(Quake.Latitude, Quake.Longitude)
                Encapsulate.addChildNode(Arrow)
                FinalNode = Encapsulate
                FinalNode.CanSwitchState = true
                FinalNode.SetLocation(Quake.Latitude, Quake.Longitude)
                if let IsInDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    FinalNode.IsInDaylight = IsInDay
                }
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)
                FinalNode.NodeID = Quake.QuakeID
                FinalNode.NodeUsage = .Earthquake
                
            case .StaticArrow:
                RadialOffset = 0.7
                let Arrow = SCNSimpleArrow(Length: CGFloat(Quake3D.StaticArrowLength.rawValue),
                                           Width: CGFloat(Quake3D.StaticArrowWidth.rawValue),
                                           Extrusion: CGFloat(Quake3D.StaticArrowExtrusion.rawValue),
                                           Color: Settings.GetColor(.BaseEarthquakeColor, NSColor.red))
                if IsCached
                {
                    Arrow.Color = NSColor.lightGray
                }
                Arrow.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                Arrow.NodeID = Quake.QuakeID
                Arrow.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                let FinalScale = NodeScales3D.StaticArrow.rawValue * CGFloat(ScaleMultiplier)
                Arrow.scale = SCNVector3(FinalScale,
                                         FinalScale,
                                         FinalScale)
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                let Encapsulate = SCNNode2()
                Encapsulate.addChildNode(Arrow)
                FinalNode = Encapsulate
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                
            case .Pyramid:
                RadialOffset = 0.0
                FinalNode = SCNNode2(geometry: SCNPyramid(width: CGFloat(Quake3D.PyramidWidth.rawValue),
                                                          height: CGFloat(Quake3D.PyramidHeightMultiplier.rawValue * Percent),
                                                          length: CGFloat(Quake3D.PyramidLength.rawValue)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                let FinalScale = NodeScales3D.PyramidEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cone:
                FinalNode = SCNNode2(geometry: SCNCone(topRadius: CGFloat(Quake3D.ConeTopRadius.rawValue),
                                                       bottomRadius: CGFloat(Quake3D.ConeBottomRadius.rawValue),
                                                       height: CGFloat(Quake3D.ConeHeightMultiplier.rawValue * Percent)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                let FinalScale = NodeScales3D.ConeEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0 + 180.0
                XRotation = Quake.Longitude + 180.0
                
            case .Box:
                FinalNode = SCNNode2(geometry: SCNBox(width: CGFloat(Quake3D.QuakeBoxWidth.rawValue),
                                                      height: CGFloat(Quake3D.QuakeBoxHeight.rawValue * Percent),
                                                      length: CGFloat(Quake3D.QuakeBoxLength.rawValue),
                                                      chamferRadius: CGFloat(Quake3D.QuakeBoxChamfer.rawValue)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                let FinalScale = NodeScales3D.BoxEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Cylinder:
                FinalNode = SCNNode2(geometry: SCNCylinder(radius: CGFloat(Percent * Quake3D.QuakeCapsuleRadius.rawValue),
                                                           height: CGFloat(Quake3D.QuakeCapsuleHeight.rawValue * Percent)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                let FinalScale = NodeScales3D.CylinderEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Capsule:
                FinalNode = SCNNode2(geometry: SCNCapsule(capRadius: CGFloat(Percent * Quake3D.QuakeCapsuleRadius.rawValue),
                                                          height: CGFloat(Quake3D.QuakeCapsuleHeight.rawValue * Percent)))
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                let FinalScale = NodeScales3D.CapsuleEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                
            case .Sphere:
                let ERadius = (Quake.GreatestMagnitude * Quake3D.SphereMultiplier.rawValue) * Quake3D.SphereConstant.rawValue
                let QSphere = SCNSphere(radius: CGFloat(ERadius))
                FinalNode = SCNNode2(geometry: QSphere)
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                let FinalScale = NodeScales3D.SphereEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                
            case .PulsatingSphere:
                let ERRadius = (Quake.GreatestMagnitude * Quake3D.SphereMultiplier.rawValue) * Quake3D.PulsatingSphereConstant.rawValue
                let ScaleDuration: Double = Quake3D.PulsatingBase.rawValue +
                    (10 - Quake.GreatestMagnitude) * Quake3D.MagnitudeMultiplier.rawValue
                let QSphere = SCNSphere(radius: CGFloat(ERRadius))
                let ScaleUp = SCNAction.scale(to: CGFloat(Quake3D.PulsatingSphereMaxScale.rawValue), duration: ScaleDuration)
                let ScaleDown = SCNAction.scale(to: 1.0, duration: ScaleDuration)
                let ScaleGroup = SCNAction.sequence([ScaleUp, ScaleDown])
                let ScaleForever = SCNAction.repeatForever(ScaleGroup)
                FinalNode = SCNNode2(geometry: QSphere)
                if IsCached
                {
                    FinalNode.geometry?.firstMaterial?.diffuse.contents = NSColor.lightGray
                }
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                FinalNode.runAction(ScaleForever)
                
            case .TetheredNumber:
                FinalNode = SCNNode2(geometry: SCNCylinder(radius: CGFloat(Percent * 0.05),
                                                           height: CGFloat(Quake3D.QuakeCapsuleHeight.rawValue * Percent)))
                let FinalScale = NodeScales3D.CylinderEarthquake.rawValue * CGFloat(ScaleMultiplier)
                FinalNode.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                FinalNode.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
                FinalNode.NodeID = Quake.QuakeID
                YRotation = Quake.Latitude + 90.0
                XRotation = Quake.Longitude + 180.0
                Addendum = PlotMagnitudes(Quake, AtHeight: 0.0)//Quake3D.QuakeCapsuleHeight.rawValue * Percent)
        }
        
        let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Double(FinalRadius) + RadialOffset)
        FinalNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        FinalNode.SetLocation(Quake.Latitude, Quake.Longitude)
        FinalNode.NodeUsage = .Earthquake
        FinalNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        FinalNode.position = SCNVector3(X, Y, Z)
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        if Addendum != nil
        {
            
            FinalNode.addChildNode(Addendum!)
        }
        return (FinalNode, MagNode, InfoNode)
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
        var ClosestCity: City2? = nil
        var Distance: Double = Double.greatestFiniteMagnitude
        for SomeCity in CitiesToPlot
        {
            let (QX, QY, QZ) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let (CX, CY, CZ) = ToECEF(SomeCity.Latitude, SomeCity.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let PDistance = Geometry.Distance3D(X1: QX, Y1: QY, Z1: QZ, X2: CX, Y2: CY, Z2: CZ)
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
    /// - Parameter Vertically: If true, text is plotted vertically.
    /// - Parameter AtHeight: If non-nil, the height of the text over the Earth.
    /// - Parameter Prefix: Prefix for the magnitude value. Defaults to "• M".
    /// - Returns: Node with extruded text indicating the earthquake.
    func PlotMagnitudes(_ Quake: Earthquake, Vertically: Bool = false, AtHeight: Double? = nil,
                        Prefix: String = "• M") -> SCNNode2
    {
        var Radius = Double(GlobeRadius.Primary.rawValue) + 0.5
        let Magnitude = "\(Prefix)\(Quake.GreatestMagnitude.RoundedTo(1))"
        
        let MagText = SCNText(string: Magnitude, extrusionDepth: CGFloat(Quake.GreatestMagnitude))
        let FontSize = CGFloat(18.0 + Quake.GreatestMagnitude)
        let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 18.0, NSColor.black))
        MagText.font = NSFont(name: EqFont.PostscriptName, size: FontSize)
        MagText.flatness = 0.1
        MagText.firstMaterial?.specular.contents = NSColor.white
        MagText.firstMaterial?.lightingModel = .physicallyBased
        let MagNode = SCNNode2(geometry: MagText)
        MagNode.SetLocation(Quake.Latitude, Quake.Longitude)
        MagNode.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
        MagNode.scale = SCNVector3(NodeScales3D.EarthquakeText.rawValue,
                                   NodeScales3D.EarthquakeText.rawValue,
                                   NodeScales3D.EarthquakeText.rawValue)
        MagNode.name = GlobeNodeNames.EarthquakeNodes.rawValue
        var YOffset = (MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) * NodeScales3D.EarthquakeText.rawValue
        YOffset = MagNode.boundingBox.max.y * NodeScales3D.EarthquakeText.rawValue * 3.5
        let XOffset = ((MagNode.boundingBox.max.y - MagNode.boundingBox.min.y) / 2.0) * NodeScales3D.EarthquakeText.rawValue -
            (MagNode.boundingBox.min.y * NodeScales3D.EarthquakeText.rawValue)
        if let HeightOffset = AtHeight
        {
            Radius = Radius + HeightOffset
        }
        let (X, Y, Z) = Geometry.ToECEF(Quake.Latitude,
                                        Quake.Longitude,
                                        LatitudeOffset: Double(-YOffset),
                                        LongitudeOffset: Double(XOffset),
                                        Radius: Radius)
        MagNode.position = SCNVector3(X, Y, Z)
        
        var QuakeColor: NSColor = NSColor.red
        let MagRange = GetMagnitudeRange(For: Quake.GreatestMagnitude)
        let Colors = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in Colors
        {
            if Magnitude == MagRange
            {
                QuakeColor = Color
            }
        }
        let Day: EventAttributes =
        { 
            let D = EventAttributes()
            D.ForEvent = .SwitchToDay
            D.Diffuse = QuakeColor
            D.Specular = NSColor(RGB: Colors3D.HourSpecular.rawValue)
            D.Emission = nil
            return D
        }()
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToNight
                N.Diffuse = QuakeColor
                N.Specular = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                N.Emission = QuakeColor.Darker()
                return N
            }()
        MagNode.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        MagNode.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        
        if Quake.IsCluster
        {
            let LowerShape = SCNBox(width: MagNode.boundingBox.max.x, height: 4.0, length: 1.0, chamferRadius: 0.0)
            let Lower = SCNNode2(geometry: LowerShape)
            Lower.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
            Lower.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.CombinedEarthquakeColor, NSColor.systemRed)
            Lower.geometry?.firstMaterial?.specular.contents = NSColor.white
            let WidthOffset = MagNode.boundingBox.max.x / 2.0
            Lower.position = SCNVector3(MagNode.boundingBox.min.x + WidthOffset, 3.5, 0.0)
            MagNode.addChildNode(Lower)
            
            let UpperShape = SCNBox(width: MagNode.boundingBox.max.x, height: 4.0, length: 1.0, chamferRadius: 0.0)
            let Upper = SCNNode2(geometry: UpperShape)
            Upper.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
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
            YRotation = Quake.Latitude
            XRotation = Quake.Longitude + 270.0
            YRotation = 0.0
            ZRotation = 0.0
        }
        MagNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
        
        return MagNode
    }
    
    /// Visually highlight the passed earthquake.
    /// - Note: If the indicator is already present, it is not redrawn.
    /// - Parameter Quake: The earthquake to highlight.
    /// - Returns: An `SCNNode` to be used as an indicator of a recent earthquake.
    func HighlightEarthquake(_ Quake: Earthquake) -> SCNNode2
    {
        let Final = SCNNode2()
        Final.NodeID = Quake.QuakeID
        Final.NodeClass = UUID(uuidString: NodeClasses.Earthquake.rawValue)!
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
                let Indicator = SCNNode2(geometry: IndicatorShape)
                #if true
                Indicator.geometry?.firstMaterial?.diffuse.contents = NSColor(RGB: 0xffa080)
                let Day: EventAttributes =
                    {
                        let D = EventAttributes()
                        D.ForEvent = .SwitchToDay
                        D.Diffuse = NSColor(RGB: 0xffa080)
                        D.Emission = nil
                        return D
                    }()
                let Night: EventAttributes =
                    {
                        let N = EventAttributes()
                        N.ForEvent = .SwitchToNight
                        N.Diffuse = NSColor(RGB: 0xffa080)
                        N.Emission = NSColor.red
                        return N
                    }()
                Indicator.CanSwitchState = true
                Indicator.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
                Indicator.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
                if let IsInDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    Indicator.IsInDaylight = IsInDay
                }
                #else
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
                #endif
                Indicator.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
                
                let Rotate = SCNAction.rotateBy(x: CGFloat(0.0.Radians),
                                                y: CGFloat(360.0.Radians),
                                                z: CGFloat(0.0.Radians),
                                                duration: 1.0)
                let ScaleDuration = 1.0 - (Quake.GreatestMagnitude / 10.0)
                var ToScale = (0.3 * (1.0 - (Quake.GreatestMagnitude / 10.0)))
                ToScale = ToScale + Double(NodeScales3D.AnimatedRingBase.rawValue)
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
                let Indicator = SCNNode2(geometry: IndicatorShape)
                let StaticColor = Settings.GetColor(.EarthquakeColor, NSColor.red)
                Indicator.geometry?.firstMaterial?.diffuse.contents = StaticColor
                Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
                Indicator.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
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
                let Indicator = SCNNode2(geometry: IndicatorShape)
                let Color = Settings.GetColor(.EarthquakeColor, NSColor.red).withAlphaComponent(0.45)
                Indicator.geometry?.firstMaterial?.diffuse.contents = Color
                Indicator.geometry?.firstMaterial?.specular.contents = NSColor.white
                Indicator.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
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
                let Indicator = SCNNode2(geometry: IndicatorShape)
                let InitialAlpha: CGFloat = 0.8
                Indicator.geometry?.firstMaterial?.diffuse.contents = NSColor(RGB: 0xffa080)

                let Day: EventAttributes =
                    {
                        let D = EventAttributes()
                        D.ForEvent = .SwitchToDay
                        D.Diffuse = NSColor(RGB: 0xffa080)
                        D.Specular = NSColor.white
                        D.Emission = nil
                        return D
                    }()
                Indicator.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
                let Night: EventAttributes =
                    {
                        let N = EventAttributes()
                        N.ForEvent = .SwitchToNight
                        N.Diffuse = NSColor(RGB: 0xffa080)
                        N.Specular = NSColor.white
                        N.Emission = NSColor(RGB: 0xffa080)
                        return N
                    }()
                Indicator.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
                Indicator.CanSwitchState = true
                if let IsInDay = Solar.IsInDaylight(Quake.Latitude, Quake.Longitude)
                {
                    Indicator.IsInDaylight = IsInDay
                }

                Indicator.geometry?.firstMaterial?.lightingModel = .lambert
                Indicator.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                Indicator.scale = SCNVector3(NodeScales3D.RadiatingRings.rawValue,
                                             NodeScales3D.RadiatingRings.rawValue,
                                             NodeScales3D.RadiatingRings.rawValue)
                
                let ScaleDuration = 1.0 + (1.0 - (Quake.GreatestMagnitude / 10.0))
                let ToScale = Double(NodeScales3D.RadiatingRingBase.rawValue) + (0.3 * (1.0 - (Quake.GreatestMagnitude / 10.0)))
                let ScaleUp = SCNAction.scale(to: CGFloat(ToScale), duration: ScaleDuration)
                let FinalFade = SCNAction.fadeOut(duration: 0.1)
                let Wait2 = SCNAction.wait(duration: ScaleDuration - 0.1)
                let FadeSequence2 = SCNAction.sequence([Wait2, FinalFade])
                let Group = SCNAction.group([ScaleUp, FadeSequence2])
                let ResetAction = SCNAction.run
                {
                    Node in
                    Node.scale = SCNVector3(NodeScales3D.RadiatingRings.rawValue,
                                            NodeScales3D.RadiatingRings.rawValue,
                                            NodeScales3D.RadiatingRings.rawValue)
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
                                            Mask: LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue)
                TRing.PointsOut = IndicatorType == .TriangleRingOut ? true: false
                TRing.Color = Settings.GetColor(.EarthquakeColor, NSColor.red)
                TRing.TriangleRotationDuration = 10.0 - Quake.GreatestMagnitude + 2.0
                TRing.position = SCNVector3(0.0, -OuterRadius / 4.0, 0.0)
                TRing.scale = SCNVector3(NodeScales3D.TriangleRing.rawValue,
                                         NodeScales3D.TriangleRing.rawValue,
                                         NodeScales3D.TriangleRing.rawValue)
                
                let YRotation = Quake.Latitude
                let XRotation = Quake.Longitude - 180.0
                let ZRotation = 0.0
                Final.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
                Final.position = SCNVector3(X, Y, Z)
                Final.addChildNode(TRing)
                
                #if false
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
                #endif
                
                Final.name = GlobeNodeNames.EarthquakeNodes.rawValue
                
            case .None:
                return SCNNode2()
        }
        
        if !IndicatorAgeMap.contains(where: {$0.key == Quake.Code})
        {
            IndicatorAgeMap[Quake.Code] = Final
        }
        return Final
    }
}
