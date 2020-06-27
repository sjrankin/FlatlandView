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
class GlobeView: SCNView, GlobeProtocol
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        InitializeView()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeView()
    }
    
    /// Set or reset attract mode depending on the current user settings.
    public func SetAttractMode()
    {
        if Settings.GetBool(.InAttractMode)
        {
            EarthNode?.removeAllActions()
            SeaNode?.removeAllActions()
            LineNode?.removeAllActions()
            HourNode?.removeAllActions()
            StopClock()
            AttractEarth()
        }
        else
        {
            EarthNode?.removeAllActions()
            SeaNode?.removeAllActions()
            LineNode?.removeAllActions()
            HourNode?.removeAllActions()
            StartClock()
        }
    }
    
    /// Display the globe in attract mode.
    func AttractEarth()
    {
        let Rotate = SCNAction.rotateBy(x: 0.0, y: CGFloat(360.0.Radians), z: 0.0, duration: 10.0)
        let RotateForever = SCNAction.repeatForever(Rotate)
        EarthNode?.runAction(RotateForever)
        SeaNode?.runAction(RotateForever)
        LineNode?.runAction(RotateForever)
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
        {
            HourNode?.runAction(RotateForever)
        }
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
    
    /// Initialize the globe view.
    func InitializeView()
    {
        #if DEBUG
        var DebugTypes = [DebugOptions3D]()
        Settings.QueryBool(.ShowSkeletons)
        {
            Show in
            if Show
            {
                DebugTypes.append(.Skeleton)
            }
        }
        Settings.QueryBool(.ShowBoundingBoxes)
        {
            Show in
            if Show
            {
                DebugTypes.append(.BoundingBoxes)
            }
        }
        Settings.QueryBool(.ShowWireframes)
        {
            Show in
            if Show
            {
                DebugTypes.append(.WireFrame)
            }
        }
        Settings.QueryBool(.ShowLightInfluences)
        {
            Show in
            if Show
            {
                DebugTypes.append(.LightInfluences)
            }
        }
        Settings.QueryBool(.ShowLightExtents)
        {
            Show in
            if Show
            {
                DebugTypes.append(.LightExtents)
            }
        }
        Settings.QueryBool(.ShowConstraints)
        {
            Show in
            if Show
            {
                DebugTypes.append(.Constraints)
            }
        }
        SetDebugOption(DebugTypes)
        #endif
        //        self.debugOptions = [.showBoundingBoxes, .renderAsWireframe]
        self.allowsCameraControl = true
        
        #if false
        //Enable for debugging and getting initial location of the automatical camera. Otherwise,
        //not needed at run-time. Do not delete this code even for release versions.
        if self.allowsCameraControl
        {
            //https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol
            CameraObserver = self.observe(\.pointOfView?.position, options: [.new, .initial])
            {
                (Node, Change) in
                OperationQueue.current?.addOperation
                {
                    print("\(Node.pointOfView!.position)")
                    //print("\(Node.pointOfView!.orientation)")
                    //print("\(Node.pointOfView!.rotation)")
                }
            }
        }
        #endif
        
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = NSColor.clear
        self.antialiasingMode = .multisampling16X
        self.isJitteringEnabled = true
        #if DEBUG
        self.showsStatistics = true
        #else
        self.showsStatistics = false
        #endif
        
        Camera = SCNCamera()
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        Camera.zFar = 500
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 16.0)
        
        #if true
        SetupLights()
        #else
        SetGridLight()
        SetMetalLights()
        SetSunlight()
        SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
        #endif
        
        self.scene?.rootNode.addChildNode(CameraNode)
        
        AddEarth()
        if Settings.GetBool(.InAttractMode)
        {
            StopClock()
            AttractEarth()
        }
        else
        {
            StartClock()
        }
        UpdateEarthView()
        SetHourResetTimer()
    }
    
    var Camera: SCNCamera = SCNCamera()
    
    /// Setup lights to use to view the 3D scene.
    func SetupLights()
    {
        if Settings.GetBool(.UseAmbientLight)
        {
            CreateAmbientLight()
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
            LightNode.removeAllActions()
            LightNode.removeFromParentNode()
            MetalSunNode.removeAllActions()
            MetalSunNode.removeFromParentNode()
            MetalMoonNode.removeAllActions()
            MetalMoonNode.removeFromParentNode()
            GridLightNode1.removeAllActions()
            GridLightNode1.removeFromParentNode()
            GridLightNode2.removeAllActions()
            GridLightNode2.removeFromParentNode()
        }
        else
        {
            RemoveAmbientLight()
            SetGridLight()
            SetMetalLights()
            SetSunlight()
            SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
        }
    }
    
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
    
    /// Resets the default camera to its original location.
    func ResetCamera()
    {
        let PositionAction = SCNAction.move(to: SCNVector3(0.0, 0.0, 16.0), duration: 1.0)
        PositionAction.timingMode = .easeOut
        self.pointOfView?.runAction(PositionAction)
        let RotationAction = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: 1.0)
        RotationAction.timingMode = .easeOut
        self.pointOfView?.runAction(RotationAction)
    }
    
    func SetHDR()
    {
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
    }
    
    /// Set the hour reset timer.
    func SetHourResetTimer()
    {
        ResetTimer?.invalidate()
        ResetTimer = nil
        if Settings.GetBool(.ResetHoursPeriodically)
        {
            let Duration = Settings.GetDouble(.ResetHourTimeInterval, 60.0 * 60.0)
            ResetTimer = Timer.scheduledTimer(timeInterval: Duration, target: self, selector: #selector(ResetHours),
                                              userInfo: nil, repeats: true)
        }
        else
        {
            ResetTimer?.invalidate()
            ResetTimer = nil
        }
    }
    
    var ResetTimer: Timer? = nil
    
    /// Handle resetting the hour display.
    @objc func ResetHours()
    {
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        UpdateHourLabels(With: HourType)
    }
    
    func CreateAmbientLight()
    {
        let Ambient = SCNLight()
        Ambient.categoryBitMask = SunMask
        Ambient.type = .ambient
        Ambient.intensity = 800
        Ambient.castsShadow = true
        Ambient.shadowColor = NSColor.black.withAlphaComponent(0.80)
        Ambient.shadowMode = .forward
        Ambient.shadowRadius = 2.0
        Ambient.color = NSColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, 80.0)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
    }
    
    func RemoveAmbientLight()
    {
        AmbientLightNode?.removeAllActions()
        AmbientLightNode?.removeFromParentNode()
        AmbientLightNode = nil
    }
    
    var AmbientLightNode: SCNNode? = nil
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = SCNLight()
        SunLight.categoryBitMask = SunMask
        SunLight.type = .directional
        SunLight.intensity = 800
        SunLight.castsShadow = true
        SunLight.shadowColor = NSColor.black.withAlphaComponent(0.80)
        SunLight.shadowMode = .forward
        SunLight.shadowRadius = 2.0
        SunLight.color = NSColor.white
        LightNode = SCNNode()
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, 80.0)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    /// Show or hide the moonlight node.
    /// - Parameter Show: Determines if moonlight is shown or removed.
    func SetMoonlight(Show: Bool)
    {
        if Show
        {
            let MoonLight = SCNLight()
            MoonLight.categoryBitMask = MoonMask
            MoonLight.type = .directional
            MoonLight.intensity = 300
            MoonLight.castsShadow = true
            MoonLight.shadowColor = NSColor.black.withAlphaComponent(0.80)
            MoonLight.shadowMode = .forward
            MoonLight.shadowRadius = 4.0
            MoonLight.color = NSColor.cyan
            MoonNode = SCNNode()
            MoonNode?.light = MoonLight
            MoonNode?.position = SCNVector3(0.0, 0.0, -100.0)
            MoonNode?.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MoonNode!)
            
            MetalMoonLight = SCNLight()
            MetalMoonLight.categoryBitMask = MetalMoonMask
            MetalMoonLight.type = .directional
            MetalMoonLight.intensity = 800
            MetalMoonLight.castsShadow = true
            MetalMoonLight.shadowColor = NSColor.black.withAlphaComponent(0.80)
            MetalMoonLight.shadowMode = .forward
            MetalMoonLight.shadowRadius = 4.0
            MetalMoonLight.color = NSColor.cyan
            MetalMoonNode = SCNNode()
            MetalMoonNode.light = MetalMoonLight
            MetalMoonNode.position = SCNVector3(0.0, 0.0, -100.0)
            MetalMoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MetalMoonNode)
        }
        else
        {
            MetalMoonNode.removeAllActions()
            MetalMoonNode.removeFromParentNode()
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
        }
    }
    
    /// Set the lights used for metallic components.
    func SetMetalLights()
    {
        MetalSunLight = SCNLight()
        MetalSunLight.categoryBitMask = MetalSunMask
        MetalSunLight.type = .directional
        MetalSunLight.intensity = 1200
        MetalSunLight.castsShadow = true
        MetalSunLight.shadowColor = NSColor.black.withAlphaComponent(0.80)
        MetalSunLight.shadowMode = .forward
        MetalSunLight.shadowRadius = 2.0
        MetalSunLight.color = NSColor.white
        MetalSunNode = SCNNode()
        MetalSunNode.light = MetalSunLight
        MetalSunNode.position = SCNVector3(0.0, 0.0, 80.0)
        self.scene?.rootNode.addChildNode(MetalSunNode)
        
        MetalMoonLight = SCNLight()
        MetalMoonLight.categoryBitMask = MetalMoonMask
        MetalMoonLight.type = .directional
        MetalMoonLight.intensity = 800
        MetalMoonLight.castsShadow = true
        MetalMoonLight.shadowColor = NSColor.black.withAlphaComponent(0.80)
        MetalMoonLight.shadowMode = .forward
        MetalMoonLight.shadowRadius = 4.0
        MetalMoonLight.color = NSColor.cyan
        MetalMoonNode = SCNNode()
        MetalMoonNode.light = MetalMoonLight
        MetalMoonNode.position = SCNVector3(0.0, 0.0, -100.0)
        MetalMoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(MetalMoonNode)
    }
    
    /// Set the lights for the grid. The grid needs a separate light because when it's over the night
    /// side, it's not easily visible. There are two grid lights - one for day time and one for night time.
    func SetGridLight()
    {
        GridLight1 = SCNLight()
        GridLight1.type = .omni
        GridLight1.color = NSColor.white
        GridLight1.categoryBitMask = GridMask
        GridLightNode1 = SCNNode()
        GridLightNode1.light = GridLight1
        GridLightNode1.position = SCNVector3(0.0, 0.0, -80.0)
        self.scene?.rootNode.addChildNode(GridLightNode1)
        GridLight2 = SCNLight()
        GridLight2.type = .omni
        GridLight2.color = NSColor.white
        GridLight2.categoryBitMask = GridMask
        GridLightNode2 = SCNNode()
        GridLightNode2.light = GridLight2
        GridLightNode2.position = SCNVector3(0.0, 0.0, 80.0)
        self.scene?.rootNode.addChildNode(GridLightNode2)
    }
    
    let SunMask: Int = 0x1 << 1
    let MetalSunMask: Int = 0x1 << 2
    let MoonMask: Int = 0x1 << 4
    let MetalMoonMask: Int = 0x1 << 8
    let GridMask: Int = 0x1 << 16
    
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
    
    func SetClockMultiplier(_ Multiplier: Double)
    {
        //        ClockMultiplier = Multiplier
        //AddEarth(FastAnimate: true)
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
        EarthClock = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateEarthView),
                                          userInfo: nil, repeats: true)
        EarthClock?.tolerance = 0.1
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
    @objc func UpdateEarthView()
    {
        if IgnoreClock
        {
            return
        }
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
    
    /// Update the rotation of the Earth.
    /// - Parameter With: The percent time of day it is. Determines the rotation position of the Earth
    ///                   and supporting 3D nodes.
    func UpdateEarth(With Percent: Double)
    {
        let Degrees = 180.0 - (360.0) * Percent
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0, y: CGFloat(-Radians), z: 0.0, duration: 1.0)
        EarthNode?.runAction(Rotate)
        SeaNode?.runAction(Rotate)
        LineNode?.runAction(Rotate)
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
        {
            HourNode?.runAction(Rotate)
        }
    }
    
    var IgnoreClock = false
    
    /// Add an Earth view to the 3D view.
    /// - Parameter FastAnimated: Used for debugging.
    func AddEarth(FastAnimate: Bool = false)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .CubicWorld
        {
            ShowCubicEarth()
            return
        }
        IgnoreClock = FastAnimate
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
        EarthSphere.segmentCount = 100
        let SeaSphere = SCNSphere(radius: GlobeRadius.SeaSphere.rawValue)
        SeaSphere.segmentCount = 100
        
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        var BaseMap: NSImage? = nil
        var SecondaryMap = NSImage()
        BaseMap = MapManager.ImageFor(MapType: MapType, ViewType: .Globe3D)
        if BaseMap == nil
        {
            print("Error retrieving base map \(MapType). Trying standard map.")
            BaseMap = MapManager.ImageFor(MapType: .Standard, ViewType: .Globe3D)
            if BaseMap == nil
            {
                fatalError("Two-strike fatal error. Error retrieving base map \(MapTypes.Standard).")
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
        
        EarthNode = SCNNode(geometry: EarthSphere)
        EarthNode?.categoryBitMask = SunMask | MoonMask
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        //Precondition the surfaces.
        switch MapType
        {
            case .EarthquakeMap:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal.withAlphaComponent(0.4)
                EarthNode?.opacity = 0.75
                
            case .StylizedSea1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .Debug2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
                
            case .Debug5:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
                
            case .TectonicOverlay:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .ASCIIArt1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                
            case .BlackWhiteShiny:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Standard:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
                
            case .SimpleBorders2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue 
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Topographical1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Pink:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                EarthNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Bronze:
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.orange
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = SunMask | MoonMask
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor(red: 1.0,
                                                                             green: 210.0 / 255.0,
                                                                             blue: 0.0,
                                                                             alpha: 1.0)
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .lambert
                
            default:
                //Create an empty sea node if one is not needed.
                SeaNode = SCNNode()
                SeaNode?.categoryBitMask = SunMask | MoonMask
        }
        
        PlotLocations(On: EarthNode!, WithRadius: 10)
        
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
            let EarthRotate = SCNAction.rotateBy(x: 0.0, y: 360.0 * CGFloat.pi / 180.0, z: 0.0, duration: 30.0)
            let RotateForever = SCNAction.repeatForever(EarthRotate)
            SystemNode?.runAction(RotateForever)
        }
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
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        LineNode = nil
        if Settings.GetBool(.Show3DGridLines)
        {
            let LineSphere = SCNSphere(radius: Radius)
            LineSphere.segmentCount = 100
            LineNode = SCNNode(geometry: LineSphere)
            LineNode?.categoryBitMask = GridMask
            LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
            let Maroon = NSColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
            let GridLineImage = MakeGridLines(Width: 3600, Height: 1800, LineColor: Maroon)
            LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLineImage
            //LineNode?.geometry?.firstMaterial?.emission.contents = Maroon
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
    var SystemNode: SCNNode? = nil
    var LineNode: SCNNode? = nil
    var EarthNode: SCNNode? = nil
    var SeaNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    var PlottedEarthquakes = Set<String>()
    
    // MARK: - GlobeProtocol functions
    
    func PlotSatellite(Satellite: Satellites, At: GeoPoint2)
    {
        let SatelliteAltitude = 10.5 * (At.Altitude / 6378.1)
        let (X, Y, Z) = ToECEF(At.Latitude, At.Longitude, Radius: SatelliteAltitude)
    }
    
    // MARK: - Variables for extensions.
    
    /// List of hours in Japanese Kanji.
    let JapaneseHours = [0: "〇", 1: "一", 2: "二", 3: "三", 4: "四", 5: "五", 6: "六", 7: "七", 8: "八", 9: "九",
                         10: "十", 11: "十一", 12: "十二", 13: "十三", 14: "十四", 15: "十五", 16: "十六", 17: "十七",
                         18: "十八", 19: "十九", 20: "二十", 21: "二十一", 22: "二十二", 23: "二十三", 24: "二十四"]
    
    var NorthPoleFlag: SCNNode? = nil
    var SouthPoleFlag: SCNNode? = nil
    var NorthPolePole: SCNNode? = nil
    var SouthPolePole: SCNNode? = nil
    var HomeNode: SCNNode? = nil
    var HomeNodeHalo: SCNNode? = nil
    var PlottedCities = [SCNNode?]()
    var WHSNodeList = [SCNNode?]()
    var GridImage: NSImage? = nil
    var EarthquakeList = [Earthquake]()
    var EarthquakeList2 = [Earthquake2]()
    var CitiesToPlot = [City]()
    
    let MagnitudeColors: [Double: NSColor] =
        [
            //0 to 4.9
            EarthquakeMagnitudes.Mag4.rawValue: NSColor.TeaGreen,
            //5 to 5.9
            EarthquakeMagnitudes.Mag5.rawValue: NSColor.ArtichokeGreen,
            //6 to 6.9
            EarthquakeMagnitudes.Mag6.rawValue: NSColor.orange,
            //7 to 7.9
            EarthquakeMagnitudes.Mag7.rawValue: NSColor.UltraPink,
            //8 to 8.9
            EarthquakeMagnitudes.Mag8.rawValue: NSColor.Sunglow,
            // 9 to 10
            EarthquakeMagnitudes.Mag9.rawValue: NSColor.Scarlet
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
}

