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
class GlobeView: SCNView, FlatlandEventProtocol, StencilPipelineProtocol
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
    
    /// Handle new time from the world clock.
    /// - Parameter WorldDate: Contains the new date and time.
    func NewWorldClockTime(WorldDate: Date)
    {
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
                Node.geometry = nil
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
                    Node.geometry = nil
                }
            }
        }
    }
    
    #if DEBUG
    /// Set debug options for the visual debugging of the 3D globe.
    /// - Note: See [SCNDebugOptions](https://docs.microsoft.com/en-us/dotnet/api/scenekit.scndebugoptions?view=xamarin-ios-sdk-12)
    /// - Parameter Options: Array of options to use. If empty, all debug options disabled. If `.AllOff` is present
    ///                      (regardless of the presence of any other option), all debug options disabled.
    func SetDebugOption(_ Options: [DebugOptions3D])
    {
        let DoDebug = Settings.GetBool(.Enable3DDebugging)
        let DebugMap = Settings.GetEnum(ForKey: .Debug3DMap, EnumType: Debug_MapTypes.self)
        if DoDebug && DebugMap == .Globe
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
        else
        {
            RemoveAxis() 
            self.debugOptions = []
        }
    }
    #endif
    
    /// Sets the HDR flag of the camera depending on user settings.
    func SetHDR()
    {
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
    }
    
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
    
    /// Contains the base map of the 3D view.
    var GlobalBaseMap: NSImage? = nil
    
    var PreviousHourType: HourValueTypes = .None
    
    /// Draws or removes the layer that displays the set of lines (eg, longitudinal and latitudinal and
    /// other) from user settings.
    /// - Note: The grid uses its own set of lights to ensure it is properly visible when over the
    ///         night-side of the Earth.
    /// - Parameter Radius: The radius of the sphere holding the lines.
    func SetLineLayer(Radius: CGFloat = GlobeRadius.LineSphere.rawValue)
    {
        #if false
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
            LineNode = SCNNode2(geometry: LineSphere)
            LineNode?.categoryBitMask = LightMasks3D.Grid.rawValue
            LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
            let GridLineImage = MakeGridLines(Width: CGFloat(Defaults.StandardMapWidth.rawValue),
                                              Height: CGFloat(Defaults.StandardMapHeight.rawValue))
            LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLineImage
            LineNode?.castsShadow = false
            SystemNode?.addChildNode(self.LineNode!)
        }
        #endif
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
    
    func SetCameraLock(_ IsLocked: Bool, ResetPosition: Bool = false)
    {
        if IsLocked
        {
            if ResetPosition
            {
            ResetCamera()
            }
        }
        self.allowsCameraControl = !IsLocked
    }
    
    var Pop: NSPopover? = nil
    
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
    
    func SetNodeEulerAngles(EditID: UUID, _ Angles: SCNVector3)
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                        ActualNode.eulerAngles = Angles
                    }
                }
            }
        }
    }
    
    func GetNodeEulerAngles(EditID: UUID) -> SCNVector3?
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                    return ActualNode.eulerAngles
                    }
                }
            }
        }
        return nil
    }
    
    func SetNodeLocation(EditID: UUID, _ Latitude: Double, _ Longitude: Double)
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                        ActualNode.Latitude = Latitude
                        ActualNode.Longitude = Longitude
                        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
                        ActualNode.position = SCNVector3(X, Y, Z)
                    }
                }
            }
        }
    }
    
    func GetNodeLocation(EditID: UUID) -> (Latitude: Double, Longitude: Double)?
    {
        for Node in EarthNode!.childNodes
        {
            if let ActualNode = Node as? SCNNode2
            {
                if let ActualNodeEditID = ActualNode.EditID
                {
                    if ActualNodeEditID == EditID
                    {
                    if ActualNode.Latitude == nil && ActualNode.Longitude == nil
                    {
                        return nil
                    }
                    return (ActualNode.Latitude!, ActualNode.Longitude!)
                    }
                }
            }
        }
        return nil
    }
    
    /// Kill all available timers. Called when the program is shutting down.
    func KillTimers()
    {
        EarthClock?.invalidate()
        DarkClock?.invalidate()
    }
    
    // MARK: - Stencil pipeline protocol functions
    
    /// Used to prevent stenciled maps from fighting to be displayed. Helps to enforce serialization.
    var StageSynchronization: NSObject = NSObject()
    
    /// Handle a new stencil map stage available.
    /// - Parameter Image: If nil, take no action. If not nil, display on the map layer of the main shape.
    /// - Parameter Stage: Used mainly for debug purposes - if not nil, contains the stage the the stenciling
    ///                    pipeline just completed. If nil, the image is undefined and should not be used.
    /// - Parameter Time: Duration from the start of the execution of the pipeline to the finish of the stage
    ///                   just completed.
    func StageCompleted(_ Image: NSImage?, _ Stage: StencilStages?, _ Time: Double?)
    {
        objc_sync_enter(StageSynchronization)
        defer{objc_sync_exit(StageSynchronization)}

        if Stage == nil || Time == nil
        {
            return
        }
        if let StenciledImage = Image
        {
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = StenciledImage
            }
        }
    }
    
    /// Called when the stenciling pipeline is completed.
    /// - Notes: `Final` is saved in `InitialStenciledMap` to cache it for when earthquakes need to redraw
    ///          the map asynchronously.
    /// - Parameter Time: The duration for the stenciling pipeline to execute with all passed stages.
    /// - Parameter Final: The final image created.
    func StencilPipelineCompleted(Time: Double, Final: NSImage?)
    {
        if self.InitialStenciledMap == nil
        {
            if let FinalImage = Final
            {
                self.InitialStenciledMap = FinalImage
            }
        }
    }
    
    /// Called at the start of the pipeline execution.
    /// - Parameter Time: The starting time of the execution.
    func StencilPipelineStarted(Time: Double)
    {
    }
    
    func StencilPipelineCompleted2(_ Context: StencilContext)
    {
        if self.InitialStenciledMap == nil
        {
            if let Final = Context.CompletedImage
            {
                self.InitialStenciledMap = Final
            }
        }
    }
    
    func StencilStageCompleted2(_ Context: StencilContext, _ Stage: StencilStages?)
    {
        objc_sync_enter(StageSynchronization)
        defer{objc_sync_exit(StageSynchronization)}
        if Stage == nil
        {
            return
        }
        if let Working = Context.WorkingImage
        {
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = Working
            }
        }
    }
    
    // MARK: - Variables for extensions.
    
    var MouseIsVisible = true
    
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
    
    /// Dark clock timer.
    var DarkClock: Timer!
    
    var InFollowMode: Bool = false
    var FollowModeNode: SCNNode2? = nil
    var MouseIndicator: SCNNode2? = nil
    var IndicatorLongitude: Double = 0.0
    var IndicatorLatitude: Double = 0.0
    var IndicatorLatitudeDirection: Double = 1.0
    let LongitudeIncrement = 0.19
    let LatitudeIncrement = 0.23
    public var CameraObserver: NSKeyValueObservation? = nil
    public var FLCameraObserver: NSKeyValueObservation? = nil
    var OldPointOfView: SCNVector3? = nil
    var Camera: SCNCamera = SCNCamera()
    
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
    
    // MARK: - User camera variables.
    
    var CameraPointOfView: SCNVector3? = nil
    var CameraOrientation: SCNQuaternion? = nil
    var CameraRotation: SCNVector4? = nil
    var FlatlandCamera: SCNCamera? = nil
    var FlatlandCameraNode: SCNNode? = nil
    //var FlatlandCameraLocation = SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue)
    var MouseLocations = Queue<NSEvent>(WithCapacity: 5)
    
    var DebugXAxis: SCNNode2? = nil
    var DebugYAxis: SCNNode2? = nil
    var DebugZAxis: SCNNode2? = nil
    
    var InitialStenciledMap: NSImage? = nil
    
    // MARK: - World clock management.
    
    /// If true, the clock is decoupled from the Earth and no ration occurs.
    var DecoupleClock = false
    var ClockMultiplier: Double = 1.0
    var PreviousPrettyPercent: Double? = nil
    var PrettyPercent = 0.0
    var EarthClock: Timer? = nil
    var PreviousLongitudePercent: Double? = nil
    
    var PreviousHourFlatnessLevel: CGFloat? = nil
    var PreviousCityFlatnessLevel: CGFloat? = nil
    var PreviousCameraDistance: Int? = nil
    let FlatnessDistanceMap: [(FlatLevel: CGFloat, Min: Int, Max: Int)] =
        [
            (0.001, 0, 60),
            (0.005, 61, 80),
            (0.01, 81, 100),
            (0.05, 101, 109),
            (0.08, 110, 120),
            (0.1, 121, 150),
            (0.3, 151, 200),
            (0.5, 201, 500),
            (1.0, 501, 10000)
        ]
    
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
    /// Holds all of the regions.
    var RegionNode: SCNNode2? = nil
    var RegionLayer: CAShapeLayer? = nil
    var TransientRegionNode: SCNNode2? = nil
    var TransientRegionLayer: CAShapeLayer? = nil
    var PlottedEarthquakes = Set<String>()
    var POIMenu: NSMenuItem? = nil
    var AddEditHomeMenu: NSMenuItem? = nil
    var RunAddEditDialogMenu: NSMenuItem? = nil
    var SetHomeAtMouseMenu: NSMenuItem? = nil
    var QuakeMenu: NSMenuItem? = nil
    var ResetMenu: NSMenuItem? = nil
    var LockMenu: NSMenuItem? = nil
    var FollowMenu: NSMenuItem? = nil
    var UnderMouseMenu: NSMenuItem? = nil
    var MapTypeMenu: NSMenuItem? = nil
    var NCenter: NSMenuItem? = nil
    var SCenter: NSMenuItem? = nil
    var RectMap: NSMenuItem? = nil
    var CubicMapMenu: NSMenuItem? = nil
    var GlobeMapMenu: NSMenuItem? = nil
    var TimeTypeMenu: NSMenuItem? = nil
    var TimeMenu: NSMenuItem? = nil
    var NoTimeMenu: NSMenuItem? = nil
    var SolarTimeMenu: NSMenuItem? = nil
    var PinnedTimeMenu: NSMenuItem? = nil
    var DeltaTimeMenu: NSMenuItem? = nil
    var ClearSearchMenu: NSMenuItem? = nil
    #if DEBUG
    var DebugMenu: NSMenuItem? = nil
    var RotateTo0Menu: NSMenuItem? = nil
    var RotateTo90Menu: NSMenuItem? = nil
    var RotateTo180Menu: NSMenuItem? = nil
    var RotateTo270Menu: NSMenuItem? = nil
    var CoupleTimerMenu: NSMenuItem? = nil
    var MoveCameraTestMenu: NSMenuItem? = nil
    var CameraDebugMenu: NSMenuItem? = nil
    var SpinCameraTestMenu: NSMenuItem? = nil
    #endif
    // The current mouse location over the Earth. If the mouse is not over the Earth, this value is set
    // to nil.
    var CurrentMouseLocation: CGPoint? = nil
    var SearchedNodeIcons: [SCNNode2] = [SCNNode2]()
    
    var CurrentMouseLatitude: Double = 0.0
    var CurrentMouseLongitude: Double = 0.0
    
    // MARK: - Region editing variables.
    var RegionEditorOpen: Bool = false
    var InRegionCreationMode: Bool = false
    var OldLockState: Bool = false
    var MouseClickReceiver: RegionMouseClickProtocol? = nil
    var UpperLeftNode: SCNNode2? = nil
    var LowerRightNode: SCNNode2? = nil
    var MousePointerType: MousePointerTypes = .Normal
    var MostRecentMouseLatitude: Double = 0.0
    var MostRecentMouseLongitude: Double = 0.0
    var TransientRegions = [UserRegion]()
    var RadialContainer: [RadialLayer] = [RadialLayer]()
    var RadialRadiusOffset: CGFloat = RadialConstants.RadialRadiusOffset.rawValue
    
    var WallClockTimer: Timer? = nil
    var WallStartAngle: Double = 0.0
    var WallScaleMultiplier: Double = 1.0
    var WallLetterColor: NSColor = NSColor.red
    var LastWallClockTime: String? = nil
    
    var PreviousMemory: Int64? = nil
    var CumulativeMemory: Int64 = 0
}


