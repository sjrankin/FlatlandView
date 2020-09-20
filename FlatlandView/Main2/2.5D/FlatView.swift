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
    
    var Camera: SCNCamera = SCNCamera()
    var CameraNode: SCNNode = SCNNode()
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
    var NighMaskNode = SCNNode()
    var GridNode = SCNNode()
    var HourPlane = SCNNode()
    var CityPlane = SCNNode()
    
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
        CityPlane.runAction(RotateAction)
        if Settings.GetBool(.ShowCities)
        {
            if FlatViewType == .FlatNorthCenter
            {
                FinalOffset = 270.0
            }
            else
            {
            FinalOffset = 180.0
            }
            let CityRadians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
            let CityRotateAction = SCNAction.rotateTo(x: 0.0,
                                                      y: 0.0,
                                                      z: CGFloat(CityRadians),
                                                      duration: Duration,
                                                      usesShortestUnitArc: true)
            CityPlane.runAction(CityRotateAction)
        }
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
        {
            FinalOffset = 90.0 + 15.0 * 3
            let HourRadians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
            LastRelativeTimeRadial = HourRadians
            print("Last relative time radial = \((LastRelativeTimeRadial * 180.0 / Double.pi).RoundedTo(3))°")
            let LastAngle = LastRelativeTimeRadial * 180.0 / Double.pi
            let Delta = fmod(180.0 - LastAngle, 360.0)
            print("  Delta with 180° = \(Delta.RoundedTo(3))°")
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
    
    private var LastRelativeTimeRadial: Double = -1
    private var UseInitialRotation = true
    
    var ClassID = UUID()

    
    func ApplyNewMap(_ NewMapImage: NSImage)
    {
        
    }
    
    func PlotEarthquakes(_ Quakes: [Earthquake], Replot: Bool)
    {
        
    }
    
    func RotateImageTo(_ Percent: Double)
    {
        
    }

    var CitiesToPlot = [City]()
    
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
}
