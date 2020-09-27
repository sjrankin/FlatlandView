//
//  GeneralEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class GeneralEditor: NSViewController, NSTextFieldDelegate, EditorProtocol
{
    public weak var Delegate: RawSettingsProtocol? = nil
    
    func AssignDelegate(_ DelegateProtocol: RawSettingsProtocol?)
    {
        Delegate = DelegateProtocol
        SettingNameLabel.stringValue = Delegate!.GetSettingName()
        TypeNameLabel.stringValue = Delegate!.GetSettingType()
        FieldType = Delegate!.GetSettingType()
        SettingKey = SettingKeys(rawValue: Delegate!.GetSettingName())
    }
    
    var FieldType: String = ""
    
    func LoadValue(_ Value: Any?, _ Type: String)
    {
        switch Type
        {
            case "Int":
                if let IVal = Value as? Int
                {
                    OldValueField.stringValue = "\(IVal)"
                    NewValueField.stringValue = "\(IVal)"
                }
                
            case "Double":
                if let DVal = Value as? Double
                {
                    OldValueField.stringValue = "\(DVal)"
                    NewValueField.stringValue = "\(DVal)"
                }
                
            case "Double?":
                if let DNVal = Value as? Double?
                {
                    OldValueField.stringValue = "\(DNVal!)"
                    NewValueField.stringValue = "\(DNVal!)"
                }
                else
                {
                    OldValueField.stringValue = ""
                    NewValueField.stringValue = ""
                }
                
            case "CGFloat":
                if let DVal = Value as? CGFloat
                {
                    OldValueField.stringValue = "\(DVal)"
                    NewValueField.stringValue = "\(DVal)"
                }
                
            case "CGFloat?":
                if let DNVal = Value as? CGFloat?
                {
                    OldValueField.stringValue = "\(DNVal!)"
                    NewValueField.stringValue = "\(DNVal!)"
                }
                else
                {
                    OldValueField.stringValue = ""
                    NewValueField.stringValue = ""
                }
                
            case "String":
                if let SVal = Value as? String
                {
                    OldValueField.stringValue = SVal
                    NewValueField.stringValue = SVal
                }
                
            default:
                return
        }
    }
    
    var SettingKey: SettingKeys? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NewValueField.stringValue = ""
    }
    
    @IBAction func HandleSavePressed(_ sender: Any)
    {
        ProcessRawText(NewValueField.stringValue)
        Delegate?.ClearDirty(SettingKey!)
    }
    
    func ProcessRawText(_ Raw: String)
    {
        switch FieldType
        {
            case "Int":
                if let IVal = Int(Raw)
                {
                    Settings.SetInt(SettingKey!, IVal)
                }
                
            case "Double":
                if let DVal = Double(Raw)
                {
                    Settings.SetDouble(SettingKey!, DVal)
                }
                
            case "Double?":
                if Raw.isEmpty
                {
                    Settings.SetDoubleNil(SettingKey!, nil)
                }
                else
                {
                    if let DVal = Double(Raw)
                    {
                        Settings.SetDoubleNil(SettingKey!, DVal)
                    }
                }
                
            case "CGFloat":
                if let DVal = Double(Raw)
                {
                    let CVal = CGFloat(DVal)
                    Settings.SetCGFloat(SettingKey!, CVal)
                }
                
            case "CGFloat?":
                if Raw.isEmpty
                {
                    Settings.SetCGFloatNil(SettingKey!, nil)
                }
                else
                {
                    if let DVal = Double(Raw)
                    {
                        let CVal = CGFloat(DVal)
                        Settings.SetCGFloatNil(SettingKey!, CVal)
                    }
                }
                
            case "String":
                Settings.SetString(SettingKey!, Raw)
            default:
                return
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let _ = obj.object as? NSTextField
        {
            Delegate?.SetDirty(SettingKey!)
        }
    }
    
    @IBOutlet weak var OldValueField: NSTextField!
    @IBOutlet weak var NewValueField: NSTextField!
    @IBOutlet weak var SettingNameLabel: NSTextField!
    @IBOutlet weak var TypeNameLabel: NSTextField!
}
