//
//  +OtherSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
    func InitializeOtherSettings()
    {
        
        ShowLocalDataCheck.state = Settings.GetBool(.ShowLocalData) ? .on : .off
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
        ShowSecondsCheck.state = Settings.GetBool(.TimeLabelSeconds) ? .on : .off
    }
    
    @IBAction func HandleShowLocalDataCheckChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowLocalData, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleShowLocalDataCheckChanged")
        }
    }
    
    @IBAction func HandleScriptComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Final = Scripts(rawValue: Raw)
                {
                    Settings.SetEnum(Final, EnumType: Scripts.self, ForKey: .Script)
                    MainDelegate?.Refresh("MainSettings.HandleScriptComboChanged")
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
            MainDelegate?.Refresh("MainSettings.HandleTimeLabelChanged")
        }
    }
    
    @IBAction func HandleShowSecondsChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.TimeLabelSeconds, Button.state == .on ? true : false)
        }
    }
}
