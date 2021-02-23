//
//  SoundPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SoundPreferences: NSViewController,
                        NSTableViewDataSource, NSTableViewDelegate,
                        NSTextFieldDelegate,
                        PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        EnableSoundsSwitch.state = Settings.GetBool(.EnableSounds) ? .on : .off
        
        HelpButtons.append(ClearEventSoundHelpButton)
        HelpButtons.append(MuteEventHelpButton)
        HelpButtons.append(PlaySampleHelpButton)
        HelpButtons.append(UserFileHelpButton)
        HelpButtons.append(ResetPanelHelpButton)
        HelpButtons.append(AvailableSoundsTableHelpButton)
        HelpButtons.append(PlaySoundsHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    // MARK: - Table view handling
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case SoundTable:
                return 0
                
            case EventTable:
                return 0
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        switch tableView
        {
            case SoundTable:
                break
                
            case EventTable:
                break
                
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    // MARK: - Help button handling
    
    @IBAction func HandleHelpButtonPressed(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ClearEventSoundHelpButton:
                    Parent?.ShowHelp(For: .ClearEventSoundHelp, Where: Button.bounds, What: ClearEventSoundHelpButton)
                    
                case MuteEventHelpButton:
                    Parent?.ShowHelp(For: .MuteEventHelp, Where: Button.bounds, What: MuteEventHelpButton)
                    
                case PlaySampleHelpButton:
                    Parent?.ShowHelp(For: .PlaySampleHelp, Where: Button.bounds, What: PlaySampleHelpButton)
                    
                case UserFileHelpButton:
                    Parent?.ShowHelp(For: .UserFileHelp, Where: Button.bounds, What: UserFileHelpButton)
                    
                case PlaySoundsHelpButton:
                    Parent?.ShowHelp(For: .SoundPlayHelp, Where: Button.bounds, What: PlaySoundsHelpButton)
                    
                case AvailableSoundsTableHelpButton:
                    Parent?.ShowHelp(For: .BuiltInSoundsHelp, Where: Button.bounds, What: AvailableSoundsTableHelpButton)
                
                case ResetPanelHelpButton:
                    Parent?.ShowHelp(For: .PaneReset, Where: Button.bounds, What: ResetPanelHelpButton)
                    
                default:
                    return
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
    
    @IBAction func HandlePlaySoundsChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.EnableSounds, Switch.state == .on ? true : false)
        }
    }
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    @IBOutlet weak var EventTable: NSTableView!
    @IBOutlet weak var SoundTable: NSTableView!
    @IBOutlet weak var EnableSoundsSwitch: NSSwitch!
    @IBOutlet weak var ClearEventSoundHelpButton: NSButton!
    @IBOutlet weak var MuteEventHelpButton: NSButton!
    @IBOutlet weak var PlaySampleHelpButton: NSButton!
    @IBOutlet weak var UserFileHelpButton: NSButton!
    @IBOutlet weak var ResetPanelHelpButton: NSButton!
    @IBOutlet weak var AvailableSoundsTableHelpButton: NSButton!
    @IBOutlet weak var PlaySoundsHelpButton: NSButton!
}
