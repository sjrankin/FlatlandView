//
//  LiveDataPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LiveDataPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        HelpButtons.append(LiveDataHelpButton)
        HelpButtons.append(EnableNASATilesHelp)
        HelpButtons.append(FetchFrequencyHelp)
        
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        EnableNASATilesSwitch.state = Settings.GetBool(.EnableNASATiles) ? .on : .off
        if let LastFetch = Settings.GetDoubleNil(.LastNASAFetchTime)
        {
            let Fetched = Date(timeIntervalSince1970: LastFetch)
            LastFetchTimeField.stringValue = Fetched.PrettyDateTime()
        }
        else
        {
            LastFetchTimeField.stringValue = "No prior fetch"
        }
        NASAFetchCombo.removeAllItems()
        for FetchWhen in NASAFetchTimes
        {
            NASAFetchCombo.addItem(withObjectValue: FetchWhen.1)
        }
    }
    
    let NASAFetchTimes: [(Int, String)] =
    [
        (0, "On demand"),
        (12, "Every 12 hours"),
        (18, "Every 18 hours"),
        (24, "Every 24 hours"),
        (25, "Every 25 hours")
    ]
    
    @IBAction func HandleEnableNASATilesSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.EnableNASATiles, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleFetchIntervalChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            if Index > -1
            {
                let Value = NASAFetchTimes[Index].0
                Settings.SetInt(.NASATilesFetchInterval, Value)
            }
        }
    }
    
    @IBAction func HandleHelpButtonPressed(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case LiveDataHelpButton:
                    Parent?.ShowHelp(For: .LiveDataHelp, Where: Button.bounds, What: LiveDataHelpButton)
                    
                case EnableNASATilesHelp:
                    Parent?.ShowHelp(For: .EnableNASATilesHelp, Where: Button.bounds, What: EnableNASATilesHelp)
                    
                case FetchFrequencyHelp:
                    Parent?.ShowHelp(For: .NASATilesFetchFrequencyHelp, Where: Button.bounds, What: FetchFrequencyHelp)
                    
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
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    @IBOutlet weak var LastFetchTimeField: NSTextField!
    @IBOutlet weak var NASAFetchCombo: NSComboBox!
    @IBOutlet weak var EnableNASATilesSwitch: NSSwitch!
    @IBOutlet weak var FetchFrequencyHelp: NSButton!
    @IBOutlet weak var EnableNASATilesHelp: NSButton!
    @IBOutlet weak var LiveDataHelpButton: NSButton!
}
