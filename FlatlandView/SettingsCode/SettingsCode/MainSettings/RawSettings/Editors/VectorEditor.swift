//
//  VectorEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class VectorEditor: NSViewController, NSTextFieldDelegate, EditorProtocol
{
    public weak var Delegate: RawSettingsProtocol? = nil
    
    func AssignDelegate(_ DelegateProtocol: RawSettingsProtocol?)
    {
        Delegate = DelegateProtocol
        SettingNameLabel.stringValue = Delegate!.GetSettingName()
        SettingKey = SettingKeys(rawValue: Delegate!.GetSettingName())
    }
    
    func LoadValue(_ Value: Any?, _ Type: String)
    {
        if let Vector = Value as? SCNVector3
        {
            var OldValue = ""
            OldValue.append("\(Vector.x.RoundedTo(5))")
            OldValue.append(", ")
            OldValue.append("\(Vector.y.RoundedTo(5))")
            OldValue.append(", ")
            OldValue.append("\(Vector.z.RoundedTo(5))")
            OldVectorValue.stringValue = OldValue
            NewX.stringValue = "\(Vector.x.RoundedTo(5))"
            NewY.stringValue = "\(Vector.y.RoundedTo(5))"
            NewZ.stringValue = "\(Vector.z.RoundedTo(5))"
        }
    }
    
    var SettingKey: SettingKeys? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleSavePressed(_ sender: Any)
    {
        let NewVector = ParseVector()
        Settings.SetVector(SettingKey!, NewVector)
        Delegate?.ClearDirty(SettingKey!)
    }
    
    func ParseVector() -> SCNVector3
    {
        var RawX = NewX.stringValue
        var RawY = NewY.stringValue
        var RawZ = NewZ.stringValue
        if RawX.isEmpty
        {
           RawX = "0.0"
        }
        if RawY.isEmpty
        {
            RawY = "0.0"
        }
        if RawZ.isEmpty
        {
            RawZ = "0.0"
        }
        var X: Double = 0.0
        var Y: Double = 0.0
        var Z: Double = 0.0
        if let TestX = Double(RawX)
        {
            X = TestX
        }
        if let TestY = Double(RawY)
        {
            Y = TestY
        }
        if let TestZ = Double(RawZ)
        {
            Z = TestZ
        }
        return SCNVector3(X, Y, Z)
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let _ = obj.object as? NSTextField
        {
            Delegate?.SetDirty(SettingKey!)
        }
    }

    @IBOutlet weak var OldVectorValue: NSTextField!
    @IBOutlet weak var NewX: NSTextField!
    @IBOutlet weak var NewY: NSTextField!
    @IBOutlet weak var NewZ: NSTextField!
    @IBOutlet weak var SettingNameLabel: NSTextField!
}
