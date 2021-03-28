//
//  EventSoundEditorController.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/27/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EventSoundEditorController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    public weak var EventParent: EventSettingProtocol? = nil
    
    override func viewDidLoad()
    {
        SoundFileHelp.isHidden = !Settings.GetBool(.ShowUIHelp)
        RemoveButtonHelp.isHidden = !Settings.GetBool(.ShowUIHelp)
        PlayButtonHelp.isHidden = !Settings.GetBool(.ShowUIHelp)
        MuteSoundHelp.isHidden = !Settings.GetBool(.ShowUIHelp)
    }
    
    override func viewDidAppear()
    {
        Window = self.view.window
        Parent = Window?.sheetParent
    }
    
    var Window: NSWindow? = nil
    var Parent: NSWindow? = nil
    
    public func SetEvent(_ Event: EventRecord)
    {
        CurrentEvent = Event
        MainTitle.stringValue = "Event Sound Editor for \(Event.Name)"
        SoundList = Settings.GetSounds()
        SoundTable.reloadData()
        MuteSoundSwitch.state = Event.SoundMuted.State()
    }
    
    var SoundList = [SoundRecord]()
    
    var CurrentEvent: EventRecord? = nil
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        if let FinalEvent = CurrentEvent
        {
            EventParent?.SetEditedEvent(FinalEvent)
        }
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleMuteSoundChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            CurrentEvent?.SoundMuted = Switch.state.AsBoolean()
        }
    }
    
    @IBAction func HandlePlayButtonPressed(_ sender: Any)
    {
        if CurrentEvent!.NoSound
        {
            return
        }
        if let Sound = CurrentEvent!.EventSound
        {
            SoundManager.Play(Name: Sound.Name)
        }
    }
    
    @IBAction func HandleRemoveButtonPressed(_ sender: Any)
    {
        CurrentEvent?.NoSound = true
    }
    
    @IBAction func HandleOpenButtonPressed(_ sender: Any)
    {
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return SoundList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "SoundColumn"
            CellContents = SoundList[row].SoundName
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let NewRow = SoundTable.selectedRow
        if NewRow < 0
        {
            return
        }
        let SomeSound = SoundList[NewRow]
        CurrentEvent?.SoundID = SomeSound.SoundPK
        CurrentEvent?.EventSound = SomeSound
        CurrentEvent?.NoSound = false
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            LocalShowHelp(For: Button)
        }
    }
    
    func LocalShowHelp(For: NSButton)
    {
        var Message = ""
        let Where = For.bounds
        switch For
        {
            case SoundFileHelp:
                Message = """
You can add your own sound file sounds to Flatland. If you do, please do not move the sound file or Flatland will not be able to use it.
"""

            case RemoveButtonHelp:
                Message = """
Removes the sound for the event. No sounds will be played when the event occurs until you assign a sound again.
"""
                
            case PlayButtonHelp:
                Message = """
Plays the currently selected sound so you can hear it before using it.
"""

            case MuteSoundSwitch:
                Message = """
Mutes the event's sound. No sound will be played when the event occurs until you unmute it.
"""
                
            default:
                return
        }
        if let PopController = NSStoryboard(name: "PreferenceHelpViewer", bundle: nil).instantiateController(withIdentifier: "PreferenceHelpViewer") as? PreferenceHelpPopover
        {
            guard let HelpController = PopController as? PreferenceHelpProtocol else
            {
                return
            }
            Pop = NSPopover()
            Pop?.contentSize = NSSize(width: 427, height: 237)
            Pop?.behavior = .semitransient
            Pop?.animates = true
            Pop?.contentViewController = PopController
            HelpController.SetHelpText(Message)
            Pop?.show(relativeTo: Where, of: For, preferredEdge: .maxY)
        }
    }
    
    var Pop: NSPopover? = nil
    
    @IBOutlet weak var SoundFileHelp: NSButton!
    @IBOutlet weak var RemoveButtonHelp: NSButton!
    @IBOutlet weak var PlayButtonHelp: NSButton!
    @IBOutlet weak var MuteSoundHelp: NSButton!
    @IBOutlet weak var MainTitle: NSTextField!
    @IBOutlet weak var MuteSoundSwitch: NSSwitch!
    @IBOutlet weak var SoundTable: NSTableView!
}
