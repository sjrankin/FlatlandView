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
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    @IBAction func HandleHelpButtonPressed(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case LiveDataHelpButton:
                    Parent?.ShowHelp(For: .LiveDataHelp, Where: Button.bounds, What: LiveDataHelpButton)
                    
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
    
    @IBOutlet weak var LiveDataHelpButton: NSButton!
}
