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
    
    /// Hide the globe view.
    public func Hide()
    {
        if EarthClock != nil
        {
            EarthClock?.invalidate()
            EarthClock = nil
        }
        self.isHidden = true
    }
    
    /// Show the globe view.
    public func Show()
    {
        StartClock()
        self.isHidden = false
    }
    
    public var CameraObserver: NSKeyValueObservation? = nil
    
    /// Initialize the globe view.
    func InitializeView()
    {
        //        self.debugOptions = [.showBoundingBoxes, .renderAsWireframe]
        self.allowsCameraControl = true
        
        #if false
        //Enable for debugging and getting initial location of the automatical camera. Otherwise,
        //not needed at run-time. Not intended to be deleted.
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
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        Camera.zFar = 500
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 16.0)
        
        SetSunlight()
        SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
        self.scene?.rootNode.addChildNode(CameraNode)
        
        AddEarth()
        StartClock()
        UpdateEarthView()
        SetHourResetTimer()
    }
    
    /// Resets the default camera to its original location.
    func ResetCamera()
    {
        #if true
        let PositionAction = SCNAction.move(to: SCNVector3(0.0, 0.0, 16.0), duration: 0.7)
        self.pointOfView?.runAction(PositionAction)
        let RotationAction = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: 0.7)
        self.pointOfView?.runAction(RotationAction)
        //self.pointOfView?.orientation = SCNQuaternion(0.0, 0.0, 0.0, 1.0)
        #else
        self.pointOfView?.position = SCNVector3(0.0, 0.0, 16.0)
        self.pointOfView?.orientation = SCNQuaternion(0.0, 0.0, 0.0, 1.0)
        self.pointOfView?.rotation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        #endif
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
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = SCNLight()
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
        print("Set moonlight to \(Show)")
        if Show
        {
            let MoonLight = SCNLight()
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
        }
        else
        {
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
        }
    }
    
    var SunLight = SCNLight()
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var MoonNode: SCNNode? = nil
    
    func SetDisplayLanguage()
    {
        
    }
    
    func SetClockMultiplier(_ Multiplier: Double)
    {
        //        ClockMultiplier = Multiplier
        //AddEarth(FastAnimate: true)
    }
    
    func StopClock()
    {
        EarthClock?.invalidate()
        EarthClock = nil
    }
    
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
        #if false
        let Now = Date()
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        var TimeZoneAbbreviation = ""
        if Settings.GetTimeLabel() == .UTC
        {
            TimeZoneAbbreviation = "UTC"
        }
        else
        {
            TimeZoneAbbreviation = GetLocalTimeZoneID() ?? "UTC"
        }
        let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
        Formatter.timeZone = TZ
        let Final = Formatter.string(from: Now)
        let FinalText = Final + " " + TimeZoneAbbreviation
        TimeLabel.text = FinalText
        #else
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        #endif
        
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
        
        let EarthSphere = SCNSphere(radius: 10.01)
        EarthSphere.segmentCount = 100
        let SeaSphere = SCNSphere(radius: 10)
        SeaSphere.segmentCount = 100
        
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        var BaseMap: NSImage? = nil
        var SecondaryMap = NSImage()
        BaseMap = MapManager.ImageFor(MapType: MapType, ViewType: .Globe3D)
        if BaseMap == nil
        {
            fatalError("Error retrieving base map \(MapType).")
        }
        switch MapType
        {
            case .Standard:
                SecondaryMap = MapManager.ImageFor(MapType: .StandardSea, ViewType: .Globe3D)!
            
            case .TectonicOverlay:
                SecondaryMap = MapManager.ImageFor(MapType: .Dithered, ViewType: .Globe3D)!
            
            default:
                break
        }
        
        EarthNode = SCNNode(geometry: EarthSphere)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        //Precondition the surfaces.
        switch MapType
        {
            case .Debug2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
            
            case .Debug5:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
            
            case .TectonicOverlay:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
            
            case .ASCIIArt1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
            
            case .BlackWhiteShiny:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Standard:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = SecondaryMap
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .blinn
            
            case .SimpleBorders2:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue 
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Topographical1:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.systemBlue
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.white
                SeaNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Pink:
                SeaNode = SCNNode(geometry: SeaSphere)
                SeaNode?.position = SCNVector3(0.0, 0.0, 0.0)
                SeaNode?.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
                SeaNode?.geometry?.firstMaterial?.specular.contents = NSColor.yellow
                EarthNode?.geometry?.firstMaterial?.lightingModel = .phong
            
            case .Bronze:
                EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.orange
                SeaNode = SCNNode(geometry: SeaSphere)
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
        }
        
        PlotLocations(On: EarthNode!, WithRadius: 10)
        
        let SeaMapList: [MapTypes] = [.Standard, .Topographical1, .SimpleBorders2, .Pink, .Bronze,
                                      .TectonicOverlay, .BlackWhiteShiny, .ASCIIArt1, .Debug2,
                                      .Debug5]
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
    /// - Parameter Radius: The radius of the sphere holding the lines. Default is `10.2` which is
    ///                     slightly over the Earth.
    func SetLineLayer(Radius: CGFloat = 10.2)
    {
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        LineNode = nil
        if Settings.GetBool(.Show3DGridLines)
        {
            let LineSphere = SCNSphere(radius: Radius)
            LineSphere.segmentCount = 100
            LineNode = SCNNode(geometry: LineSphere)
            LineNode?.position = SCNVector3(0.0, 0.0, 0.0)
            let Maroon = NSColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
            let GridLineImage = MakeGridLines(Width: 3600, Height: 1800, LineColor: Maroon)
            LineNode?.geometry?.firstMaterial?.diffuse.contents = GridLineImage
            //LineNode?.geometry?.firstMaterial?.emission.contents = Maroon
            LineNode?.castsShadow = false
            SystemNode?.addChildNode(self.LineNode!)
        }
    }
    
    #if false
    /// Finds and removes all sub-nodes in `Parent` with the specified name.
    /// - Parameter Parent: The parent node whose sub-nodes are checked for nodes to remove.
    /// - Parameter Named: Name of the sub-node to remove. All sub-nodes with this name will be removed.
    func RemoveNodeFrom(Parent Node: SCNNode, Named: String)
    {
        for Child in Node.childNodes
        {
            if Child.name == Named
            {
                Child.removeAllActions()
                Child.removeFromParentNode()
            }
        }
    }
    #endif
    
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
    
    // MARK: - GlobeProtocol functions
    
    func PlotSatellite(Satellite: Satellites, At: GeoPoint2)
    {
        let SatelliteAltitude = 10.5 * (At.Altitude / 6378.1)
        let (X, Y, Z) = ToECEF(At.Latitude, At.Longitude, Radius: SatelliteAltitude)
    }
    
    // MARK: - Variables for extensions.
    
    /// List of hours in Japanese Kanji.
    let JapaneseHours = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九",
                         "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七",
                         "十八", "十九", "二十", "二十一", "二十二", "二十三", "二十四"]
    
    var NorthPoleFlag: SCNNode? = nil
    var SouthPoleFlag: SCNNode? = nil
    var NorthPolePole: SCNNode? = nil
    var SouthPolePole: SCNNode? = nil
    var HomeNode: SCNNode? = nil
    var HomeNodeHalo: SCNNode? = nil
    var PlottedCities = [SCNNode?]()
    var WHSNodeList = [SCNNode?]()
    
    var GridImage: NSImage? = nil
}

