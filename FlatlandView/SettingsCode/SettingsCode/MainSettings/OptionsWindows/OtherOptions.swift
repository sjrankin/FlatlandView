//
//  OtherOptions.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class OtherOptions: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeOtherSettings()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func InitializeOtherSettings()
    {
        ScriptCombo.removeAllItems()
        for Script in Scripts.allCases
        {
            ScriptCombo.addItem(withObjectValue: Script.rawValue)
        }
        let CurrentScript = Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
        ScriptCombo.selectItem(withObjectValue: CurrentScript.rawValue)
        let TimeLabelType = Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .None)
        switch TimeLabelType
        {
            case .None:
                TimeLabelSegment.selectedSegment = 0
            
            case .UTC:
                TimeLabelSegment.selectedSegment = 1
            
            case .Local:
                TimeLabelSegment.selectedSegment = 2
        }
        ShowSecondsSwitch.state = Settings.GetBool(.TimeLabelSeconds) ? .on : .off
        AttractModeSwitch.state = Settings.GetBool(.InAttractMode) ? .on : .off
        ShowSplashScreenSwitch.state = Settings.GetBool(.ShowSplashScreen) ? .on : .off
        let SplashDuration = Settings.GetDouble(.SplashScreenDuration, 6.0)
        let Indices = SplashMap.KeyFor(Value: SplashDuration)
        var FinalIndex = 5
        if Indices.count != 0
        {
            FinalIndex = Indices.first!
        }
        SplashDurationSegment.selectedSegment = FinalIndex
    }
    
    let SplashMap: [Int: Double] =
    [
        0: 2.0,
        1: 4.0,
        2: 6.0,
        3: 10.0,
        4: 15.0,
        5: 30.0
    ]
    
    @IBAction func HandleScriptComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Final = Scripts(rawValue: Raw)
                {
                    Settings.SetEnum(Final, EnumType: Scripts.self, ForKey: .Script)
                }
            }
        }
    }
    
    @IBAction func HandleTimeLabelChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let TimeTypes = [TimeLabels.None, TimeLabels.UTC, TimeLabels.Local]
            if Segment.selectedSegment > TimeTypes.count - 1
            {
                return
            }
            Settings.SetEnum(TimeTypes[Segment.selectedSegment], EnumType: TimeLabels.self, ForKey: .TimeLabel)
        }
    }
    
    @IBAction func HandleShowSecondsChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.TimeLabelSeconds, Button.state == .on ? true : false)
        }
    }
    
    
    @IBAction func HandleAttractModeChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.InAttractMode, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleSplashDurationChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            let SplashDuration = SplashMap[Index]!
            print("\(#function): SplashDuration=\(SplashDuration)")
            Settings.SetDouble(.SplashScreenDuration, SplashDuration)
        }
    }
    
    @IBAction func HandleShowSplashScreenChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowSplashScreen, Switch.state == .on ? true : false)
        }
    }
    
    @IBOutlet weak var SplashDurationSegment: NSSegmentedControl!
    @IBOutlet weak var ShowSplashScreenSwitch: NSSwitch!
    @IBOutlet weak var AttractModeSwitch: NSSwitch!
    @IBOutlet weak var TimeLabelSegment: NSSegmentedControl!
    @IBOutlet weak var ShowSecondsSwitch: NSSwitch!
    @IBOutlet weak var ScriptCombo: NSComboBox!
}
