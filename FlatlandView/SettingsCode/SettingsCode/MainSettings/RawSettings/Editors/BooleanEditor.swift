//
//  BooleanEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BooleanEditor: NSViewController, EditorProtocol
{
    public weak var Delegate: RawSettingsProtocol? = nil
    
    func AssignDelegate(_ DelegateProtocol: RawSettingsProtocol?)
    {
        Delegate = DelegateProtocol
        SettingNameLabel.stringValue = Delegate!.GetSettingName()
        SettingKey = SettingTypes(rawValue: Delegate!.GetSettingName())
    }
    
    func LoadValue(_ Value: Any?, _ Type: String)
    {
        if let OldBool = Value as? Bool
        {
            NewBoolValue.state = OldBool ? .on : .off
            OldBoolValue.stringValue = OldBool ? "True" : "False"
        }
    }
    
    var SettingKey: SettingTypes? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleSavePressed(_ sender: Any)
    {
        Delegate?.ClearDirty(SettingKey!)
        Settings.SetBool(SettingKey!, NewBoolValue.state == .on ? true : false)
    }
    
    @IBAction func HandleNewBoolValue(_ sender: Any)
    {
        Delegate?.SetDirty(SettingKey!)
    }
    
    @IBOutlet weak var OldBoolValue: NSTextField!
    @IBOutlet weak var NewBoolValue: NSSwitch!
    @IBOutlet weak var SettingNameLabel: NSTextField!
}
