//
//  EnumEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EnumEditor: NSViewController, EditorProtocol
{
    var EnumTypeName: String = ""
    var SettingKey: SettingTypes? = nil
    
    public weak var Delegate: RawSettingsProtocol? = nil
    /*
    {
        didSet
        {
            let SettingKeyName = Delegate?.GetSettingName()
            SettingNameLabel.stringValue = Delegate!.GetSettingName()
            if let SettingType = SettingKeyName
            {
                EnumTypeName = "\(SettingType)"
                SettingKey = SettingTypes(rawValue: SettingKeyName!)
                Settings.GetValue(For: SettingKey!)
                {
                    Result in
                    switch Result
                    {
                        case .failure(let ErrorType):
                            self.OldEnumValue.stringValue = "\(ErrorType)"
                            
                        case .success(let (SettingValue, _)):
                            let EnumValues = self.Delegate?.GetEnumCases()
                            self.EnumCombo.removeAllItems()
                            for EnumValue in EnumValues!
                            {
                                self.EnumCombo.addItem(withObjectValue: EnumValue)
                            }
                            if let OldValue = SettingValue as? String
                            {
                                self.EnumCombo.selectItem(withObjectValue: OldValue)
                                self.OldEnumValue.stringValue = OldValue
                            }
                    }
                }
            }
        }
    }
 */
    
    func AssignDelegate(_ DelegateProtocol: RawSettingsProtocol?)
    {
        Delegate = DelegateProtocol
        SettingNameLabel.stringValue = Delegate!.GetSettingName()
    }
    
    func LoadValue(_ Value: Any?, _ Type: String)
    {
        let EnumValues = Delegate?.GetEnumCases()
        EnumCombo.removeAllItems()
        for EnumValue in EnumValues!
        {
            EnumCombo.addItem(withObjectValue: EnumValue)
        }
        if let OldValue = Value as? String
        {
            EnumCombo.selectItem(withObjectValue: OldValue)
            OldEnumValue.stringValue = OldValue
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleSavePressed(_ sender: Any)
    {
       if let Selected = EnumCombo.objectValueOfSelectedItem as? String
       {
        Delegate?.SetEnumValue(SettingKey!, Selected)
        Delegate?.ClearDirty(SettingKey!)
       }
    }
    
    @IBAction func HandleEnumComboChanged(_ sender: Any)
    {
        Delegate?.SetDirty(SettingKey!)
    }
    
    @IBOutlet weak var OldEnumValue: NSTextField!
    @IBOutlet weak var EnumCombo: NSComboBox!
    @IBOutlet weak var SettingNameLabel: NSTextField!
}
