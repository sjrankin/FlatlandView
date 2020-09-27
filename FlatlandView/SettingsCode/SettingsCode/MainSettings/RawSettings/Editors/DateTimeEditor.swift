//
//  DateTimeEditor.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DateTimeEditor: NSViewController, EditorProtocol
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
        if let OldDate = Value as? Date
        {
            OldDateTimeValue.stringValue = "\(OldDate)"
            NewDate.dateValue = OldDate
            NewTime.dateValue = OldDate
        }
    }
    
    var SettingKey: SettingKeys? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleSavePressed(_ sender: Any)
    {
        let UpdatedDate = NewDate.dateValue
        let UpdatedTime = NewTime.dateValue
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: UpdatedTime)
        let Minute = Cal.component(.minute, from: UpdatedTime)
        let Second = Cal.component(.second, from: UpdatedTime)
        let Day = Cal.component(.day, from: UpdatedDate)
        let Month = Cal.component(.month, from: UpdatedDate)
        let Year = Cal.component(.year, from: UpdatedDate)
        var FinalComponents = DateComponents()
        FinalComponents.year = Year
        FinalComponents.month = Month
        FinalComponents.day = Day
        FinalComponents.hour = Hour
        FinalComponents.minute = Minute
        FinalComponents.second = Second
        let Final = Cal.date(from: FinalComponents)
        Settings.SetDate(SettingKey!, Final!)
        Delegate?.ClearDirty(SettingKey!)
    }
    
    @IBAction func HandleNewDate(_ sender: Any)
    {
        Delegate?.SetDirty(SettingKey!)
    }
    
    @IBAction func HandleNewTime(_ sender: Any)
    {
        Delegate?.SetDirty(SettingKey!)
    }
    
    @IBOutlet weak var NewTime: NSDatePicker!
    @IBOutlet weak var NewDate: NSDatePicker!
    @IBOutlet weak var OldDateTimeValue: NSTextField!
    @IBOutlet weak var SettingNameLabel: NSTextField!
}
