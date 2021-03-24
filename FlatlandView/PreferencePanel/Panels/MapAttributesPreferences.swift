//
//  MapAttributesPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapAttributesPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if Settings.GetBool(.HideMouseOverEarth)
        {
            CursorSegment.selectedSegment = 1
        }
        else
        {
            CursorSegment.selectedSegment = 0
        }
        ShowWallClockSeparatorsSwitch.state = Settings.GetBool(.ShowWallClockSeparators) ? .on : .off
        HelpButtons.append(ShowGridLineHelpButton)
        HelpButtons.append(GridLineColorHelpButton)
        HelpButtons.append(BackgroundColorHelpButton)
        HelpButtons.append(FlatMapNightLevelHelpButton)
        HelpButtons.append(PoleShapeHelpButton)
        HelpButtons.append(CursorHelp)
        HelpButtons.append(PanelResetHelp)
        HelpButtons.append(WallClockHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
        GridLineColorWell.color = Settings.GetColor(.GridLineColor, NSColor.PrussianBlue)
        BackgroundColorWell.color = Settings.GetColor(.BackgroundColor3D)!
        ShowGridLinesSwitch.state = Settings.GetBool(.GridLinesDrawnOnMap) ? .on : .off
        ShowMoonLightSwitch.state = Settings.GetBool(.ShowMoonLight) ? .on : .off
        PoleCombo.removeAllItems()
        for Shape in PolarShapes.allCases
        {
            PoleCombo.addItem(withObjectValue: Shape.rawValue)
        }
        let CurrentPole = Settings.GetEnum(ForKey: .PolarShape, EnumType: PolarShapes.self, Default: .Pole)
        PoleCombo.selectItem(withObjectValue: CurrentPole.rawValue)
        FlatMapNightCombo.removeAllItems()
        for DarkLevel in NightDarknesses.allCases
        {
            FlatMapNightCombo.addItem(withObjectValue: DarkLevel.rawValue)
        }
        let CurrentDarkness = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Dark)
        FlatMapNightCombo.selectItem(withObjectValue: CurrentDarkness.rawValue)
    }
    
    @IBAction func HandleColorChanged(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            switch ColorWell
            {
                case BackgroundColorWell:
                    Settings.SetColor(.BackgroundColor3D, ColorWell.color)
                    
                case GridLineColorWell:
                    let NewColor = ColorWell.color
                    Settings.SetColor(.GridLineColor, NewColor)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleCursorChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.selectedSegment == 0
            {
                Settings.SetBool(.HideMouseOverEarth, false)
            }
            else
            {
                Settings.SetBool(.HideMouseOverEarth, true)
            }
        }
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowGridLineHelpButton:
                    Parent?.ShowHelp(For: .ShowGridLines, Where: Button.bounds, What: ShowGridLineHelpButton)
                    
                case GridLineColorHelpButton:
                    Parent?.ShowHelp(For: .GridLineColor, Where: Button.bounds, What: GridLineColorHelpButton)
                    
                case BackgroundColorHelpButton:
                    Parent?.ShowHelp(For: .BackgroundColor, Where: Button.bounds, What: BackgroundColorHelpButton)
                    
                case FlatMapNightLevelHelpButton:
                    Parent?.ShowHelp(For: .FlatNightDarkness, Where: Button.bounds, What: FlatMapNightLevelHelpButton)
                    
                case ShowMoonlightHelpButton:
                    Parent?.ShowHelp(For: .ShowMoonlight, Where: Button.bounds, What: ShowMoonlightHelpButton)
                    
                case PoleShapeHelpButton:
                    Parent?.ShowHelp(For: .PoleShape, Where: Button.bounds, What: PoleShapeHelpButton)
                    
                case CursorHelp:
                    Parent?.ShowHelp(For: .CursorAppearance, Where: Button.bounds, What: CursorHelp)
            
                case PanelResetHelp:
                    Parent?.ShowHelp(For: .PaneReset, Where: Button.bounds, What: PanelResetHelp)
                    
                case WallClockHelpButton:
                    Parent?.ShowHelp(For: .WallClockSeparators, Where: Button.bounds, What: WallClockHelpButton)
                    
                default:
                    break
            }
        }
    }
    
    func SetDarkMode(To: Bool)
    {
        
    }
    
    func SetHelpVisibility(To: Bool)
    {
        for HelpButton in HelpButtons
        {
            HelpButton.alphaValue = To ? 1.0 : 0.0
            HelpButton.isEnabled = To ? true : false
        }
    }
    
    @IBAction func HandleGridLinesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.GridLinesDrawnOnMap, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleShowMoonLightChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowMoonLight, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandlePoleComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Item = Combo.objectValueOfSelectedItem as? String
            {
                if let SelectedItem = PolarShapes(rawValue: Item)
                {
                    Settings.SetEnum(SelectedItem, EnumType: PolarShapes.self, ForKey: .PolarShape)
                }
            }
        }
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
    
    func ResetToFactorySettings()
    {
        Settings.SetBool(.ShowWallClockSeparators, false)
        ShowWallClockSeparatorsSwitch.state = .off
        Settings.SetBool(.GridLinesDrawnOnMap, true)
        ShowGridLinesSwitch.state = .on
        Settings.SetColor(.GridLineColor, NSColor.PrussianBlue)
        GridLineColorWell.color = NSColor.PrussianBlue
        Settings.SetColor(.BackgroundColor3D, NSColor.black)
        BackgroundColorWell.color = NSColor.black
        CursorSegment.selectedSegment = 0
        Settings.SetBool(.HideMouseOverEarth, false)
        Settings.SetEnum(.Dark, EnumType: NightDarknesses.self, ForKey: .NightDarkness)
        FlatMapNightCombo.selectItem(withObjectValue: NightDarknesses.Dark.rawValue)
        Settings.SetBool(.ShowMoonLight, true)
        ShowMoonLightSwitch.state = .on
        Settings.SetEnum(.Pole, EnumType: PolarShapes.self, ForKey: .PolarShape)
        PoleCombo.selectItem(withObjectValue: PolarShapes.Pole.rawValue)
    }
    
    @IBAction func WallClockSeparatorChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowWallClockSeparators, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleFlatMapNightChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Item = Combo.objectValueOfSelectedItem
            {
                if let ItemString = Item as? String
                {
                    if let ActualItem = NightDarknesses(rawValue: ItemString)
                    {
                        Settings.SetEnum(ActualItem, EnumType: NightDarknesses.self, ForKey: .NightDarkness)
                    }
                }
            }
        }
    }
    
    var HelpButtons: [NSButton] = [NSButton]()

    @IBOutlet weak var WallClockHelpButton: NSButton!
    @IBOutlet weak var ShowWallClockSeparatorsSwitch: NSSwitch!
    @IBOutlet weak var FlatMapNightCombo: NSComboBox!
    @IBOutlet weak var PanelResetHelp: NSButton!
    @IBOutlet weak var PoleCombo: NSComboBox!
    @IBOutlet weak var ShowMoonLightSwitch: NSSwitch!
    @IBOutlet weak var ShowGridLinesSwitch: NSSwitch!
    @IBOutlet weak var BackgroundColorWell: NSColorWell!
    @IBOutlet weak var GridLineColorWell: NSColorWell!
    @IBOutlet weak var CursorSegment: NSSegmentedControl!
    @IBOutlet weak var ShowGridLineHelpButton: NSButton!
    @IBOutlet weak var GridLineColorHelpButton: NSButton!
    @IBOutlet weak var BackgroundColorHelpButton: NSButton!
    @IBOutlet weak var FlatMapNightLevelHelpButton: NSButton!
    @IBOutlet weak var ShowMoonlightHelpButton: NSButton!
    @IBOutlet weak var PoleShapeHelpButton: NSButton!
    @IBOutlet weak var CursorHelp: NSButton!
}
