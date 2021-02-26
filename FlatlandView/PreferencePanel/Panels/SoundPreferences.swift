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
        
        EventList = Settings.GetEvents()
        SoundList = Settings.GetSounds()
        CurrentEvent = EventList.first
        SoundBox.title = "\(CurrentEvent!.Name) Sound Editor"

        EventTable.reloadData()
        SoundTable.reloadData()
    }
    
    override func viewWillLayout()
    {
        let ISet = IndexSet(integer: 0)
        EventTable.selectRowIndexes(ISet, byExtendingSelection: false)
        PopulateEditor(With: CurrentEvent!)
    }
    
    override func viewWillDisappear()
    {
        Settings.SaveEvents(EventList)
        Settings.SaveSounds(SoundList)
    }
    
    var CurrentEvent: EventRecord? = nil
    var EventList = [EventRecord]()
    var SoundList = [SoundRecord]()
    
    // MARK: - Table view handling
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case SoundTable:
                return SoundList.count
                
            case EventTable:
                return EventList.count
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var ToolTip = ""
        
        switch tableView
        {
            case SoundTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "BuiltInSoundColumn"
                    CellContents = SoundList[row].SoundName
                }
                
            case EventTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "EventColumn"
                    CellContents = EventList[row].Name
                }
                else
                {
                    CellIdentifier = "SoundColumn"
                    if EventList[row].EventSound!.IsFile
                    {
                        ToolTip = EventList[row].EventSound!.FileName
                        CellContents = EventList[row].EventSound!.FileName
                    }
                    else
                    {
                        CellContents = EventList[row].EventSound!.SoundName
                    }
                }
                
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if !ToolTip.isEmpty
        {
            Cell?.toolTip = ToolTip
        }
        return Cell
    }
    
    func CurrentEventIndex() -> Int?
    {
        if let CEvent = CurrentEvent
        {
            var Count = 0
            var Index = -1
            for SomeEvent in EventList
            {
                if SomeEvent.EventPK == CEvent.EventPK
                {
                    Index = Count
                    break
                }
                Count = Count + 1
            }
            if Index < 0
            {
                return nil
            }
            return Index
        }
        else
        {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        if let Table = notification.object as? NSTableView
        {
            let NewRow = Table.selectedRow
            if NewRow < 0
            {
                if Table == EventTable
                {
                    SoundBox.title = "Event Sound Editor"
                }
                return
            }
            switch Table
            {
                case SoundTable:
                    print("Selected sound \(SoundList[NewRow].SoundName)")
                    let SomeSound = SoundList[NewRow]
                    CurrentEvent!.SoundID = SomeSound.SoundPK
                    CurrentEvent!.EventSound = SomeSound
                    if let CIndex = CurrentEventIndex()
                    {
                        EventList[CIndex] = CurrentEvent!
                        EventTable.reloadData()
                    }
                    
                case EventTable:
                    print("Selected event \(EventList[NewRow].Name)")
                    SoundBox.title = "\(EventList[NewRow].Name) Sound Editor"
                    if let CIndex = CurrentEventIndex()
                    {
                        EventList[CIndex] = CurrentEvent!
                        EventTable.reloadData()
                    }
                    CurrentEvent = EventList[NewRow]
                    PopulateEditor(With: CurrentEvent!)
                    
                default:
                    print("Unknown table clicked")
                    break
            }
        }
    }
    
    // MARK: - Sound editor handling
    
    func SelectSound(_ Name: String)
    {
        var Index = 0
        for Sound in SoundList
        {
            if Sound.SoundName == Name
            {
                let ISet = IndexSet(integer: Index)
                SoundTable.selectRowIndexes(ISet, byExtendingSelection: false)
                SoundTable.scrollRowToVisible(Index)
                return
            }
            Index = Index + 1
        }
    }
    
    func PopulateEditor(With: EventRecord)
    {
        MuteEventSwitch.state = With.SoundMuted ? .on : .off
        SelectSound(With.EventSound!.SoundName)
    }
    
    @IBAction func MuteEventSwitchHandler(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            CurrentEvent!.SoundMuted = Switch.state == .on ? true : false
        }
    }
    
    @IBAction func ClearSoundButtonHandler(_ sender: Any)
    {
        CurrentEvent!.SoundID = SoundList[0].SoundPK
        CurrentEvent!.EventSound = SoundList[0]
        let ISet = IndexSet(integer: 0)
        SoundTable.selectRowIndexes(ISet, byExtendingSelection: false)
        SoundTable.scrollRowToVisible(0)
    }
    
    @IBAction func PlaySoundButtonHandler(_ sender: Any)
    {
        let Sound = CurrentEvent!.EventSound
        SoundManager.Play(Name: Sound!.Name)
    }
    
    @IBAction func OpenSoundFileButtonHandler(_ sender: Any)
    {
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
    
    // MARK: - Reset functionality
    
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
        Settings.SetTrue(.EnableSounds)
        EnableSoundsSwitch.state = .on
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
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    @IBOutlet weak var SoundFileField: NSTextField!
    @IBOutlet weak var MuteEventSwitch: NSSwitch!
    @IBOutlet weak var SoundBox: NSBox!
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
