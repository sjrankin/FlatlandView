//
//  DebugSettingsCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DebugSettingsCode: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeDebugSettings()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func InitializeDebugSettings()
    {
        #if DEBUG
        DebugTimeSwitch.state = Settings.GetBool(.DebugTime) ? .on : .off
        let TimeControl = Settings.GetEnum(ForKey: .TimeControl, EnumType: TimeControls.self, Default: .Run)
        if TimeControl == .Run
        {
            TimeControlSegment.selectedSegment = 0
        }
        else
        {
            TimeControlSegment.selectedSegment = 1
        }
        TimeMultiplierCombo.removeAllItems()
        TimeMultiplierCombo.addItem(withObjectValue: "0.5")
        TimeMultiplierCombo.addItem(withObjectValue: "1.0")
        TimeMultiplierCombo.addItem(withObjectValue: "2.0")
        TimeMultiplierCombo.addItem(withObjectValue: "5.0")
        TimeMultiplierCombo.addItem(withObjectValue: "10.0")
        TimeMultiplierCombo.addItem(withObjectValue: "100.0")
        TimeMultiplierCombo.addItem(withObjectValue: "600.0")
        TimeMultiplierCombo.addItem(withObjectValue: "1200.0")
        let Multiplier = Settings.GetDouble(.TimeMultiplier, 1.0)
        TimeMultiplierCombo.selectItem(withObjectValue: "\(String.WithTrailingZero(Multiplier))")
        TestTimeSetter.timeZone = TimeZone(abbreviation: "UTC")!
        StopAtTimeSetter.timeZone = TimeZone(abbreviation: "UTC")!
        let TestTime = Settings.GetDate(.TestTime, Date())
        TestTimeSetter.dateValue = TestTime
        let TimeBreakpoint = Settings.GetDate(.StopTimeAt, Date())
        StopAtTimeSetter.dateValue = TimeBreakpoint
        EnableStopTime.state = Settings.GetBool(.EnableStopTime) ? .on : .off
        #endif
    }
    
    @IBAction func HandleDebugTimeChanged(_ sender: Any)
    {
        #if DEBUG
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.DebugTime, Switch.state == .on ? true : false)
        }
        #endif
    }
    
    @IBAction func HandleTimeControlChanged(_ sender: Any)
    {
        #if DEBUG
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            switch Index
            {
                case 0:
                    Settings.SetEnum(.Run, EnumType: TimeControls.self, ForKey: .TimeControl)
                    
                case 1:
                    Settings.SetEnum(.Pause, EnumType: TimeControls.self, ForKey: .TimeControl)
                    
                default:
                    return
            }
        }
        #endif
    }
    
    @IBAction func HandleTestTimeChanged(_ sender: Any)
    {
        #if DEBUG
        if let TimePicker = sender as? NSDatePicker
        {
            print("\(TimePicker.dateValue)")
            Settings.SetDate(.TestTime, TimePicker.dateValue)
        }
        #endif
    }
    
    @IBAction func HandleStopAtTimeChanged(_ sender: Any)
    {
        #if DEBUG
        if let TimePicker = sender as? NSDatePicker
        {
            print("\(TimePicker.dateValue)")
            Settings.SetDate(.StopTimeAt, TimePicker.dateValue)
        }
        #endif
    }
    
    @IBAction func HandleTimeMultiplierChanged(_ sender: Any)
    {
        #if DEBUG
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Final = Double(Raw)
                {
                    Settings.SetDouble(.TimeMultiplier, Final)
                }
            }
        }
        #endif
    }
    
    @IBAction func EnableStopTimeChanged(_ sender: Any)
    {
        #if DEBUG
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.EnableStopTime, Switch.state == .on ? true : false)
        }
        #endif
    }
    
    @IBOutlet weak var EnableStopTime: NSSwitch!
    @IBOutlet weak var TimeMultiplierCombo: NSComboBox!
    @IBOutlet weak var StopAtTimeSetter: NSDatePicker!
    @IBOutlet weak var TimeControlSegment: NSSegmentedControl!
    @IBOutlet weak var DebugTimeSwitch: NSSwitch!
    @IBOutlet weak var TestTimeSetter: NSDatePicker!
}
