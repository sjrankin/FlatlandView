//
//  PreferenceHelpPopover.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class PreferenceHelpPopover: NSViewController, NSPopoverDelegate, PreferenceHelpProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Initialize()
    }
    
    override func viewWillLayout()
    {
        HelpTextControl.stringValue = AssignLater
    }
    
    var This: NSPopover? = nil
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool
    {
        return true
    }
    
    func Initialize()
    {
        HelpTextControl.stringValue = ""
    }
    
    func SetHelpText(_ Text: String)
    {
        if HelpTextControl != nil
        {
        HelpTextControl.stringValue = Text
        }
        AssignLater = Text
    }
    
    var AssignLater: String = ""
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var HelpTextControl: NSTextField!
}
