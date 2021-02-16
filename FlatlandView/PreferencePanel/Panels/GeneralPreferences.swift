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
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowStatusSwitch.state = Settings.GetBool(.ShowStatusBar) ? .on : .off
        let CurrentMapView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.FlatNorthCenter)
        switch CurrentMapView
        {
            case .CubicWorld:
                MapTypeSegment.selectedSegment = 3
                
            case .FlatNorthCenter:
                MapTypeSegment.selectedSegment = 1
                
            case .FlatSouthCenter:
                MapTypeSegment.selectedSegment = 0
                
            case .Rectangular:
                MapTypeSegment.selectedSegment = 2
                
            case .Globe3D:
                MapTypeSegment.selectedSegment = 3
        }
        let CurrentHourView = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        switch CurrentHourView
        {
            case .None:
                HourTypeSegment.selectedSegment = 0
                
            case .Solar:
                HourTypeSegment.selectedSegment = 1
                
            case .RelativeToNoon:
                HourTypeSegment.selectedSegment = 2
                
            case .RelativeToLocation:
                HourTypeSegment.selectedSegment = 3
        }
        let PreviousScale = Settings.GetEnum(ForKey: .HourScale, EnumType: MapNodeScales.self, Default: .Normal)
        switch PreviousScale
        {
            case .Small:
                HourScaleSegment.selectedSegment = 0
                
            case .Normal:
                HourScaleSegment.selectedSegment = 1
                
            case .Large:
                HourScaleSegment.selectedSegment = 2
        }
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
        
        HelpButtons.append(ResetPaneHelp)
        HelpButtons.append(ShowUIHelpHelp)
        HelpButtons.append(StatusBarHelp)
        HelpButtons.append(HourScaleHelpButton)
        HelpButtons.append(HourTypeHelpButton)
        HelpButtons.append(MapTypeHelpButton)
        HelpButtons.append(InputUnitHelpButton)
        HelpButtons.append(ShowSecondsHelpButton)
        HelpButtons.append(DateStyleHelpButton)
        HelpButtons.append(IFStyleHelpButton)
        ShowUIHelpSwitch.state = Settings.GetBool(.ShowUIHelp) ? .on : .off
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    public var HelpButtons: [NSButton] = [NSButton]()
    
    public func SetHelpVisibility(To: Bool)
    {
        for HelpButton in HelpButtons
        {
            HelpButton.alphaValue = To ? 1.0 : 0.0
            HelpButton.isEnabled = To ? true : false
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
            switch NewValue
            {
                case .Minimal:
                    Settings.SetFalse(.ExtrudedCitiesCastShadows)
                    Settings.SetFalse(.HoursCastShadows)
                    
                case .Normal:
                    Settings.SetFalse(.ExtrudedCitiesCastShadows)
                    Settings.SetFalse(.HoursCastShadows)

                case .Maximum:
                    Settings.SetTrue(.ExtrudedCitiesCastShadows)
                    Settings.SetTrue(.HoursCastShadows)
            }
        }
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowUIHelpHelp:
                    Parent?.ShowHelp(For: .UIHelp, Where: Button.bounds, What: ShowUIHelpHelp)
                
                case IFStyleHelpButton:
                    Parent?.ShowHelp(For: .InterfaceStyle, Where: Button.bounds, What: IFStyleHelpButton)
                    
                case InputUnitHelpButton:
                    Parent?.ShowHelp(For: .InputUnits, Where: Button.bounds, What: InputUnitHelpButton)
                    
                case DateStyleHelpButton:
                    Parent?.ShowHelp(For: .MainDateFormat, Where: Button.bounds, What: DateStyleHelpButton)
                    
                case ShowSecondsHelpButton:
                    Parent?.ShowHelp(For: .ShowSeconds, Where: Button.bounds, What: ShowSecondsHelpButton)
                    
                case HourTypeHelpButton:
                    Parent?.ShowHelp(For: .HourTypes, Where: Button.bounds, What: HourTypeHelpButton)
                    
                case MapTypeHelpButton:
                    Parent?.ShowHelp(For: .MapTypes, Where: Button.bounds, What: MapTypeHelpButton)
                    
                case HourScaleHelpButton:
                    Parent?.ShowHelp(For: .HourScale, Where: Button.bounds, What: HourScaleHelpButton)
                    
                case StatusBarHelp:
                    Parent?.ShowHelp(For: .ShowStatusBar, Where: Button.bounds, What: StatusBarHelp) 
                    
                case ResetPaneHelp:
                    Parent?.ShowHelp(For: .PaneReset, Where: Button.bounds, What: ResetPaneHelp)
                    
                default:
                    return
            }
        }
    }
    
    //https://stackoverflow.com/questions/29433487/create-an-nsalert-with-swift
    @discardableResult func RunMessageBoxOK(Message: String, InformationMessage: String) -> Bool
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = InformationMessage
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "Reset Values")
        Alert.addButton(withTitle: "Cancel")
        return Alert.runModal() == .alertFirstButtonReturn
    }
    
    @IBAction func HandleResetPane(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            let DoReset = RunMessageBoxOK(Message: "Reset settings on this pane?",
                                         InformationMessage: "You will lose all of the changes you have made to the settings on this panel.")
            if DoReset
            {
                ResetToFactorySettings()
            }
        }
    }
    
    func ResetToFactorySettings()
    {
        //Reset time view.
        Settings.SetBool(.TimeLabelSeconds, false)
        ShowSecondsSwitch.state = .off
        Settings.SetEnum(.UTC, EnumType: TimeLabels.self, ForKey: .TimeLabel)
        TimeFormatSegment.selectedSegment = 1
        
        //Reset style box
        Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
        MapTypeSegment.selectedSegment = 3
        Settings.SetEnum(.Solar, EnumType: HourValueTypes.self, ForKey: .HourType)
        HourTypeSegment.selectedSegment = 1
        Settings.SetEnum(.Normal, EnumType: MapNodeScales.self, ForKey: .HourScale)
        HourScaleSegment.selectedSegment = 1
        
        //Reset interface box
        Settings.SetEnum(.Normal, EnumType: InterfaceStyles.self, ForKey: .InterfaceStyle)
        InterfaceSegement.selectedSegment = 1
        Settings.SetBool(.ShowStatusBar, true)
        ShowStatusSwitch.state = .on
        Settings.SetBool(.ShowUIHelp, true)
        ShowUIHelpSwitch.state = .on
        
        //Reset other box
        Settings.SetEnum(.Kilometers, EnumType: InputUnits.self, ForKey: .InputUnit)
        InputUnitSegment.selectedSegment = 0
    }
    
    func SetDarkMode(To: Bool)
    {
        
    }
    
    @IBAction func HandleShowHelpChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowUIHelp, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func MapTypeChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 1:
                    Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 2:
                    Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 3:
                    Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HourTypeChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(.None, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case 1:
                    Settings.SetEnum(.Solar, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case 2:
                    Settings.SetEnum(.RelativeToNoon, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case 3:
                    Settings.SetEnum(.RelativeToLocation, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HourScaleChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            if Index <= MapNodeScales.allCases.count - 1
            {
                let NewScale = MapNodeScales.allCases[Index]
                Settings.SetEnum(NewScale, EnumType: MapNodeScales.self, ForKey: .HourScale)
            }
        }
    }
    
    @IBAction func ShowStatusBarChangedHandler(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowStatusBar, Switch.state == .on ? true : false)
        }
    }

    @IBOutlet weak var ResetPaneHelp: NSButton!
    @IBOutlet weak var ShowUIHelpHelp: NSButton!
    @IBOutlet weak var ShowUIHelpSwitch: NSSwitch!
    @IBOutlet weak var ShowStatusSwitch: NSSwitch!
    @IBOutlet weak var StatusBarHelp: NSButton!
    @IBOutlet weak var HourTypeSegment: NSSegmentedControl!
    @IBOutlet weak var MapTypeSegment: NSSegmentedControl!
    @IBOutlet weak var HourScaleHelpButton: NSButton!
    @IBOutlet weak var HourScaleSegment: NSSegmentedControl!
    @IBOutlet weak var HourTypeHelpButton: NSButton!
    @IBOutlet weak var MapTypeHelpButton: NSButton!
    @IBOutlet weak var InputUnitHelpButton: NSButton!
    @IBOutlet weak var ShowSecondsHelpButton: NSButton!
    @IBOutlet weak var DateStyleHelpButton: NSButton!
    @IBOutlet weak var IFStyleHelpButton: NSButton!
    @IBOutlet weak var InterfaceSegement: NSSegmentedControl!
    @IBOutlet weak var TimeFormatSegment: NSSegmentedControl!
    @IBOutlet weak var ShowSecondsSwitch: NSSwitch!
    @IBOutlet weak var InputUnitSegment: NSSegmentedControl!
}
