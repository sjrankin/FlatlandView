//
//  NodeRotationController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class NodeRotationController: NSViewController
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CurrentLatitude.stringValue = ""
        CurrentLongitude.stringValue = ""
        LatitudeField.stringValue = ""
        LongitudeField.stringValue = ""
        CurrentX.stringValue = ""
        CurrentY.stringValue = ""
        CurrentZ.stringValue = ""
        XTextField.stringValue = ""
        YTextField.stringValue = ""
        XTextField.stringValue = ""
        RadianSwitch.state = .on
        DegreeInputSwitch.state = .on
    }
    
    var IsInRadians = true
    var InputInDegrees = true
    let TestNodeID = UUID(uuidString: "a70f71ca-1fa6-43eb-8fa1-dcae38011ed2")!
    var OriginalEuler: SCNVector3? = nil
    
    override func viewDidAppear()
    {
        UpdateCurrent()
    }
    
    func UpdateCurrent()
    {
        if let First = MainDelegate?.GetNodeEulerAngles(EditID: TestNodeID)
        {
            OriginalEuler = First
            if IsInRadians
            {
                CurrentX.stringValue = "\(First.x.RoundedTo(2))"
                CurrentY.stringValue = "\(First.y.RoundedTo(2))"
                CurrentZ.stringValue = "\(First.z.RoundedTo(2))"
            }
            else
            {
                let DX = First.x.Degrees.RoundedTo(2)
                let DY = First.y.Degrees.RoundedTo(2)
                let DZ = First.z.Degrees.RoundedTo(2)
                CurrentX.stringValue = "\(DX)°"
                CurrentY.stringValue = "\(DY)°"
                CurrentZ.stringValue = "\(DZ)°"
            }
        }
        else
        {
            print("Error getting node")
        }
        if let (Latitude, Longitude) = MainDelegate?.GetNodeLocation(EditID: TestNodeID)
        {
            CurrentLatitude.stringValue = Latitude.RoundedTo(2)
            CurrentLongitude.stringValue = Longitude.RoundedTo(2)
        }
    }
    
    func GetEulerComponent(From: NSTextField) -> Double
    {
        if let DValue = Double(From.stringValue)
        {
            if InputInDegrees
            {
                return DValue.Radians
            }
            else
            {
                return DValue
            }
        }
        return 0.0
    }
    
    func GetEulerValues() -> SCNVector3
    {
        let X = GetEulerComponent(From: XTextField)
        let Y = GetEulerComponent(From: YTextField)
        let Z = GetEulerComponent(From: ZTextField)
        return SCNVector3(X, Y, Z)
    }
    
    @IBAction func HandleSetPressed(_ sender: Any)
    {
        let Euler = GetEulerValues()
        MainDelegate?.SetNodeEulerAngles(EditID: TestNodeID, Euler)
    }
    
    @IBAction func HandleRadianSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            IsInRadians = Switch.state == .on ? true : false
            UpdateCurrent()
        }
    }
    
    @IBAction func HandleSetLocationButton(_ sender: Any)
    {
        var FinalLat: Double = 0.0
        guard Double(LatitudeField.stringValue) != nil else
        {
            return
        }
        
        let LatResult = InputValidation.LatitudeValidation(LatitudeField.stringValue)
        switch LatResult
        {
            case .success(let Lat):
                FinalLat = Lat
                
            case .failure(let Why):
                let _ = Why
                FinalLat = 0.0
                LatitudeField.stringValue = "0.0"
        }
        
        var FinalLon: Double = 0.0
        guard Double(LongitudeField.stringValue) != nil else
        {
            return
        }
        
        let LonResult = InputValidation.LongitudeValidation(LongitudeField.stringValue)
        switch LonResult
        {
            case .success(let Lon):
                FinalLon = Lon
                
            case .failure(let Why):
                let _ = Why
                FinalLon = 0.0
                LongitudeField.stringValue = "0.0"
        }
        
        MainDelegate?.SetNodeLocation(EditID: TestNodeID, FinalLat, FinalLon)
    }
    
    @IBAction func HandleRadianInputSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            InputInDegrees = Switch.state == .on ? true : false
        }
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @objc dynamic var TableData = [DebugNodeType]()
    
    @IBOutlet weak var CurrentLongitude: NSTextField!
    @IBOutlet weak var CurrentLatitude: NSTextField!
    @IBOutlet weak var LongitudeField: NSTextField!
    @IBOutlet weak var LatitudeField: NSTextField!
    @IBOutlet weak var DegreeInputSwitch: NSSwitch!
    @IBOutlet weak var RadianSwitch: NSSwitch!
    @IBOutlet weak var CurrentX: NSTextField!
    @IBOutlet weak var CurrentY: NSTextField!
    @IBOutlet weak var CurrentZ: NSTextField!
    @IBOutlet weak var XTextField: NSTextField!
    @IBOutlet weak var YTextField: NSTextField!
    @IBOutlet weak var ZTextField: NSTextField!
}


@objcMembers class DebugNodeType: NSObject
{
    dynamic var NodeClass: String = ""
    dynamic var NodeName: String = ""
}
