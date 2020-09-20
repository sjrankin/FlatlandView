//
//  FlatView.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Implement's Flatland's flat mode in a 3D scene.
class FlatView: SCNView, SettingChangedProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
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
    
    /// Initialize the view.
    func InitializeView()
    {
        Settings.AddSubscriber(self)
        
        #if DEBUG
        showsStatistics = true
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
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = NSColor.clear
        self.antialiasingMode = .multisampling2X
        self.isJitteringEnabled = true
        
        CreateCamera()
        CreateLights()
        AddEarth()
        StartClock()
        UpdateEarthView()
        AddHourLayer()
        AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
        AddNightMaskLayer()
        AddGridLayer()
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
    
    func CreateCamera()
    {
        RemoveNodeWithName(GlobeNodeNames.FlatlandCameraNode.rawValue)
        Camera = SCNCamera()
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
        Camera.fieldOfView = Settings.GetCGFloat(.FieldOfView, Defaults.FieldOfView)
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
    var CameraNode: SCNNode = SCNNode()
    
    /// Remove all nodes with the specified name from the scene's root node.
    /// - Parameter Name: The name of the node to remove. *Must match exactly.*
    /// - Parameter FromParent: If not nil, the parent node from which nodes are removed. If nil,
    ///                         nodes are removed from the scene's root node.
    func RemoveNodeWithName(_ Name: String, FromParent: SCNNode? = nil)
    {
        if let Parent = FromParent
        {
            for Node in Parent.childNodes
            {
                if Node.name == Name
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                }
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
    
    func CreateLights()
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
        
        let BackNode = SCNNode()
        BackNode.light = Ambient
        BackNode.position = SCNVector3(0.0, 0.0, -Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(BackNode)
    }
    
    /// Remove the ambient light from the scene.
    func RemoveAmbientLight()
    {
        AmbientLightNode?.removeAllActions()
        AmbientLightNode?.removeFromParentNode()
        AmbientLightNode = nil
    }
    
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
    var LightNode = SCNNode()
    var GridLight1 = SCNLight()
    var GridLightNode1 = SCNNode()
    var GridLight2 = SCNLight()
    var GridLightNode2 = SCNNode()
    var MoonNode: SCNNode? = nil
    
    var AmbientLightNode: SCNNode? = nil
    
    func AddEarth()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.FlatThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        FlatEarthNode = SCNNode(geometry: Flat)
        let Image = NSImage(named: "SimplePoliticalWorldMapSouthCenter")
        SetEarthMap(Image!)
        FlatEarthNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlatEarthNode.position = SCNVector3(0.0, 0.0, 0.0)
        FlatEarthNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0)
        self.scene?.rootNode.addChildNode(FlatEarthNode)
    }
    
    /// Creates a shape to be used to hold the night mask.
    func AddNightMaskLayer()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.NightMaskThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        NighMaskNode = SCNNode(geometry: Flat)
        NighMaskNode.geometry?.firstMaterial?.diffuse.contents = nil
        NighMaskNode.position = SCNVector3(0.0, 0.0, 0.0)
        NighMaskNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 90.0.Radians)
        self.scene?.rootNode.addChildNode(NighMaskNode)
    }
    
    func AddGridLayer()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.GridLayerThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        GridNode = SCNNode(geometry: Flat)
        GridNode.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        GridNode.position = SCNVector3(0.0, 0.0, 0.0)
        GridNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 90.0.Radians)
        self.scene?.rootNode.addChildNode(GridNode)
        PopulateGrid()
    }
    
    var GridNode = SCNNode()
    var NighMaskNode = SCNNode()
    
    func AddHourLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.HourRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.HourRadius.rawValue * 2.0))
        HourPlane = SCNNode(geometry: Flat)
        HourPlane.categoryBitMask = LightMasks.Sun.rawValue
        HourPlane.name = NodeNames2D.HourPlane.rawValue
        HourPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        HourPlane.geometry?.firstMaterial?.isDoubleSided = true
        HourPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        HourPlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        HourPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(HourPlane)
    }
    
    var HourPlane = SCNNode()
    
    func PopulateGrid()
    {
        for Node in GridNode.childNodes
        {
            Node.removeFromParentNode()
        }
        let EquatorLocation = CGFloat(FlatConstants.FlatRadius.rawValue) / 2.0
        let CancerLocation = (CGFloat(FlatConstants.FlatRadius.rawValue) * (90.0 + 23.4366) / 180.0)
        let CapricornLocation = (CGFloat(FlatConstants.FlatRadius.rawValue) * (90.0 - 23.4366) / 180.0)
        let ArcticLocation = CGFloat(FlatConstants.FlatRadius.rawValue * (90.0 + 66.56) / 180.0)
        let AntarcticLocation = CGFloat(FlatConstants.FlatRadius.rawValue * (90.0 - 66.56) / 180.0)
        let Equator = MakeRing(Radius: EquatorLocation)
        let CancerRing = MakeRing(Radius: CancerLocation)
        let CapricornRing = MakeRing(Radius: CapricornLocation)
        let ArcticRing = MakeRing(Radius: ArcticLocation)
        let AntarcticRing = MakeRing(Radius: AntarcticLocation)
        GridNode.addChildNode(Equator)
        GridNode.addChildNode(CancerRing)
        GridNode.addChildNode(CapricornRing)
        GridNode.addChildNode(ArcticRing)
        GridNode.addChildNode(AntarcticRing)
        let Center = CGFloat(FlatConstants.FlatRadius.rawValue / 2.0)
        let VLine = MakeVerticalLine(At: Center, Height: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        let HLine = MakeHorizontalLine(At: Center, Width: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        GridNode.addChildNode(VLine)
        GridNode.addChildNode(HLine)
    }
    
    func MakeVerticalLine(At: CGFloat, Height: CGFloat) -> SCNNode
    {
        let LineShape = SCNBox(width: Height, height: 0.1, length: 0.1, chamferRadius: 0.0)
        let LineNode = SCNNode(geometry: LineShape)
        LineNode.name = NodeNames2D.GridNodes.rawValue
        LineNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        LineNode.position = SCNVector3(0.0, 0.0, 0.0)
        return LineNode
    }
    
    func MakeHorizontalLine(At: CGFloat, Width: CGFloat) -> SCNNode
    {
        let LineShape = SCNBox(width: 0.1, height: 0.1, length: Width, chamferRadius: 0.0)
        let LineNode = SCNNode(geometry: LineShape)
        LineNode.name = NodeNames2D.GridNodes.rawValue
        LineNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        LineNode.position = SCNVector3(0.0, 0.0, 0.0)
        return LineNode
    }
    
    func MakeRing(Radius: CGFloat) -> SCNNode
    {
        let RingShape = SCNTorus(ringRadius: Radius, pipeRadius: 0.06)
        let RingNode = SCNNode(geometry: RingShape)
        RingShape.ringSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        RingShape.pipeSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        RingNode.name = NodeNames2D.GridNodes.rawValue
        RingNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        RingNode.position = SCNVector3(0.0, 0.0, 0.0)
        return RingNode
    }
    
    func AddNightMask()
    {
        if let Mask = Utility.GetNightMask(ForDate: Date())
        {
            AddNightMask(Mask)
        }
    }
    
    /// Add the night mask image to the night mask node.
    /// - Parameter Image: The night mask image to add.
    func AddNightMask(_ Image: NSImage)
    {
        let ImageTiff = Image.tiffRepresentation
        var CImage = CIImage(data: ImageTiff!)
        let Transform = CGAffineTransform(scaleX: -1, y: 1)
        CImage = CImage?.transformed(by: Transform)
        let CImageRep = NSCIImageRep(ciImage: CImage!)
        let Final = NSImage(size: CImageRep.size)
        Final.addRepresentation(CImageRep)
        NighMaskNode.geometry?.firstMaterial?.diffuse.contents = Final
    }
    
    /// Hide the night mask.
    func HideNightMask()
    {
        NighMaskNode.geometry?.firstMaterial?.diffuse.contents = nil
    }
    
    /// Set the 2D earth map.
    /// - Parameter NewImage: The image to use for the view.
    func SetEarthMap(_ NewImage: NSImage)
    {
        let ImageTiff = NewImage.tiffRepresentation
        var CImage = CIImage(data: ImageTiff!)
        let Transform = CGAffineTransform(scaleX: -1, y: 1)
        CImage = CImage?.transformed(by: Transform)
        let CImageRep = NSCIImageRep(ciImage: CImage!)
        let Final = NSImage(size: CImageRep.size)
        Final.addRepresentation(CImageRep)
        FlatEarthNode.geometry?.firstMaterial?.diffuse.contents = Final
    }
    
    var FlatEarthNode = SCNNode()
    
    func StartClock()
    {
        EarthClock = Timer.scheduledTimer(timeInterval: Defaults.EarthClockTick.rawValue,
                                          target: self, selector: #selector(UpdateEarthView),
                                          userInfo: nil, repeats: true)
        EarthClock?.tolerance = Defaults.EarthClockTickTolerance.rawValue
        RunLoop.current.add(EarthClock!, forMode: .common)
    }
    
    var EarthClock: Timer? = nil
    
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
    
    var PreviousPercent = 0.0
    
    /// Convert the passed time (in terms of percent of a day) into a radian.
    /// - Parameter From: The percent of the day that has passed.
    /// - Parameter With: Offset value to subtract from the number of degrees intermediate value.
    /// - Returns: Radial equivalent of the time percent.
    func MakeRadialTime(From Percent: Double, With Offset: Double) -> Double
    {
        let Degrees = 360.0 * Percent + Offset
        return Degrees * Double.pi / 180.0
    }
    
    func UpdateEarth(With Percent: Double)
    {
        let FlatViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        PreviousPercent = Percent
        var FinalOffset = 180.0
        var Multiplier = -1.0
        if FlatViewType == .FlatSouthCenter
        {
            FinalOffset = 90.0
            Multiplier = -1.0
        }
        //Be sure to rotate the proper direction based on the map.
        let MapRadians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
        let Duration = UseInitialRotation ? FlatConstants.InitialRotation.rawValue : FlatConstants.NormalRotation.rawValue
        UseInitialRotation = false
        let RotateAction = SCNAction.rotateTo(x: CGFloat(90.0.Radians),
                                              y: CGFloat(180.0.Radians),
                                              z: CGFloat(MapRadians),
                                              duration: Duration,
                                              usesShortestUnitArc: true)
        FlatEarthNode.runAction(RotateAction)
        GridNode.runAction(RotateAction)
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
        {
            FinalOffset = 90.0 + 15.0 * 3
            let HourRadians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
            let HourRotateAction = SCNAction.rotateTo(x: 0.0,
                                                      y: 0.0,
                                                      z: CGFloat(HourRadians),
                                                      duration: Duration,
                                                      usesShortestUnitArc: true)
            HourPlane.runAction(HourRotateAction)
        }
        else
        {
            HourPlane.eulerAngles = SCNVector3(CGFloat(0.0.Radians),
                                               CGFloat(0.0.Radians),
                                               CGFloat(0.0.Radians))
        }
    }
    
    private var UseInitialRotation = true
    
    
    private var ClassID = UUID()
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    func AddHours(HourRadius: Double)
    {
        RemoveNodeWithName(NodeNames2D.HourNodes.rawValue, FromParent: HourPlane)
        switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        {
            case .None:
                //Nothing to do here since all hours have already been removed.
                break
                
            case .Solar:
                MakeSolarHours(HourRadius: HourRadius)
                
            case .RelativeToNoon:
                MakeNoonRelativeHours(HourRadius: HourRadius)
                
            case .RelativeToLocation:
                MakeRelativetoLocationHours(HourRadius: HourRadius)
        }
    }
    
    func MakeSolarHours(HourRadius: Double)
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapCenter == .FlatNorthCenter
        {
            //Stride never returns the `to` value (depsite the parameter name - this is by design for some
            //strange reason) so we have to set the terminal value to -1 to get the 0.
            for Hour in stride(from: 23, to: -1, by: -1)
            {
                let Angle = abs(Double(Hour - 23 - 1))
                Debug.Print("Hour \(Hour) has angle \(Angle * 15.0)")
                HourPlane.addChildNode(MakeHour(Hour, AtAngle: Angle, Radius: HourRadius))
            }
        }
        else
        {
            for Hour in 0 ... 23
            {
                HourPlane.addChildNode(MakeHour(Hour, AtAngle: Double(Hour), Radius: HourRadius))
            }
        }
    }
    
    /// Draws hours relative to noon.
    func MakeNoonRelativeHours(HourRadius: Double)
    {

        for Hour in 0 ... 23
        {
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            DisplayHour = DisplayHour - 12
            HourPlane.addChildNode(MakeHour(DisplayHour, AtAngle: Double(DisplayHour + 12), Radius: HourRadius,
                                            AddPrefix: true))
        }
    }
    
    func MakeRelativetoLocationHours(HourRadius: Double)
    {
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        HourList = HourList.Shift(By: -12)
        if let LocalLongitude = Settings.GetDoubleNil(.LocalLongitude)
        {
            let Long = Int(LocalLongitude / 15.0)
            HourList = HourList.Shift(By: Long)
            for Hour in 0 ... 23
            {
                let DisplayHour = Hour % 24
                let FinalHour = HourList[DisplayHour]
                HourPlane.addChildNode(MakeHour(FinalHour, AtAngle: Double(FinalHour), Radius: HourRadius,
                                                AddPrefix: true))
            }
        }
    }
    
    func UpdateHours()
    {
        RemoveNodeWithName(NodeNames2D.HourNodes.rawValue)
        AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
    }
    
    func MakeHour(_ Hour: Int, AtAngle: Double, Radius: Double, Scale: Double = FlatConstants.HourScale.rawValue,
                  AddPrefix: Bool = false) -> SCNNode
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        var Offset = 0.0
        if MapCenter == .FlatSouthCenter
        {
            Offset = 180.0
        }
        var Angle = (AtAngle * 15.0) + Offset
        Angle = fmod(Angle, 360.0)
        var Prefix = ""
        if AddPrefix
        {
            if Hour > 0
            {
                Prefix = "+"
            }
        }
        let HourText = "\(Prefix)\(Hour)"
        let HourShape = SCNText(string: HourText, extrusionDepth: CGFloat(FlatConstants.HourExtrusion.rawValue))
        let FontData = Settings.GetFont(.HourFontName, StoredFont("Avenir-Medium", 20.0, NSColor.yellow))
        HourShape.font = NSFont(name: FontData.PostscriptName, size: 25.0)
        HourShape.flatness = CGFloat(FlatConstants.HourFlatness.rawValue)
        if Settings.GetBool(.UseHourChamfer)
        {
            HourShape.chamferRadius = CGFloat(FlatConstants.HourChamfer.rawValue)
        }
        let Node = SCNNode(geometry: HourShape)
        Node.name = NodeNames2D.HourNodes.rawValue
        Node.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.HourColor, NSColor.systemOrange)
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        let FinalAngle = (Angle - 90.0) * -1
        let Radians = FinalAngle.Radians
        let X = Radius * cos(Radians)
        let Y = Radius * sin(Radians)
        var XDelta = Double(Node.boundingBox.max.x - Node.boundingBox.min.x) / 2.0
        XDelta = XDelta * Scale
        var YDelta = Double(Node.boundingBox.max.y - Node.boundingBox.min.y) / 2.0
        YDelta = YDelta * Scale
        Node.pivot = SCNMatrix4MakeTranslation(CGFloat(XDelta) * 20, 0.0, 0.0)
        Node.position = SCNVector3(X, Y, 0.0)
        let NodeRotation = (FinalAngle - 90.0).Radians
        Node.eulerAngles = SCNVector3(0.0, 0.0, NodeRotation)
        Node.scale = SCNVector3(Scale, Scale, Scale)
        
        return Node
    }
    
    func ApplyNewMap(_ NewMapImage: NSImage)
    {
        
    }
    
    func PlotEarthquakes(_ Quakes: [Earthquake], Replot: Bool)
    {
        
    }
    
    /// Handle setting changes that affect us.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The setting value before the change. May be nil.
    /// - Parameter NewValue: The setting value after the change. May be nil.
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .MapType:
                let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let CurrentView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                if [.FlatNorthCenter, .FlatSouthCenter].contains(CurrentView)
                {
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: CurrentView)
                    {
                        SetEarthMap(MapImage)
                    }
                }
                
            case .ShowNight:
                if Settings.GetBool(.ShowNight)
                {
                    AddNightMask()
                }
                else
                {
                    HideNightMask()
                }
                
            case .NightDarkness:
                if Settings.GetBool(.ShowNight)
                {
                    AddNightMask()
                }
                
            case .HourType:
                AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
                
            case .UseHDRCamera:
                CameraNode.camera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
                
            case .Earthquake2DStyles:
                break
                
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
        
        Debug.Print("Setting \(Setting) handled in FlatView")
    }
    
    func RotateImageTo(_ Percent: Double)
    {
        
    }
}
