//
//  GlobeView.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Provide the main 3D view for Flatland.
class GlobeView: SCNView, FlatlandEventProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    /// Initializer.
    /// - Parameter frame: The frame of the SCNView.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        InitializeView()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeView()
    }
    
    /// Hide the globe view.
    public func Hide()
    {
        if EarthClock != nil
        {
            EarthClock?.invalidate()
            EarthClock = nil
        }
        self.isHidden = true
        StopClock()
    }
    
    /// Show the globe view.
    public func Show()
    {
        StartClock()
        SetAttractMode()
        self.isHidden = false
    }
    
    public var CameraObserver: NSKeyValueObservation? = nil
    
    var OldPointOfView: SCNVector3? = nil
    
    var Camera: SCNCamera = SCNCamera()
    
    /// Remove all nodes with the specified name from the scene's root node.
    /// - Note: Nodes are removed only from the specified node - see `FromParent`.
    /// - Parameter Name: The name of the node to remove. *Must match exactly.*
    /// - Parameter FromParent: If nil, nodes are removed from the scene's root node. If not nil, the nodes
    ///                         are removed from `FromParent`.
    func RemoveNodeWithName(_ Name: String, FromParent: SCNNode? = nil)
    {
        if let Parent = FromParent
        {
            for Node in Parent.childNodes
            {
                Node.removeAllActions()
                Node.removeAllAnimations()
                Node.removeFromParentNode()
            }
            return
        }
        if let Nodes = self.scene?.rootNode.childNodes
        {
            for Node in Nodes
            {
                if Node.name == Name
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                }
            }
        }
    }
    
    // MARK: - User camera variables.

    var FlatlandCamera: SCNCamera? = nil
    var FlatlandCameraNode: SCNNode? = nil
    //var FlatlandCameraLocation = SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue)
    var MouseLocations = Queue<NSEvent>(WithCapacity: 5)
    
    #if DEBUG
    /// Set debug options for the visual debugging of the 3D globe.
    /// - Note: See [SCNDebugOptions](https://docs.microsoft.com/en-us/dotnet/api/scenekit.scndebugoptions?view=xamarin-ios-sdk-12)
    /// - Parameter Options: Array of options to use. If empty, all debug options disabled. If `.AllOff` is present
    ///                      (regardless of the presence of any other option), all debug options disabled.
    func SetDebugOption(_ Options: [DebugOptions3D])
    {
        if Options.count == 0 || Options.contains(.AllOff)
        {
            self.debugOptions = []
            return
        }
        var DOptions: UInt = 0
        for Option in Options
        {
            DOptions = DOptions + Option.rawValue
        }
        self.debugOptions = SCNDebugOptions(rawValue: DOptions)
    }
    #endif
    
    /// Sets the HDR flag of the camera depending on user settings.
    func SetHDR()
    {
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
    }
    
    var AmbientLightNode: SCNNode? = nil
    var MetalSunLight = SCNLight()
    var MetalMoonLight = SCNLight()
    var MetalSunNode = SCNNode()
    var MetalMoonNode = SCNNode()
    var SunLight = SCNLight()
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var GridLight1 = SCNLight()
    var GridLightNode1 = SCNNode()
    var GridLight2 = SCNLight()
    var GridLightNode2 = SCNNode()
    var MoonNode: SCNNode? = nil
    
    func SetDisplayLanguage()
    {
        
    }
    
    /// Stop the rotational clock.
    func StopClock()
    {
        EarthClock?.invalidate()
        EarthClock = nil
    }
    
    /// Start the rotational clock.
    func StartClock()
    {
        EarthClock = Timer.scheduledTimer(timeInterval: Defaults.EarthClockTick.rawValue,
                                          target: self, selector: #selector(UpdateEarthView),
                                          userInfo: nil, repeats: true)
        EarthClock?.tolerance = Defaults.EarthClockTickTolerance.rawValue
        RunLoop.current.add(EarthClock!, forMode: .common)
    }
    
    var EarthClock: Timer? = nil
    
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    var ClockMultiplier: Double = 1.0
    
    /// Called periodically to update the rotation of the Earth. Regardless of the frequency of
    /// being called, the Earth will always be updated to the correct position when called. However,
    /// if this function is called too infrequently, the Earth will show jerky motion as it rotates.
    /// - Note: When compiled in #DEBUG mode, code is included for debugging time functionality but
    ///         only when the proper settings are enabled.
    @objc func UpdateEarthView()
    {
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
        let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        UpdateEarth(With: PrettyPercent)
    }
    
    #if DEBUG
    /// Holds the current debug time.
    var DebugTime: Date = Date()
    /// Holds the current stop time.
    var StopTime: Date = Date()
    
    /// Set the debug time.
    /// - Parameter NewTime: The new time for the debug clock.
    func SetDebugTime(_ NewTime: Date)
    {
        DebugTime = NewTime
    }
    
    /// Set the stop time.
    /// - Parameter NewTime: The time when to stop updating the clock.
    func SetStopTime(_ NewTime: Date)
    {
        StopTime = NewTime
    }
    #endif
    
    /// Update the rotation of the Earth.
    /// - Note: The rotation must be called with `usesShortestUnitArc` set to `true` or every midnight
    ///         UTC, the Earth will spin backwards by 360°.
    /// - Parameter With: The percent time of day it is. Determines the rotation position of the Earth
    ///                   and supporting 3D nodes.
    func UpdateEarth(With Percent: Double)
    {
        let Degrees = 180.0 - (360.0) * Percent
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0,
                                        y: CGFloat(-Radians),
                                        z: 0.0,
                                        duration: Defaults.EarthRotationDuration.rawValue,
                                        usesShortestUnitArc: true)
        EarthNode?.runAction(Rotate)
        SeaNode?.runAction(Rotate)
        LineNode?.runAction(Rotate)
        for (_, Layer) in StencilLayers
        {
            Layer.runAction(Rotate)
        }
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
        {
            HourNode?.runAction(Rotate)
        }
    }
    
    /// Return maps to be used as textures for the 3D Earth.
    /// - Parameter Map: The map type whose image (or images) will be returned.
    /// - Returns: Tuple with the standard Earth map and, if the map type supports it, the sea map as well.
    func MakeMaps(_ Map: MapTypes) -> (Earth: NSImage, Sea: NSImage?)
    {

        let BaseMap = MapManager.ImageFor(MapType: Map, ViewType: .Globe3D)
        var SecondaryMap: NSImage? = nil
        switch Map
        {
            case .Standard:
                SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
                
            case .TectonicOverlay:
                SecondaryMap = MapManager.ImageFor(MapType: .Dithered, ViewType: .Globe3D)!
                
            case .StylizedSea1:
                SecondaryMap = NSImage(named: "JapanesePattern4")!
                
            default:
                break
        }
        if let Category = MapManager.CategoryFor(Map: Map)
        {
            if Category == .Satellite
            {
                if let TheMap = GlobalBaseMap
                {
                return (Earth: TheMap, Sea: SecondaryMap)
                }
                let LastResortMap = MapManager.ImageFor(MapType: .Standard, ViewType: .Globe3D)!
                return (Earth: LastResortMap, Sea: nil)
            }
        }
        return (Earth: BaseMap!, Sea: SecondaryMap)
    }
    
    /// Contains the base map of the 3D view.
    var GlobalBaseMap: NSImage? = nil
    
    /// Add an Earth view to the 3D view.
    /// - Parameter FastAnimated: Used for debugging.
    func AddEarth(FastAnimate: Bool = false, WithMap: NSImage? = nil)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .CubicWorld
        {
            ShowCubicEarth()
            return
        }
        if EarthNode != nil
        {
            EarthNode?.removeAllActions()
            EarthNode?.removeFromParentNode()
            EarthNode = nil
        }
        if SeaNode != nil
        {
            SeaNode?.removeAllActions()
            SeaNode?.removeFromParentNode()
            SeaNode = nil
        }
        if LineNode != nil
        {
            LineNode?.removeAllActions()
            LineNode?.removeFromParentNode()
            LineNode = nil
        }
        if SystemNode != nil
        {
            SystemNode?.removeAllActions()
            SystemNode?.removeFromParentNode()
            SystemNode = nil
        }
        if HourNode != nil
        {
            HourNode?.removeAllActions()
            HourNode?.removeFromParentNode()
            HourNode = nil
        }
        
        SystemNode = SCNNode()
        
        let EarthSphere = SCNSphere(radius: GlobeRadius.Primary.rawValue)
        EarthSphere.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: Int(Defaults.SphereSegmentCount.rawValue))
        let SeaSphere = SCNSphere(radius: GlobeRadius.SeaSphere.rawValue)
        SeaSphere.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: Int(Defaults.SphereSegmentCount.rawValue))
        
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        var BaseMap: NSImage? = nil
        var SecondaryMap = NSImage()

        if let OtherMap = WithMap
        {
            BaseMap = OtherMap
        }
        else
        {
            let (Earth, Sea) = MakeMaps(MapType)
            BaseMap = Earth
            if let SeaMap = Sea
            {
                SecondaryMap = SeaMap
            }
        }

        switch MapType
        {
            case .Standard:
                SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
                
            case .TectonicOverlay:
                SecondaryMap = MapManager.ImageFor(MapType: .Dithered, ViewType: .Globe3D)!
                
            case .StylizedSea1:
                SecondaryMap = NSImage(named: "JapanesePattern4")!
                
            default:
                break
        }
        
        GlobalBaseMap = BaseMap
        
        EarthNode = SCNNode2(geometry: EarthSphere)
        EarthNode?.castsShadow = true
        EarthNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        //Precondition the surfaces.
        switch MapType
        {
            case .EarthquakeMap:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal.withAlphaComponent(CGFloat(Defaults.EarthquakeMapOpacity.rawValue))
                EarthNode?.opacity = CGFloat(Defaults.EarthquakeMapOpacity.rawValue)
                
            case .StylizedSea1:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .Debug2:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
                
            case .Debug5:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
                
            case .TectonicOverlay:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .ASCIIArt1:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                
            case .BlackWhiteShiny:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Standard:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
                
            case .SimpleBorders2:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue 
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Topographical1:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Pink:
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                EarthNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Bronze:
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.orange
                SeaNode = SCNNode2(geometry: SeaSphere)
                SeaNode?.castsShadow = true
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor(red: 1.0,
                                                                             green: 210.0 / 255.0,
                                                                             blue: 0.0,
                                                                             alpha: 1.0)
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .lambert
                
            default:
                //Create an empty sea node if one is not needed.
                SeaNode = SCNNode2()
                SeaNode?.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SeaNode?.castsShadow = true
        }
        
        EarthNode?.NodeID = NodeTables.EarthGlobe
        EarthNode?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        SeaNode?.NodeID = NodeTables.SeaGlobe
        SeaNode?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        
        PlotLocations(On: EarthNode!, WithRadius: GlobeRadius.Primary.rawValue)
        
        let SeaMapList: [MapTypes] = [.Standard, .Topographical1, .SimpleBorders2, .Pink, .Bronze,
                                      .TectonicOverlay, .BlackWhiteShiny, .ASCIIArt1, .Debug2,
                                      .Debug5, .StylizedSea1, .EarthquakeMap]
        self.prepare([EarthNode!, SeaNode!], completionHandler:
                        {
                            success in
                            if success
                            {
                                self.SystemNode?.addChildNode(self.EarthNode!)
                                if SeaMapList.contains(MapType)
                                {
                                    self.SystemNode?.addChildNode(self.SeaNode!)
                                }
                                self.scene?.rootNode.addChildNode(self.SystemNode!)
                            }
                        }
        )
        
        SetLineLayer()
        
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        UpdateHourLabels(With: HourType)
        
        let Declination = Sun.Declination(For: Date())
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        if FastAnimate
        {
            let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0,
                                                 duration: Defaults.FastAnimationDuration.rawValue)
            let RotateForever = SCNAction.repeatForever(EarthRotate)
            SystemNode?.runAction(RotateForever)
        }
    }
    
    /// Change the base map to the passed map.
    /// - Note: Stenciling will be applied as appropriate and the new base map will be applied
    ///         once the stenciling process has been completed.
    /// - Parameter To: Texture to use for the base map.
    func ChangeEarthBaseMap(To NewMap: NSImage)
    {
        GlobalBaseMap = NewMap
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = NewMap
        ApplyStencils(Caller: #function)
    }
    
    var PreviousHourType: HourValueTypes = .None
    
    /// Draws or removes the layer that displays the set of lines (eg, longitudinal and latitudinal and
    /// other) from user settings.
    /// - Note: The grid uses its own set of lights to ensure it is properly visible when over the
    ///         night-side of the Earth.
    /// - Parameter Radius: The radius of the sphere holding the lines. Default is `10.2` which is
    ///                     slightly over the Earth.
    func SetLineLayer(Radius: CGFloat = GlobeRadius.LineSphere.rawValue)
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
            return
        }
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        LineNode = nil
        if Settings.GetBool(.Show3DGridLines)
        {
            let LineSphere = SCNSphere(radius: Radius)
            LineSphere.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: Int(Defaults.SphereSegmentCount.rawValue))
            LineNode = SCNNode(geometry: LineSphere)
            LineNode?.categoryBitMask = LightMasks3D.Grid.rawValue
            LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
            let GridLineImage = MakeGridLines(Width: CGFloat(Defaults.StandardMapWidth.rawValue),
                                              Height: CGFloat(Defaults.StandardMapHeight.rawValue))
            LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLineImage
            LineNode?.castsShadow = false
            SystemNode?.addChildNode(self.LineNode!)
        }
    }
    
    /// Change the transparency of the land and sea nodes to what is in user settings.
    func UpdateSurfaceTransparency()
    {
        let Alpha = 1.0 - Settings.GetDouble(.GlobeTransparencyLevel)
        EarthNode?.opacity = CGFloat(Alpha)
        SeaNode?.opacity = CGFloat(Alpha)
        HourNode?.opacity = CGFloat(Alpha)
        LineNode?.opacity = CGFloat(Alpha)
    }
    
    var RotationAccumulator: CGFloat = 0.0
    /// Holds most nodes.
    var SystemNode: SCNNode? = nil
    /// Holds nodes used to draw 3D lines.
    var LineNode: SCNNode? = nil
    /// Holds the main Earth node.
    var EarthNode: SCNNode2? = nil
    /// Holds the main sea node.
    var SeaNode: SCNNode2? = nil
    /// Holds all of the hour nodes.
    var HourNode: SCNNode2? = nil
    var PlottedEarthquakes = Set<String>()
    
    /// Handle mouse motion reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseAt(Point: CGPoint)
    {
        let MapView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapView == .Globe3D
        {
            //print("Mouse at \(Point.x),\(Point.y)")
            let SearchOptions: [SCNHitTestOption: Any] =
                [
                    //.boundingBoxOnly: true,
                    .searchMode: SCNHitTestSearchMode.closest.rawValue,
                    .ignoreHiddenNodes: true,
                    .ignoreChildNodes: false,
                    .rootNode: self.EarthNode as Any
                ]
            let HitObject = self.hitTest(Point, options: SearchOptions)
            if HitObject.count > 0
            {
                if let Node = HitObject[0].node as? SCNNode2
                {
                    if let NodeID = Node.NodeID
                    {
                        if PreviousNodeID != nil
                        {
                            if PreviousNodeID! == NodeID
                            {
                                return
                            }
                        }
                        PreviousNodeID = NodeID
                        if let NodeData = NodeTables.GetItemData(For: NodeID)
                        {
                            if Settings.GetBool(.HighlightNodeUnderMouse)
                            {
                                PreviousNode?.HideBoundingBox()
                                Node.ShowBoundingBox()
                            }
                            MainDelegate?.DisplayNodeInformation(ItemData: NodeData)
                            PreviousNode = Node
                        }
                        else
                        {
                            PreviousNode?.HideBoundingBox()
                            Debug.Print("Did not find node data for \(NodeID)")
                        }
                    }
                }
                else
                {
                    MainDelegate?.DisplayNodeInformation(ItemData: nil)
                    PreviousNode?.HideBoundingBox()
                }
            }
        }
    }
    
    var PreviousNode: SCNNode2? = nil
    var PreviousNodeID: UUID? = nil
    
    // MARK: - GlobeProtocol functions
    
    func PlotSatellite(Satellite: Satellites, At: GeoPoint)
    {
        #if false
        let SatelliteAltitude = 10.5 * (At.Altitude / 6378.1)
        let (X, Y, Z) = ToECEF(At.Latitude, At.Longitude, Radius: SatelliteAltitude)
        #endif
    }

    // MARK: - Variables for extensions.
    
    /// List of hours in Japanese Kanji.
    let JapaneseHours = [0: "〇", 1: "一", 2: "二", 3: "三", 4: "四", 5: "五", 6: "六", 7: "七", 8: "八", 9: "九",
                         10: "十", 11: "十一", 12: "十二", 13: "十三", 14: "十四", 15: "十五", 16: "十六", 17: "十七",
                         18: "十八", 19: "十九", 20: "二十", 21: "二十一", 22: "二十二", 23: "二十三", 24: "二十四"]
    
    var NorthPoleFlag: SCNNode2? = nil
    var SouthPoleFlag: SCNNode2? = nil
    var NorthPolePole: SCNNode2? = nil
    var SouthPolePole: SCNNode2? = nil
    var HomeNode: SCNNode2? = nil
    var HomeNodeHalo: SCNNode2? = nil
    var PlottedCities = [SCNNode2?]()
    var WHSNodeList = [SCNNode2?]()
    var GridImage: NSImage? = nil
    var EarthquakeList = [Earthquake]()
    var CitiesToPlot = [City2]()
    
    let TextureMap: [EarthquakeTextures: String] =
    [
        .SolidColor: "",
        .CheckerBoardTransparent: "CheckerboardTextureTransparent",
        .Checkerboard: "CheckerboardTexture",
        .DiagonalLines: "DiagonalLineTexture",
        .Gradient1: "EarthquakeHighlight",
        .Gradient2: "EarthquakeHighlight2",
        .RedCheckerboard: "RedCheckerboardTextureTransparent",
        .TransparentDiagonalLines: "DiagonalLineTextureTransparent"
    ]
    
    let RecentMap: [EarthquakeRecents: Double] =
    [
        .Day05: 12.0 * 60.0 * 60.0,
        .Day1: 24.0 * 60.0 * 60.0,
        .Day2: 2.0 * 24.0 * 60.0 * 60.0,
        .Day3: 3.0 * 24.0 * 60.0 * 60.0,
        .Day7: 7.0 * 24.0 * 60.0 * 60.0,
        .Day10: 10.0 * 24.0 * 60.0 * 60.0,
    ]
    
    var IndicatorAgeMap = [String: SCNNode2]()
    
    var StencilLayers = [GlobeLayers: SCNNode]()
    var MakeLayerLock = NSObject()
    
    var ClassID = UUID()
}
