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
                        PreferencePanelProtocol,
                        EventSettingProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        EditEventSoundButton.isEnabled = false
        EnableSoundsSwitch.state = Settings.GetBool(.EnableSounds) ? .on : .off
        EnableMutePeriodSwitch.state = Settings.GetBool(.EnableMutePeriod) ? .on : .off
        let Duration = Settings.GetInt(.MutePeriodDuration)
        MutePeriodDurationField.stringValue = "\(Duration)"
        let StartTime = Settings.GetInt(.MutePeriodStart)
        let Hour = StartTime / 60
        let Minute = StartTime % 60
        if let FinalStartTime = Date.DateFactory(Hour: Hour, Minute: Minute, Second: 0)
        {
            StartTimePicker.dateValue = FinalStartTime
        }
        
        HelpButtons.append(ResetPanelHelpButton)
        HelpButtons.append(PlaySoundsHelpButton)
        HelpButtons.append(MutePeriodHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
        
        EventList = Settings.GetEvents()
        CurrentEvent = EventList.first
        
        EventTable.reloadData()
    }
    
    override func viewWillLayout()
    {
        let ISet = IndexSet(integer: 0)
        EventTable.selectRowIndexes(ISet, byExtendingSelection: false)
    }
    
    override func viewWillDisappear()
    {
        Settings.SaveEvents(EventList)
    }
    
    var CurrentEvent: EventRecord? = nil
    var EventList = [EventRecord]()
    
    // MARK: - Table view handling
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return EventList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var ToolTip = ""
        var NotAssigned: Bool = false
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "EventColumn"
            CellContents = EventList[row].Name
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "SoundColumn"
            if EventList[row].NoSound
            {
                NotAssigned = true
                CellContents = "no sound assigned"
            }
            else
            {
                if EventList[row].EventSound!.IsFile
                {
                    ToolTip = EventList[row].EventSound!.FileName
                    CellContents = EventList[row].EventSound!.FileName
                }
                else
                {
                    var FinalName = ""
                    if let TheSound = Sounds(rawValue: EventList[row].EventSound!.SoundName)
                    {
                        FinalName = TheSound.rawValue
                    }
                    else
                    {
                        FinalName = EventList[row].EventSound!.SoundName
                    }
                    CellContents = FinalName
                }
            }
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if NotAssigned
        {
            Cell?.textField?.textColor = NSColor.disabledControlTextColor
        }
        else
        {
            Cell?.textField?.textColor = NSColor.textColor
        }
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
                EditEventSoundButton.isEnabled = false
                return
            }
            CurrentEvent = EventList[NewRow]
            EditEventSoundButton.isEnabled = true
        }
    }
    
    // MARK: - Help button handling
    
    @IBAction func HandleHelpButtonPressed(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case PlaySoundsHelpButton:
                    Parent?.ShowHelp(For: .SoundPlayHelp, Where: Button.bounds, What: PlaySoundsHelpButton)
                    
                case ResetPanelHelpButton:
                    Parent?.ShowHelp(For: .PaneReset, Where: Button.bounds, What: ResetPanelHelpButton)
                    
                case MutePeriodHelpButton:
                    Parent?.ShowHelp(For: .MutePeriodHelp, Where: Button.bounds, What: MutePeriodHelpButton)
                    
                default:
                    return
            }
        }
    }
    
    func SetDarkMode(To: Bool)
    {
        
    }
    
    @IBAction func HandleEditEventSound(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "PreferencePanel", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EventSoundEditor") as? EventSoundEditorWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? EventSoundEditorController
            Controller?.EventParent = self
            Controller?.SetEvent(CurrentEvent!)
            self.view.window?.beginSheet(Window!)
            {
                Result in
            }
        }
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
        let DoReset = RunMessageBoxOK(Message: "Reset settings on this pane?",
                                      InformationMessage: "You will lose all of the changes you have made to the settings on this panel.")
        if DoReset
        {
            ResetToFactorySettings()
        }
    }
    
    /// Called by the event sound editor when the user accepts a change to a sound.
    /// - Parameter Edited: The edited event record.
    func SetEditedEvent(_ Edited: EventRecord)
    {
        if let Index = CurrentEventIndex()
        {
            EventList[Index] = Edited
            EventTable.reloadData()
        }
    }
    
    func ResetToFactorySettings()
    {
        Settings.SetTrue(.EnableSounds)
        EnableSoundsSwitch.state = .on
        Settings.SetFalse(.EnableMutePeriod)
        EnableSoundsSwitch.state = .off
        let NewStart = Date.DateFactory(Hour: 20, Minute: 0, Second: 0)
        StartTimePicker.dateValue = NewStart!
        Settings.SetInt(.MutePeriodStart, 20 * 60)
        MutePeriodDurationField.stringValue = "8"
        Settings.SetInt(.MutePeriodDuration, 8 * 60)
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
    
    // MARK: - Mute period settings.
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case MutePeriodDurationField:
                    if let Duration = Int(TextField.stringValue)
                    {
                        if Duration < 0
                        {
                            TextField.stringValue = "0"
                            Settings.SetInt(.MutePeriodDuration, 0)
                            return
                        }
                        if Duration > 23
                        {
                            TextField.stringValue = "23"
                            Settings.SetInt(.MutePeriodDuration, 23)
                            return
                        }
                        Settings.SetInt(.MutePeriodStart, Duration)
                    }
                    else
                    {
                        TextField.stringValue = "0"
                        Settings.SetInt(.MutePeriodDuration, 0)
                        return
                    }
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleMutePeriodSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.EnableMutePeriod, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleStartTimeChanged(_ sender: Any)
    {
        if let Picker = sender as? NSDatePicker
        {
            let StartTime = Picker.dateValue
            let Minute = StartTime.Minute
            let Hour = StartTime.Hour
            let Seconds = (Hour * 60 * 60) + (Minute * 60)
            Settings.SetInt(.MutePeriodStart, Seconds)
        }
    }
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    @IBOutlet weak var EditEventSoundButton: NSButton!
    @IBOutlet weak var MutePeriodDurationField: NSTextField!
    @IBOutlet weak var StartTimePicker: NSDatePicker!
    @IBOutlet weak var EnableMutePeriodSwitch: NSSwitch!
    @IBOutlet weak var MutePeriodHelpButton: NSButton!
    @IBOutlet weak var EventTable: NSTableView!
    @IBOutlet weak var EnableSoundsSwitch: NSSwitch!
    @IBOutlet weak var ResetPanelHelpButton: NSButton!
    @IBOutlet weak var PlaySoundsHelpButton: NSButton!
}
