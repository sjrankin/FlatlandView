//
//  ClockControlPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ClockControlPanel: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear()
    {
        let Multiplier = Settings.GetDouble(.Debug_ClockActionClockMultiplier, 0.0)
        ClockMultiplierText.stringValue = "\(Multiplier)"
        let Angle = Settings.GetDouble(.Debug_ClockActionClockAngle, 0.0)
        ClockAngleText.stringValue = "\(Angle)"
        let FreezeWhen = Settings.GetDate(.Debug_ClockActionFreezeTime, Date())
        FreezeTimePicker.dateValue = FreezeWhen
        let MapType = Settings.GetEnum(ForKey: .Debug_ClockDebugMap, EnumType: Debug_MapTypes.self, Default: .Globe)
        switch MapType
        {
            case .Globe:
                MapSegment.selectedSegment = 2
                
            case .Round:
                MapSegment.selectedSegment = 1
                
            case .Rectangular:
                MapSegment.selectedSegment = 0
        }
        FreezeSwitch.state = Settings.GetBool(.Debug_ClockActionFreeze) ? .on : .off
        FreezeAtSwitch.state = Settings.GetBool(.Debug_ClockActionFreezeAtTime) ? .on : .off
        ClockAngleSwitch.state = Settings.GetBool(.Debug_ClockActionSetClockAngle) ? .on : .off
        MultiplierActiveSwitch.state = Settings.GetBool(.Debug_ClockUseTimeMultiplier) ? .on : .off
        EnableSwitch.state = Settings.GetBool(.Debug_EnableClockControl) ? .on : .off
    }
    
    @IBAction func HandleEnableSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.Debug_EnableClockControl, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleActionSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.Debug_ClockActionFreeze, false)
            Settings.SetBool(.Debug_ClockActionFreezeAtTime, false)
            Settings.SetBool(.Debug_ClockActionSetClockAngle, false)
            Settings.SetBool(.Debug_ClockUseTimeMultiplier, false)
            FreezeSwitch.state = Switch == FreezeSwitch ? .on : .off
            FreezeAtSwitch.state = Switch == FreezeAtSwitch ? .on : .off
            ClockAngleSwitch.state = Switch == ClockAngleSwitch ? .on : .off
            MultiplierActiveSwitch.state = Switch == MultiplierActiveSwitch ? .on : .off

            switch Switch
            {
                case FreezeSwitch:
                    Settings.SetBool(.Debug_ClockActionFreeze, true)
                    
                case FreezeAtSwitch:
                    Settings.SetBool(.Debug_ClockActionFreezeAtTime, true)
                    
                case ClockAngleSwitch:
                    Settings.SetBool(.Debug_ClockActionSetClockAngle, true)
                    
                case MultiplierActiveSwitch:
                    Settings.SetBool(.Debug_ClockUseTimeMultiplier, true)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleMapTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var NewMapType = Debug_MapTypes.Globe
            switch Segment.selectedSegment
            {
                case 0:
                    NewMapType = .Rectangular
                    
                case 1:
                    NewMapType = .Round
                    
                case 2:
                    NewMapType = .Globe
                    
                default:
                    return
            }
            Settings.SetEnum(NewMapType, EnumType: Debug_MapTypes.self, ForKey: .Debug_ClockDebugMap)
        }
    }

    @IBAction func NewFreezeTime(_ sender: Any)
    {
        if let TimePicker = sender as? NSDatePicker
        {
            let NewTime = TimePicker.dateValue
            Settings.SetDate(.Debug_ClockActionFreezeTime, NewTime)
        }
    }
    
    func DoubleFrom(_ TextField: NSTextField) -> Double
    {
        if let Valid = Double(TextField.stringValue)
        {
            return Valid
        }
        return 0.0
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case ClockMultiplierText:
                    var Multiplier = DoubleFrom(TextField)
                    if Multiplier < -100.0
                    {
                        Multiplier = -100.0
                        TextField.stringValue = "-100.0"
                    }
                    if Multiplier > 100.0
                    {
                        Multiplier = 100.0
                        TextField.stringValue = "100.0"
                    }
                    Settings.SetDouble(.Debug_ClockActionClockMultiplier, Multiplier)
                    
                case ClockAngleText:
                    var Angle = DoubleFrom(TextField)
                    if Angle < 0.0
                    {
                        Angle = 0.0
                        TextField.stringValue = "0.0"
                    }
                    if Angle > 360.0
                    {
                        Angle = 360.0
                        TextField.stringValue = "360.0"
                    }
                    Settings.SetDouble(.Debug_ClockActionClockAngle, Angle)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var ClockMultiplierText: NSTextField!
    @IBOutlet weak var ClockAngleText: NSTextField!
    @IBOutlet weak var MultiplierActiveSwitch: NSSwitch!
    @IBOutlet weak var FreezeAtSwitch: NSSwitch!
    @IBOutlet weak var FreezeTimePicker: NSDatePicker!
    @IBOutlet weak var MapSegment: NSSegmentedControl!
    @IBOutlet weak var EnableSwitch: NSSwitch!
    @IBOutlet weak var ClockAngleSwitch: NSSwitch!
    @IBOutlet weak var FreezeSwitch: NSSwitch!
}
