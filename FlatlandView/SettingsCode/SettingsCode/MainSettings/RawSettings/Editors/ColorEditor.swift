//
//  ColorEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ColorEditor: NSViewController, EditorProtocol
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
        if let OldColor = Value as? NSColor
        {
            OldColorWell.color = OldColor
            NewColorWell.color = OldColor
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
        Settings.SetColor(SettingKey!, NewColorWell.color)
    }
    
    @IBAction func HandleNewColorChanged(_ sender: Any)
    {
        Delegate?.SetDirty(SettingKey!)
    }
    
    @IBOutlet weak var NewColorWell: NSColorWell!
    @IBOutlet weak var OldColorWell: NSColorWell!
    @IBOutlet weak var SettingNameLabel: NSTextField!
}
