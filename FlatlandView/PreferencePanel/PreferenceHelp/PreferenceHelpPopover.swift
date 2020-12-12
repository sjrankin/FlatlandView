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
        HelpTextControl.isEditable = false
        HelpTextControl.isSelectable = true
        DoSetText(AssignLater)
    }
    
    func DoSetText(_ Raw: String)
    {
        let AText = AttributedText.ConvertText(Raw)
        HelpTextControl.textStorage?.setAttributedString(AText)
    }
    
    var This: NSPopover? = nil
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool
    {
        return true
    }
    
    func Initialize()
    {
        DoSetText("")
    }
    
    func SetHelpText(_ Text: String)
    {
        if HelpTextControl != nil
        {
           DoSetText(Text)
        }
        AssignLater = Text
    }
    
    var AssignLater: String = ""
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var HelpTextControl: NSTextView!
}
