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
    
    func AssignDelegate(_ DelegateProtocol: RawSettingsProtocol?)
    {
        Delegate = DelegateProtocol
        SettingNameLabel.stringValue = Delegate!.GetSettingName()
        SettingKey = SettingTypes(rawValue: Delegate!.GetSettingName())
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
