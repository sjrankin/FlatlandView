//
//  RectangleView.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Implement's Flatland's equirectilinear mode in a 3D scene.
class RectangleView: SCNView, SettingChangedProtocol, FlatlandEventProtocol
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
    
    /// Handle new time from the world clock.
    /// - Parameter WorldDate: Contains the new date and time.
    func NewWorldClockTime(WorldDate: Date)
    {
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
        if DoDebug && DebugMap == .Rectangular
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
            self.debugOptions = []
        }
    }
    #endif
    
    var Camera: SCNCamera = SCNCamera()
    var CameraNode: SCNNode = SCNNode()
    var SunLight = SCNLight()
    var LightNode = SCNNode()
    var GridLight = SCNLight()
    var GridLightNode = SCNNode()
    var AmbientLightNode: SCNNode? = nil
    var AmbientSunLightNode = SCNNode()
    var HourLight = SCNLight()
    var HourLightNode = SCNNode()
    var RectNightMaskNode = SCNNode()
    var GridNode = SCNNode2()
    var HourPlane = SCNNode2()
    var CityPlane = SCNNode2()
    var PolarLight = SCNLight()
    var PolarNode = SCNNode2()
    var QuakePlane = SCNNode2()
    var UNESCOPlane = SCNNode2()
    
    func KillTimers()
    {
        EarthClock?.invalidate()
    }
    
    /// Set the 2D, rectangular earth map.
    /// - Parameter NewImage: The image to use for the view.
    func SetEarthMap(_ NewImage: NSImage)
    {
        let ImageTiff = NewImage.tiffRepresentation
        var CImage = CIImage(data: ImageTiff!)
        let Transform = CGAffineTransform(scaleX: -1, y: -1)
        CImage = CImage?.transformed(by: Transform)
        let CImageRep = NSCIImageRep(ciImage: CImage!)
        let Final = NSImage(size: CImageRep.size)
        Final.addRepresentation(CImageRep)
        FlatEarthNode.geometry?.firstMaterial?.diffuse.contents = Final
    }
    
    func StartClock()
    {
        EarthClock = Timer.scheduledTimer(timeInterval: 1.0,//Defaults.EarthClockTick.rawValue,
                                          target: self, selector: #selector(UpdateNightMask),
                                          userInfo: nil, repeats: true)
        EarthClock?.tolerance = Defaults.EarthClockTickTolerance.rawValue
        RunLoop.current.add(EarthClock!, forMode: .common)
        UpdateNightMask()
    }
    
    var EarthClock: Timer? = nil
    
    /// Called periodically to update the rotation of the Earth. Regardless of the frequency of
    /// being called, the Earth will always be updated to the correct position when called. However,
    /// if this function is called too infrequently, the Earth will show jerky motion as it rotates.
    /// - Note: When compiled in #DEBUG mode, code is included for debugging time functionality but
    ///         only when the proper settings are enabled.
    @objc func UpdateNightMask()
    {
        OperationQueue.main.addOperation
        {
            let PrettyPercent = self.GetPercentTimeUTC()
            self.NightMaskImage = Utility.GetRectangularNightMask(ForDate: Date())
            self.AdjustNightMask(With: PrettyPercent)
        }
    }
    
    /// Holds the source night mask image.
    var NightMaskImage: NSImage? = nil
    
    /// Get the time in UTC as a percent of the day.
    /// - Returns: UTC time expressed in terms of percent of a day.
    func GetPercentTimeUTC() -> Double
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
        return PrettyPercent
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
    
    private var LastRelativeTimeRadial: Double = -1
    private var UseInitialRotation = true
    
    var ClassID = UUID()
    
    func ApplyNewMap(_ NewMapImage: NSImage)
    {
        
    }
    
    /// Plot the passed set of earthquakes.
    /// - Parameter Quakes: The set of earthquakes to plot. Earthquakes will be filtered elsewhere.
    /// - Parameter Replot: If true, earthquakes will be cleared before being plotted.
    func PlotEarthquakes(_ Quakes: [Earthquake], Replot: Bool)
    {
        Plot2DEarthquakes(Quakes, Replot: Replot)
    }
    
    /// Plot the saved set of earthquakes.
    func PlotSameEarthquakes()
    {
        if PreviousEarthquakes.count < 1
        {
            Remove2DEarthquakes()
            return
        }
        PlotPrevious2DEarthquakes()
    }
    
    func RotateImageTo(_ Percent: Double)
    {
        
    }
    
    /// Resets the default camera to its original location.
    /// - Note: In order to prevent the Earth from flying around wildly during the reset transition, a
    ///         look-at constraint is added for the duration of the transition, and removed once the rotation
    ///         transition is completed.
    func ResetCamera()
    {
        let Constraint = SCNLookAtConstraint(target: FlatEarthNode)
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
    
    /// Update the lights to show or hide shadows in 2D mode.
    /// - Parameter ShowShadows: Value that determines whether shadows are shown or not.
    func UpdateLightsForShadows(ShowShadows: Bool)
    {
        if ShowShadows
        {
            SunLight.intensity = 0.0
            UpdatePolarLight(With: PrimaryLightMultiplier)
            PolarLight.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue)
            //FlatEarthNode.categoryBitMask = LightMasks2D.Polar.rawValue
        }
        else
        {
            //FlatEarthNode.categoryBitMask = LightMasks2D.Sun.rawValue
            SunLight.intensity = CGFloat(FlatConstants.SunLightIntensity.rawValue)
            PolarLight.intensity = 0
        }
    }
    
    #if false
    /// Handle mouse motion reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseClickedAt(Point: CGPoint)
    {
        let HitObject = self.hitTest(Point, options: [.boundingBoxOnly: true])
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
                    if PreviousNode != nil
                    {
                        if Settings.GetBool(.HighlightNodeUnderMouse)
                        {
                            PreviousNode?.HideBoundingShape()
                        }
                    }
                    if let NodeData = NodeTables.GetItemData(For: NodeID)
                    {
                        if Settings.GetBool(.HighlightNodeUnderMouse)
                        {
                            Node.ShowBoundingShape(.Sphere,
                                                   LineColor: NSColor.red,
                                                   SegmentCount: 10)
                        }
                        PreviousNode = Node
                        MakePopOver(At: Point, For: NodeData)
                    }
                }
            }
            else
            {
                Pop?.performClose(self)
            }
        }
    }
    
    func MouseMovedTo(Point: CGPoint)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.Rectangular) == .Rectangular
        {
            if InFollowMode
            {
                let SearchOptions: [SCNHitTestOption: Any] =
                    [
                        .searchMode: SCNHitTestSearchMode.closest.rawValue,
                        .ignoreHiddenNodes: true,
                        .ignoreChildNodes: true,
                        .rootNode: self.FlatEarthNode as Any
                    ]
                let HitObject = self.hitTest(Point, options: SearchOptions)
                if HitObject.count > 0
                {
                    if HitObject[0].node.self is SCNNode2
                    {
                        let Where = HitObject[0].worldCoordinates
                        if test == nil
                        {
                            test = MakeMousePointer()
                            FlatEarthNode.addChildNode(test!)
                        }
                        let RawPosition = SCNVector3(-Where.x,
                                                     -0.75,
                                                     -Where.y)
                        let (Lat, Lon) = Geometry.ConvertRectangleToGeo(Point: RawPosition, Width: RectMode.MapWidth.rawValue,
                                                                       Height: RectMode.MapHeight.rawValue)
                        test?.position = RawPosition
                        MainDelegate?.MouseAtLocation(Latitude: Lat, Longitude: Lon, Caller: #function)
                    }
                }
            }
        }
    }
    #endif
    
    func MakeMousePointer() -> SCNNode2
    {
        let top = SCNCone(topRadius: 0.0, bottomRadius: 0.25, height: 0.5)
        let bottom = SCNCone(topRadius: 0.25, bottomRadius: 0.0, height: 0.5)
        let topnode = SCNNode2(geometry: top)
        let bottomnode = SCNNode2(geometry: bottom)
        topnode.categoryBitMask = LightMasks2D.Polar.rawValue
        bottomnode.categoryBitMask = LightMasks2D.Polar.rawValue
        topnode.position = SCNVector3(0.0, 0.5, 0.0)
        topnode.geometry?.firstMaterial?.diffuse.contents = NSColor.systemOrange
        bottomnode.geometry?.firstMaterial?.diffuse.contents = NSColor.yellow
        let final = SCNNode2()
        final.addChildNode(topnode)
        final.addChildNode(bottomnode)
        return final
    }
    
    var test: SCNNode2? = nil
    
    #if false
    func MakePopOver(At: CGPoint, For: ItemToDisplay)
    {
        if let PopController = NSStoryboard(name: "Popovers", bundle: nil).instantiateController(withIdentifier: "POIPopover") as? POIPopover
        {
            Pop = NSPopover()
            Pop?.contentSize = NSSize(width: 376, height: 159)
            Pop?.behavior = .semitransient
            Pop?.animates = true
            Pop?.contentViewController = PopController
            Pop?.show(relativeTo: NSRect(x: At.x, y: At.y, width: 10.0, height: 10.0), of: self, preferredEdge: .minX)
            PopController.ItemToDisplay(For)
            PopController.SetSelf(Pop!)
        }
    }
    #endif
    
    func SetCameraLock(_ IsLocked: Bool)
    {
        if IsLocked
        {
            ResetCamera()
        }
        self.allowsCameraControl = !IsLocked
    }
    
    var Pop: NSPopover? = nil
    
    var FlatEarthNode = SCNNode2()
    var InFollowMode: Bool = true
    var FollowModeNode: SCNNode2? = nil
    var PreviousNode: SCNNode2? = nil
    var PreviousNodeID: UUID? = nil
    var NodesWithShadows = [SCNNode]()
    var Quakes2D = [Earthquake]()
    var PreviousEarthquakes = [Earthquake]()
    var WHSNodeList = [SCNNode2]()
    var SunNode = SCNNode2()
    var CitiesToPlot = [City2]()
    var POIsToPlot = [POI]()
    var PrimaryLightMultiplier: Double = 1.0
    var PreviousNightMaskValue: Double? = nil
    var HorizontalShift = 0
    var MouseIndicator: SCNNode2? = nil
    
    var FollowMenu: NSMenuItem? = nil
    var POIMenu: NSMenuItem? = nil
    var QuakeMenu: NSMenuItem? = nil
    var ResetMenu: NSMenuItem? = nil
    var LockMenu: NSMenuItem? = nil
    var SunMenu: NSMenuItem? = nil
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
}
