//
//  DebugSettingsCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DebugSettingsCode: NSViewController, NSTextFieldDelegate
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
        let Ortho = Settings.GetCGFloat(.CameraOrthographicScale, 15.0).RoundedTo(2)
        OrthographicScaleField.stringValue = "\(Ortho)"
        let FOV = Settings.GetCGFloat(.CameraFieldOfView, 90.0)
        let FOVS = "\(Int(FOV))"
        FlatlandFieldOfViewCombo.selectItem(withObjectValue: FOVS)
        SystemCameraSwitch.state = Settings.GetBool(.UseSystemCameraControl) ? .on : .off
        EnableZoomSwitch.state = Settings.GetBool(.EnableZooming) ? .on : .off
        EnableDragSwitch.state = Settings.GetBool(.EnableDragging) ? .on : .off
        EnableMoveSwitch.state = Settings.GetBool(.EnableMoving) ? .on : .off
        let Projection = Settings.GetEnum(ForKey: .CameraProjection, EnumType: CameraProjections.self,
                                          Default: .Perspective)
        switch Projection
        {
            case .Orthographic:
                CameraProjectionSegment.selectedSegment = 1
                
            case .Perspective:
                CameraProjectionSegment.selectedSegment = 0
        }
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
    
    @IBAction func HandleSystemCameraSwitch(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.UseSystemCameraControl, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleFlatlandCameraControls(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            let SwitchEnabled = Switch.state == .on ? true: false
            switch Switch
            {
                case EnableZoomSwitch:
                    Settings.SetBool(.EnableZooming, SwitchEnabled)
                    
                case EnableDragSwitch:
                    Settings.SetBool(.EnableDragging, SwitchEnabled)
                    
                case EnableMoveSwitch:
                    Settings.SetBool(.EnableMoving, SwitchEnabled)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleFOVComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Value = Combo.objectValueOfSelectedItem as? String
            {
                if let DValue = Double(Value)
                {
                    Settings.SetCGFloat(.CameraFieldOfView, CGFloat(DValue))
                }
            }
            else
            {
                print("Error converting FOV combo value to string")
            }
        }
    }
    
    @IBAction func HandleCameraProjectionChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(.Perspective, EnumType: CameraProjections.self, ForKey: .CameraProjection)
                    
                case 1:
                    Settings.SetEnum(.Orthographic, EnumType: CameraProjections.self, ForKey: .CameraProjection)
                    
                default:
                    return
            }
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let RawValue = TextField.stringValue
            if let DValue = Double(RawValue)
            {
                Settings.SetCGFloat(.CameraOrthographicScale, CGFloat(DValue))
            }
        }
    }
    
    @IBAction func HandleRawSettingsButtonPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "RawSettingsEditor", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "RawSettingsWindow") as? RawSettingsWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
    @IBOutlet weak var OrthographicScaleField: NSTextField!
    @IBOutlet weak var CameraProjectionSegment: NSSegmentedControl!
    @IBOutlet weak var FlatlandFieldOfViewCombo: NSComboBox!
    @IBOutlet weak var EnableZoomSwitch: NSSwitch!
    @IBOutlet weak var EnableDragSwitch: NSSwitch!
    @IBOutlet weak var EnableMoveSwitch: NSSwitch!
    @IBOutlet weak var SystemCameraSwitch: NSSwitch!
    @IBOutlet weak var EnableStopTime: NSSwitch!
    @IBOutlet weak var TimeMultiplierCombo: NSComboBox!
    @IBOutlet weak var StopAtTimeSetter: NSDatePicker!
    @IBOutlet weak var TimeControlSegment: NSSegmentedControl!
    @IBOutlet weak var DebugTimeSwitch: NSSwitch!
    @IBOutlet weak var TestTimeSetter: NSDatePicker!
}
