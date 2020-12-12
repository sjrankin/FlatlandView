//
//  GeneralPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class GeneralPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        switch Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: TimeLabels.UTC)
        {
            case .Local:
                TimeFormatSegment.selectedSegment = 2
                
            case .None:
                TimeFormatSegment.selectedSegment = 0
                
            case .UTC:
                TimeFormatSegment.selectedSegment = 1
        }
        ShowSecondsSwitch.state = Settings.GetBool(.TimeLabelSeconds) ? .on : .off
        switch Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers)
        {
            case .Kilometers:
                InputUnitSegment.selectedSegment = 0
                
            case .Miles:
                InputUnitSegment.selectedSegment = 1
        }
        let IFStyle = Settings.GetEnum(ForKey: .InterfaceStyle, EnumType: InterfaceStyles.self,
                                       Default: .Normal)
        switch IFStyle
        {
            case .Minimal:
                InterfaceSegement.selectedSegment = 0
                
            case .Normal:
                InterfaceSegement.selectedSegment = 1
                
            case .Maximum:
                InterfaceSegement.selectedSegment = 2
        }
    }
    
    @IBAction func HandleShowSecondsChanged(_ sender: Any)
    {
     if let Switch = sender as? NSSwitch
     {
        Settings.SetBool(.TimeLabelSeconds, Switch.state == .on ? true : false)
     }
    }
    
    @IBAction func HandleTimeFormatChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.selectedSegment < 0 || Segment.selectedSegment > TimeLabels.allCases.count - 1
            {
                return
            }
            let NewValue = TimeLabels.allCases[Segment.selectedSegment]
            Settings.SetEnum(NewValue, EnumType: TimeLabels.self, ForKey: .TimeLabel)
        }
    }
    
    @IBAction func HandleInputUnitsChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.selectedSegment < 0 || Segment.selectedSegment > InputUnits.allCases.count - 1
            {
                return
            }
            let NewValue = InputUnits.allCases[Segment.selectedSegment]
            Settings.SetEnum(NewValue, EnumType: InputUnits.self, ForKey: .InputUnit)
        }
    }
    
    @IBAction func HandleInterfaceSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.selectedSegment < 0 || Segment.selectedSegment > InterfaceStyles.allCases.count - 1
            {
                return
            }
            let NewValue = InterfaceStyles.allCases[Segment.selectedSegment]
            Settings.SetEnum(NewValue, EnumType: InterfaceStyles.self, ForKey: .InterfaceStyle)
        }
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case IFStyleHelpButton:
                    Parent?.ShowHelp(For: .InterfaceStyle, Where: Button.bounds, What: IFStyleHelpButton)
                    
                case InputUnitHelpButton:
                    Parent?.ShowHelp(For: .InputUnits, Where: Button.bounds, What: InputUnitHelpButton)
                    
                case DateStyleHelpButton:
                    Parent?.ShowHelp(For: .MainDateFormat, Where: Button.bounds, What: DateStyleHelpButton)
                    
                case ShowSecondsHelpButton:
                    Parent?.ShowHelp(For: .ShowSeconds, Where: Button.bounds, What: ShowSecondsHelpButton)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var InputUnitHelpButton: NSButton!
    @IBOutlet weak var ShowSecondsHelpButton: NSButton!
    @IBOutlet weak var DateStyleHelpButton: NSButton!
    @IBOutlet weak var IFStyleHelpButton: NSButton!
    @IBOutlet weak var InterfaceSegement: NSSegmentedControl!
    @IBOutlet weak var TimeFormatSegment: NSSegmentedControl!
    @IBOutlet weak var ShowSecondsSwitch: NSSwitch!
    @IBOutlet weak var InputUnitSegment: NSSegmentedControl!
}
