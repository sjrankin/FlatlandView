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
class GlobeView: SCNView, SettingChangedProtocol
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
    
    /// Set or reset attract mode depending on the current user settings.
    public func SetAttractMode()
    {
        if Settings.GetBool(.InAttractMode)
        {
            EarthNode?.removeAllActions()
            SeaNode?.removeAllActions()
            LineNode?.removeAllActions()
            HourNode?.removeAllActions()
            for (_, Layer) in StencilLayers
            {
                Layer.removeAllActions()
            }
            StopClock()
            AttractEarth()
        }
        else
        {
            EarthNode?.removeAllActions()
            SeaNode?.removeAllActions()
            LineNode?.removeAllActions()
            HourNode?.removeAllActions()
            for (_, Layer) in StencilLayers
            {
                Layer.removeAllActions()
            }
            StartClock()
        }
    }
    
    /// Display the globe in attract mode.
    func AttractEarth()
    {
        let Rotate = SCNAction.rotateBy(x: 0.0, y: CGFloat(360.0.Radians), z: 0.0,
                                        duration: Defaults.AttractRotationDuration.rawValue)
        let RotateForever = SCNAction.repeatForever(Rotate)
        EarthNode?.runAction(RotateForever)
        SeaNode?.runAction(RotateForever)
        LineNode?.runAction(RotateForever)
        for (_, Layer) in StencilLayers
        {
            Layer.runAction(RotateForever)
        }
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
        Settings.AddSubscriber(self)
        
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
        self.allowsCameraControl = true
        #if false
        //If the user-camera control is enabled, this prevents the user from zooming in too close to the
        //view by checking the run-time Z value and resetting the current point of view to the minimum
        //value found in the user settings (but which is not user-accessible).
        if self.allowsCameraControl
        {
            //https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol
            CameraObserver = self.observe(\.pointOfView?.position, options: [.new, .initial])
            {
                (Node, Change) in
                OperationQueue.current?.addOperation
                {
                    if self.OldPointOfView == nil
                    {
                        self.OldPointOfView = Node.pointOfView!.position
                        return
                    }
                    let Distance = sqrt(Node.pointOfView!.position.x + Node.pointOfView!.position.y +
                                            Node.pointOfView!.position.z)
                    let Closest = Settings.GetCGFloat(.ClosestZ, Defaults.ClosestZ)
                    if Distance < Closest
                    {
                        print("\(Distance)<\(Closest)")
                        Node.pointOfView!.position = self.OldPointOfView!
                    }
                    else
                    {
                        self.OldPointOfView = Node.pointOfView!.position
                    }
                }
            }
        }
        #endif
        
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = NSColor.clear
        //Higher antialiasing mode values tend to use a lot of alpha which SceneKit uses when doing final
        //rendering, making the globe transparent along the edges of grid lines, which looks really weird.
        self.antialiasingMode = .multisampling2X
        self.isJitteringEnabled = true
        #if DEBUG
        self.showsStatistics = Settings.GetBool(.ShowStatistics)
        #else
        self.showsStatistics = false
        #endif
        
        #if false
        InitializeSceneCamera(Settings.GetBool(.UseSystemCameraControl))
        #else
        CreateCamera()
        #endif
        SetupLights()

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
    
    var OldPointOfView: SCNVector3? = nil
    
    // MARK: - Camera-related functions.
    
    /// Create the default camera. This is the camera that `allowsCameraControl` manipulates.
    func CreateCamera()
    {
        RemoveNodeWithName(GlobeNodeNames.FlatlandCameraNode.rawValue)
        Camera = SCNCamera()
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
        Camera.fieldOfView = Settings.GetCGFloat(.FieldOfView, Defaults.FieldOfView)
        //Camera.usesOrthographicProjection = true
        //Camera.orthographicScale = Settings.GetDouble(.OrthographicScale, 14.0)
        let ZFar = Settings.GetDouble(.ZFar, Defaults.ZFar)
        let ZNear = Settings.GetDouble(.ZNear, Defaults.ZNear)
        Camera.zFar = ZFar
        Camera.zNear = ZNear
        CameraNode = SCNNode()
        CameraNode.name = GlobeNodeNames.BuiltInCameraNode.rawValue
        CameraNode.camera = Camera
        CameraNode.position = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue))
        self.scene?.rootNode.addChildNode(CameraNode)
    }
    
    var Camera: SCNCamera = SCNCamera()
    
    /// Remove all nodes with the specified name from the scene's root node.
    /// - Parameter Name: The name of the node to remove. *Must match exactly.*
    func RemoveNodeWithName(_ Name: String)
    {
        if let Nodes = self.scene?.rootNode.childNodes
        {
            for Node in Nodes
            {
                if Node.name == Name
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                    print("Node: \(Name) removed from parent.")
                }
            }
        }
    }
    
    func InitializeSceneCamera(_ UseFlatland: Bool)
    {
        #if false
        print("UseFlatlandCamera(\(UseFlatland))")
        if UseFlatland
        {
            self.allowsCameraControl = false
            RemoveNodeWithName(GlobeNodeNames.BuiltInCameraNode.rawValue)
            FlatlandCamera = SCNCamera()
            FlatlandCamera?.fieldOfView = Settings.GetCGFloat(.CameraFieldOfView, 90.0)
            FlatlandCamera?.zFar = Settings.GetDouble(.ZFar, 1000.0)
            FlatlandCamera?.zNear = Settings.GetDouble(.ZNear, 0.1)
            FlatlandCameraNode = SCNNode()
            FlatlandCameraNode?.camera = FlatlandCamera
            FlatlandCameraNode?.position = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, 175.0))
            self.scene?.rootNode.addChildNode(FlatlandCameraNode!)
        }
        else
        {
            CreateCamera()
            self.allowsCameraControl = true
        }
        #endif
    }
    
    func UpdateFlatlandCamera()
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        if FlatlandCamera == nil
        {
            print("FlatlandCamera is nil")
        }
        let NewFOV = Settings.GetCGFloat(.CameraFieldOfView)
        let NewOrthoScale = Settings.GetDouble(.CameraOrthographicScale)
        let NewProjection = Settings.GetEnum(ForKey: .CameraProjection, EnumType: CameraProjections.self, Default: .Perspective)
        if NewProjection == .Orthographic
        {
            FlatlandCamera?.usesOrthographicProjection = true
            FlatlandCamera?.orthographicScale = NewOrthoScale
            FlatlandCamera?.fieldOfView = NewFOV
        }
        else
        {
            FlatlandCamera?.usesOrthographicProjection = false
            FlatlandCamera?.fieldOfView = NewFOV
        }
        #endif
    }
    
    func ResetFlatlandCamera(_ Completed: ((Bool) -> ())? = nil)
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            Completed?(false)
            return
        }
        let ResetAngles = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0,
                                             duration: 1.5, usesShortestUnitArc: true)
        let ResetPosition = SCNAction.move(to: SCNVector3(0.0, 0.0, 15.0),
                                           duration: 1.5)
        SystemNode?.runAction(ResetAngles)
        FlatlandCameraNode?.runAction(ResetPosition)
        {
            Completed?(true)
        }
        #endif
    }
    
    // MARK: - User camera variables.

    var FlatlandCamera: SCNCamera? = nil
    var FlatlandCameraNode: SCNNode? = nil
    var FlatlandCameraLocation = SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue)
    var MouseLocations = Queue<NSEvent>(WithCapacity: 5)
    
    func HandleMouseScrollWheelChanged(DeltaX: Int, DeltaY: Int, Option: Bool)
    {
        #if false
        let CameraX = FlatlandCameraNode?.position.x
        let CameraY = FlatlandCameraNode?.position.y
        let CameraZ = FlatlandCameraNode?.position.z
        if Option
        {
            if Settings.GetBool(.EnableZooming)
            {
                let NewZ = CameraZ! + CGFloat(DeltaY)
                FlatlandCameraNode?.position = SCNVector3(CameraX!, CameraY!, NewZ)
            }
        }
        else
        {
            if Settings.GetBool(.EnableMoving)
            {
                FlatlandCameraNode?.position = SCNVector3(CameraX! + CGFloat(-DeltaX),
                                                      CameraY! + CGFloat(DeltaY),
                                                      CameraZ!)
            }
        }
        #endif
    }
    
    func HandleMouseDragged(DeltaX: Int, DeltaY: Int)
    {
        #if false
        if Settings.GetBool(.EnableDragging)
        {
            if let Euler = SystemNode?.eulerAngles
            {
                if DeltaX != 0
                {
                    let Yaw = Euler.y + (CGFloat(DeltaX) * CGFloat.pi / 180.0)
                    SystemNode?.eulerAngles = SCNVector3(Euler.x, Yaw, Euler.z)
                }
                if DeltaY != 0
                {
                    let Pitch = Euler.x + (CGFloat(DeltaY) * CGFloat.pi / 180.0)
                    SystemNode?.eulerAngles = SCNVector3(Pitch, Euler.y, Euler.z)
                }
            }
        }
        #endif
    }
    
    // MARK: - Light-related functions
    
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
    /// - Note: In order to prevent the Earth from flying around wildly during the reset transition, a
    ///         look-at constraint is added for the duration of the transition, and removed once the rotation
    ///         transition is completed.
    func ResetCamera()
    {
        let Constraint = SCNLookAtConstraint(target: SystemNode)
        Constraint.isGimbalLockEnabled = false
        SCNTransaction.begin()
        SCNTransaction.animationDuration = Defaults.ResetCameraAnimationDuration.rawValue
        self.pointOfView?.constraints = [Constraint]
        SCNTransaction.commit()
        
        let InitialPosition = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue))
        let PositionAction = SCNAction.move(to: InitialPosition, duration: Defaults.ResetCameraAnimationDuration.rawValue)
        PositionAction.timingMode = .easeOut
        self.pointOfView?.runAction(PositionAction)
        
        let RotationAction = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: Defaults.ResetCameraAnimationDuration.rawValue)
        RotationAction.timingMode = .easeOut
        self.pointOfView?.runAction(RotationAction)
        {
            self.pointOfView?.constraints = []
        }
    }
    
    /// Sets the HDR flag of the camera depending on user settings.
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
    
    /// Create an ambient light for the scene.
    func CreateAmbientLight()
    {
        let Ambient = SCNLight()
        Ambient.categoryBitMask = LightMasks.Sun.rawValue
        Ambient.type = .ambient
        Ambient.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        Ambient.castsShadow = true
        Ambient.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        Ambient.shadowMode = .forward
        Ambient.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        Ambient.color = NSColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
    }
    
    /// Remove the ambient light from the scene.
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
        SunLight.categoryBitMask = LightMasks.Sun.rawValue
        SunLight.type = .directional
        SunLight.intensity = CGFloat(Defaults.SunLightIntensity.rawValue)
        SunLight.castsShadow = true
        SunLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        SunLight.shadowMode = .forward
        SunLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        SunLight.color = NSColor.white
        LightNode = SCNNode()
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    /// Show or hide the moonlight node.
    /// - Parameter Show: Determines if moonlight is shown or removed.
    func SetMoonlight(Show: Bool)
    {
        if Show
        {
            let MoonLight = SCNLight()
            MoonLight.categoryBitMask = LightMasks.Moon.rawValue
            MoonLight.type = .directional
            MoonLight.intensity = CGFloat(Defaults.MoonLightIntensity.rawValue)
            MoonLight.castsShadow = true
            MoonLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
            MoonLight.shadowMode = .forward
            MoonLight.shadowRadius = CGFloat(Defaults.MoonLightShadowRadius.rawValue)
            MoonLight.color = NSColor.cyan
            MoonNode = SCNNode()
            MoonNode?.light = MoonLight
            MoonNode?.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
            MoonNode?.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MoonNode!)
            
            MetalMoonLight = SCNLight()
            MetalMoonLight.categoryBitMask = LightMasks.MetalMoon.rawValue
            MetalMoonLight.type = .directional
            MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
            MetalMoonLight.castsShadow = true
            MetalMoonLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
            MetalMoonLight.shadowMode = .forward
            MetalMoonLight.shadowRadius = CGFloat(Defaults.MoonLightShadowRadius.rawValue)
            MetalMoonLight.color = NSColor.cyan
            MetalMoonNode = SCNNode()
            MetalMoonNode.light = MetalMoonLight
            MetalMoonNode.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
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
        MetalSunLight.categoryBitMask = LightMasks.MetalSun.rawValue
        MetalSunLight.type = .directional
        MetalSunLight.intensity = CGFloat(Defaults.MetalSunLightIntensity.rawValue)
        MetalSunLight.castsShadow = true
        MetalSunLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        MetalSunLight.shadowMode = .forward
        MetalSunLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        MetalSunLight.color = NSColor.white
        MetalSunNode = SCNNode()
        MetalSunNode.light = MetalSunLight
        MetalSunNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(MetalSunNode)
        
        MetalMoonLight = SCNLight()
        MetalMoonLight.categoryBitMask = LightMasks.MetalMoon.rawValue
        MetalMoonLight.type = .directional
        MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
        MetalMoonLight.castsShadow = true
        MetalMoonLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        MetalMoonLight.shadowMode = .forward
        MetalMoonLight.shadowRadius = CGFloat(Defaults.MoonLightShadowRadius.rawValue)
        MetalMoonLight.color = NSColor.cyan
        MetalMoonNode = SCNNode()
        MetalMoonNode.light = MetalMoonLight
        MetalMoonNode.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
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
        GridLight1.categoryBitMask = LightMasks.Grid.rawValue
        GridLightNode1 = SCNNode()
        GridLightNode1.light = GridLight1
        GridLightNode1.position = SCNVector3(0.0, 0.0, Defaults.Grid1Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode1)
        GridLight2 = SCNLight()
        GridLight2.type = .omni
        GridLight2.color = NSColor.white
        GridLight2.categoryBitMask = LightMasks.Grid.rawValue
        GridLightNode2 = SCNNode()
        GridLightNode2.light = GridLight2
        GridLightNode2.position = SCNVector3(0.0, 0.0, Defaults.Grid2Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode2)
    }
    
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
        
        EarthNode = SCNNode(geometry: EarthSphere)
        EarthNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        //Precondition the surfaces.
        switch MapType
        {
            case .EarthquakeMap:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal.withAlphaComponent(CGFloat(Defaults.EarthquakeMapOpacity.rawValue))
                EarthNode?.opacity = CGFloat(Defaults.EarthquakeMapOpacity.rawValue)
                
            case .StylizedSea1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .Debug2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
                
            case .Debug5:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
                
            case .TectonicOverlay:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                
            case .ASCIIArt1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                
            case .BlackWhiteShiny:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Standard:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
                
            case .SimpleBorders2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue 
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Topographical1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Pink:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                EarthNode?.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Bronze:
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.orange
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
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
                SeaNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
        }
        
        PlotLocations(On: EarthNode!, WithRadius: GlobeRadius.Primary.rawValue)
        
        EarthNode?.geometry?.firstMaterial?.isDoubleSided = true
        SeaNode?.geometry?.firstMaterial?.isDoubleSided = true
        EarthNode?.geometry?.firstMaterial?.blendMode = .alpha
        SeaNode?.geometry?.firstMaterial?.blendMode = .alpha
        
        #if false
        Stenciler.AddStencils(To: BaseMap!,
                              Quakes: EarthquakeList,
                              ShowRegions: true,
                              PlotCities: true,
                              GridLines: true,
                              UNESCOSites: true,
                              CalledBy: "AddEarth",
                              Completed: GotStenciledMap(_:_:_:))
        #endif
        
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
    
    /// Apply stencils to `GlobalBaseMap` as needed. When the stenciled map is ready,
    /// `GotStenciledMap` is called.
    /// - Notes:
    ///    - Control returns almost immediately.
    ///    - The user can change settings such that no stenciling is applied. In that case,
    ///      the non-stenciled map will be available very quickly.
    /// - Parameter Caller: Name of the caller.
    /// - Parameter Final: Called after the stencil has been applied.
    func ApplyStencils(Caller: String? = nil, Final: (() -> ())? = nil)
    {
        #if DEBUG
        if let CallerName = Caller
        {
            Debug.Print("ApplyStencils called by \(CallerName)")
        }
        #endif
        if let Map = GlobalBaseMap
        {
            let ShowEarthquakes = Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            var Quakes: [Earthquake]? = nil
            if ShowEarthquakes
            {
                if Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No) == .Stenciled
                {
                    Quakes = EarthquakeList
                }
            }
            let ShowUNESCO = Settings.GetBool(.ShowWorldHeritageSites) && Settings.GetBool(.PlotSitesAs2D)
            Stenciler.AddStencils(To: Map,
                                  Quakes: Quakes,
                                  ShowRegions: Settings.GetBool(.ShowEarthquakeRegions),
                                  PlotCities: Settings.GetBool(.CityNamesDrawnOnMap),
                                  GridLines: Settings.GetBool(.GridLinesDrawnOnMap),
                                  UNESCOSites: ShowUNESCO,
                                  CalledBy: Caller,
                                  FinalNotify: Final,
                                  Completed: GotStenciledMap)
        }
    }
    
    /// Closure for receiving a stenciled map.
    /// - Parameter Image: The (potentially) stenciled map. Depending on user settings, it is very
    ///                    possible no stenciling will be done and the map will be made available
    ///                    very quickly.
    /// - Parameter Duration: The duration, in seconds, of the stenciling process. If no steciling
    ///                       was applied, this value will be 0.0.
    /// - Parameter CalledBy: The name of the caller. May be nil.
    func GotStenciledMap(_ Image: NSImage, _ Duration: Double, _ CalledBy: String?,
                         Notify: (() -> ())? = nil)
    {
        #if DEBUG
        let StackFrames = Debug.StackFrameContents(10)
        Debug.Print(Debug.PrettyStackTrace(StackFrames))
        if let Caller = CalledBy
        {
            Debug.Print("Stencil available: called by \(Caller), duration: \(Duration.RoundedTo(2))")
        }
        else
        {
            Debug.Print("Stenciling duration: \(Duration)")
        }
        #endif
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = Image
        Debug.Print("Applied stenciled map.")
        Notify?()
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
            LineNode?.categoryBitMask = LightMasks.Grid.rawValue
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
    var SystemNode: SCNNode? = nil
    var LineNode: SCNNode? = nil
    var EarthNode: SCNNode? = nil
    var SeaNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    var PlottedEarthquakes = Set<String>()
    
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
    var CitiesToPlot = [City]()
    
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
    
    var IndicatorAgeMap = [String: SCNNode]()
    
    var StencilLayers = [GlobeLayers: SCNNode]()
    var MakeLayerLock = NSObject()
    
    var ClassID = UUID()
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .HourType:
                if let NewHourType = NewValue as? HourValueTypes
                {
                    UpdateHourLabels(With: NewHourType)
                }
                
            case .UseHDRCamera:
                SetHDR()
                
            case .CityShapes:
                PlotCities()
                ApplyStencils(Caller: "SettingChanged(.CityShapes)")
                
            case .PopulationType:
                PlotCities()
                
            case .ShowHomeLocation:
                PlotCities()
                
            case .HomeColor:
                PlotCities()
                
            case .UserLocations:
                PlotCities()
                
            case .ShowUserLocations:
                PlotCities()
                
            case .HomeShape:
                PlotHomeLocation()
                
            case .PolarShape:
                PlotPolarShape()
                
            case .ShowWorldHeritageSites:
                ApplyStencils(Caller: "SettingChanged(.ShowWorldHeritageSites)")
                PlotWorldHeritageSites()
                
            case .WorldHeritageSiteType:
                ApplyStencils(Caller: "SettingChanged(.WorldHeritageSiteType)")
                PlotWorldHeritageSites()
                
            case .Show3DEquator, .Show3DTropics, .Show3DMinorGrid, .Show3DPolarCircles, .Show3DPrimeMeridians,
                 .MinorGrid3DGap, .Show3DGridLines, .GridLineColor, .MinorGridLineColor:
                SetLineLayer()
                ApplyStencils(Caller: "SettingChanged(.{Multiple})")
                
            case .Script:
                PlotPolarShape()
                UpdateHours()
                
            case .HourColor:
                UpdateHours()
                
            case .ShowMoonLight:
                SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
                
            case .ShowPOIEmission:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                {
                    PlotCities()
                }
                
            case .EarthquakeStyles:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .RecentEarthquakeDefinition:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .EarthquakeTextures:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .EarthquakeColor:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .BaseEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .HighlightRecentEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .ColorDetermination:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        ApplyStencils(Caller: "SettingChanged(.ColorDetermination)")
                    }
                }
                
            case .EarthquakeShapes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .EarthquakeMagnitudeColors:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        ApplyStencils(Caller: "SettingChanged(.EarthquakeMagnitudeColors)")
                    }
                }
                
            case .UseAmbientLight:
                SetupLights()
                
            case .EarthquakeFontName:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        ApplyStencils(Caller: ".EarthquakeFontName")
                    }
                }
                
            case .EarthquakeMagnitudeViews:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .CombinedEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .CityFontName, .CityFontRelativeSize, .MagnitudeRelativeFontSize:
                PlotCities()
                ApplyStencils(Caller: "{.Multiple}")
                
            case .WorldCityColor, .AfricanCityColor, .AsianCityColor, .EuropeanCityColor,
                 .NorthAmericanCityColor, .SouthAmericanCityColor, .CapitalCityColor,
                 .CustomCityListColor, .CityNodesGlow, .PopulationColor:
                PlotCities()
                ApplyStencils()
                
            case .ShowCustomCities, .ShowAfricanCities, .ShowAsianCities,
                 .ShowEuropeanCities, .ShowNorthAmericanCities, .ShowSouthAmericanCities,
                 .ShowCapitalCities, .ShowWorldCities, .ShowCitiesByPopulation,
                 .PopulationRank, .PopulationRankIsMetro, .PopulationFilterValue,
                 .PopulationFilterGreater, .PopulationFilterType:
                PlotCities()
                ApplyStencils()
                
            case .CustomCityList:
                if Settings.GetBool(.ShowCustomCities)
                {
                    PlotCities()
                    ApplyStencils()
                }
                
            case .HourFontName:
                UpdateHours()
                
            case .GridLinesDrawnOnMap, .MagnitudeValuesDrawnOnMap,
                 .EarthquakeRegions, .ShowEarthquakeRegions,
                 .CityNamesDrawnOnMap:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    ClearEarthquakes()
                    ApplyStencils(Caller: "SettingChanged(.{Multiple})")
                }
                
            case .UseSystemCameraControl:
                InitializeSceneCamera(!Settings.GetBool(.UseSystemCameraControl))
                
            case .CameraProjection, .CameraOrthographicScale, .CameraFieldOfView:
                UpdateFlatlandCamera()
                
            #if DEBUG
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints, .ShowStatistics:
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .Globe3D || ViewType == .CubicWorld
                {
                    Settings.QueryBool(.ShowStatistics)
                    {
                        Show in
                        showsStatistics = Show
                    }
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
                }
            #endif
                
            default:
                return
        }
        Debug.Print("Setting \(Setting) handled in GlobeView")
    }
}
