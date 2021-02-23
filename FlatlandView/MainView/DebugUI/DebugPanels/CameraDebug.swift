//
//  CameraDebug.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/3/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class CameraDebug: PanelController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        if let POV = Main?.Get3DPointOfView()
        {
            Main3DPOV = POV
            CameraPositionObserver = POV.observe(\.position, options: [.new, .initial])
            {
                (Node, Change) in
                OperationQueue.current?.addOperation
                {
                    let Location = Node.position
                    self.UpdateLocation(Location)
                }
            }
            if CameraPositionObserver == nil
            {
                print("CameraPositionObserver is nil")
            }
            CameraOrientationObserver = POV.observe(\.eulerAngles, options: [.new, .initial])
            {
                (Node, Change) in
                OperationQueue.current?.addOperation
                {
                    let Euler = Node.eulerAngles
                    self.UpdateOrientation(Euler)
                }
            }
            if CameraOrientationObserver == nil
            {
                print("CameraOrientationObserver is nil")
            }
        }
        else
        {
            print("No POV node returned.")
        }
        CameraXLabel.stringValue = ""
        CameraYLabel.stringValue = ""
        CameraZLabel.stringValue = ""
        CameraLatitudeField.stringValue = ""
        CameraLongitudeField.stringValue = ""
        DistanceLabel.stringValue = ""
        RollLabel.stringValue = ""
        YawLabel.stringValue = ""
        PitchLabel.stringValue = ""
        TimePercentLabel.stringValue = ""
        TimePercentDegrees.stringValue = ""
        InclinationLabel.stringValue = ""
        ECEF_X.stringValue = ""
        ECEF_Y.stringValue = ""
        ECEF_Z.stringValue = ""
        FinalLatitudeField.stringValue = ""
        FinalLongitudeField.stringValue = ""
        AltitudeField.stringValue = "175"
    }
    
    var CameraPositionObserver: NSKeyValueObservation? = nil
    var CameraOrientationObserver: NSKeyValueObservation? = nil
    var Main3DPOV: SCNNode? = nil
    
    func UpdateOrientation(_ Euler: SCNVector3)
    {
        PitchLabel.stringValue = "\(Euler.x.RoundedTo(2))"
        YawLabel.stringValue = "\(Euler.y.RoundedTo(2))"
        RollLabel.stringValue = "\(Euler.z.RoundedTo(2))"
    }
    
    func UpdateLocation(_ Location: SCNVector3)
    {
        CameraXLabel.stringValue = "\(Location.x.RoundedTo(2))"
        CameraYLabel.stringValue = "\(Location.y.RoundedTo(2))"
        CameraZLabel.stringValue = "\(Location.z.RoundedTo(2))"
        let Distance = sqrt((Location.x * Location.x) + (Location.y * Location.y) + (Location.z * Location.z))
        DistanceLabel.stringValue = "\(Int(Distance))"
    }
    
    
    @IBAction func HandleGetPOVData(_ sender: Any)
    {
        DoGetPOVData()
    }
    
    func DoGetPOVData()
    {
        if let POV = Main?.Get3DPointOfView()
        {
            UpdateOrientation(POV.eulerAngles)
            UpdateLocation(POV.position)
        }
        let Inclination = Sun.Declination(For: Date())
        InclinationLabel.stringValue = "\(Inclination.RoundedTo(3))°"
        let DayPercent = GetDayPercent()
        TimePercentLabel.stringValue = "\(DayPercent.RoundedTo(3))"
        TimePercentDegrees.stringValue = "\(GetDayDegrees().RoundedTo(3))°"
    }
    
    func GetDayPercent() -> Double
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
        return Percent
    }
    
    func GetDayDegrees() -> Double
    {
        let DayPercent = GetDayPercent()
        return DayPercent * 360.0
    }
    
    func GetLatitude() -> Double?
    {
        if let LatValue = Double(PointToLatitude.stringValue)
        {
            if LatValue < -90.0 || LatValue > 90.0
            {
                SoundManager.Play(ForEvent: .BadInput)
//                NSSound(named: "Tink")?.play()
                return nil
            }
            return LatValue
        }
        else
        {
            if PointToLatitude.stringValue.isEmpty
            {
                PointToLatitude.stringValue = "0"
                return 0.0
            }
            SoundManager.Play(ForEvent: .BadInput)
//            NSSound(named: "Tink")?.play()
            return nil
        }
    }
    
    func GetLongitude() -> Double?
    {
        if let LonValue = Double(PointToLongitude.stringValue)
        {
            if LonValue < -180.0 || LonValue > 180.0
            {
                SoundManager.Play(ForEvent: .BadInput)
//                NSSound(named: "Tink")?.play()
                return nil
            }
            return LonValue
        }
        else
        {
            if PointToLongitude.stringValue.isEmpty
            {
                PointToLongitude.stringValue = "0"
                return 0.0
            }
            SoundManager.Play(ForEvent: .BadInput)
//            NSSound(named: "Tink")?.play()
            return nil
        }
    }
    
    @IBAction func HandleCameraResetButton(_ sender: Any)
    {
        Main?.ResetCameraPosition()
    }
    
    func GetOffsets() -> (Double, Double)
    {
        var LatOffset: Double = 0.0
        var LonOffset: Double = 0.0
        if let TempLat = Double(LatitudeOffset.stringValue)
        {
            LatOffset = TempLat
        }
        if let TempLon = Double(LongitudeOffset.stringValue)
        {
            LonOffset = TempLon
        }
        return (LatOffset, LonOffset)
    }
    
    func GetAltitude() -> Double
    {
        if let Alt = Double(AltitudeField.stringValue)
        {
            return Alt
        }
        else
        {
            AltitudeField.stringValue = "\(Double(Defaults.InitialZ.rawValue))"
            return Double(Defaults.InitialZ.rawValue)
        }
    }
    
    @IBAction func HandleCameraGoButton(_ sender: Any)
    {
        guard let Latitude = GetLatitude() else
        {
            return
        }
        guard let Longitude = GetLongitude() else
        {
            return
        }
        var FinalLatitude = Latitude + abs(Sun.Declination(For: Date()))
        let LonDegrees = GetDayDegrees()
        var FinalLongitude = Longitude + LonDegrees + 180.0
        let (LatitudeOffset, LongitudeOffset) = GetOffsets()
        FinalLatitude = FinalLatitude + LatitudeOffset
        FinalLongitude = FinalLongitude + LongitudeOffset
        FinalLatitudeField.stringValue = "\(FinalLatitude.RoundedTo(2))°"
        FinalLongitudeField.stringValue = "\(FinalLongitude.RoundedTo(2))°"
        let Altitude = GetAltitude()
        let (X, Y, Z) = Geometry.ToECEF(FinalLatitude, FinalLongitude, Radius: Altitude)
        ECEF_X.stringValue = "\(X.RoundedTo(2))"
        ECEF_Y.stringValue = "\(Y.RoundedTo(2))"
        ECEF_Z.stringValue = "\(Z.RoundedTo(2))"
        Main?.PointCamera(At: GeoPoint(FinalLatitude, FinalLongitude))
        let _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(UpdatePOV), userInfo: nil, repeats: false)
    }
    
    @objc func UpdatePOV()
    {
        OperationQueue.main.addOperation
        {
            self.DoGetPOVData()
        }
    }
    
    func GetAngle(From: NSTextField) -> Double?
    {
        if let DVal = Double(From.stringValue)
        {
            if DVal < -360.0 || DVal > 360.0
            {
                return nil
            }
            return DVal
        }
        else
        {
            return nil
        }
    }
    
    @IBAction func HandleSetCameraPitchButton(_ sender: Any)
    {
        guard let Pitch = GetAngle(From: CameraPitchField) else
        {
            return
        }
        guard let Yaw = GetAngle(From: CameraYawField) else
        {
            return
        }
        guard let Roll = GetAngle(From: CameraRollField) else
        {
            return
        }
        Main?.SetCameraOrientation(Pitch: Pitch, Yaw: Yaw, Roll: Roll, ValuesAreRadians: false)
    }
    
    @IBOutlet weak var AltitudeField: NSTextField!
    @IBOutlet weak var ECEF_Z: NSTextField!
    @IBOutlet weak var ECEF_Y: NSTextField!
    @IBOutlet weak var ECEF_X: NSTextField!
    @IBOutlet weak var TimePercentDegrees: NSTextField!
    @IBOutlet weak var TimePercentLabel: NSTextField!
    @IBOutlet weak var InclinationLabel: NSTextField!
    @IBOutlet weak var CameraRollField: NSTextField!
    @IBOutlet weak var CameraYawField: NSTextField!
    @IBOutlet weak var CameraPitchField: NSTextField!
    @IBOutlet weak var PointToLongitude: NSTextField!
    @IBOutlet weak var PointToLatitude: NSTextField!
    @IBOutlet weak var CameraXLabel: NSTextField!
    @IBOutlet weak var CameraLatitudeField: NSTextField!
    @IBOutlet weak var CameraLongitudeField: NSTextField!
    @IBOutlet weak var CameraYLabel: NSTextField!
    @IBOutlet weak var CameraZLabel: NSTextField!
    @IBOutlet weak var DistanceLabel: NSTextField!
    @IBOutlet weak var RollLabel: NSTextField!
    @IBOutlet weak var YawLabel: NSTextField!
    @IBOutlet weak var PitchLabel: NSTextField!
    @IBOutlet weak var LongitudeOffset: NSTextField!
    @IBOutlet weak var LatitudeOffset: NSTextField!
    @IBOutlet weak var FinalLatitudeField: NSTextField!
    @IBOutlet weak var FinalLongitudeField: NSTextField!
}
