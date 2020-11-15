//
//  DebuggerWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DebuggerWindow: NSWindowController
{
    override func windowDidLoad()
    {
        ClockControlBarItem.view?.wantsLayer = true
        ClockControlBarItem.view?.layer?.cornerRadius = 3.0
        ClockControlBarItem.view?.layer?.borderWidth = 1.0
        ClockControlBarItem.view?.layer?.borderColor = NSColor.clear.cgColor
        DebugLogBarItem.view?.wantsLayer = true
        DebugLogBarItem.view?.layer?.cornerRadius = 3.0
        DebugLogBarItem.view?.layer?.borderWidth = 1.0
        DebugLogBarItem.view?.layer?.borderColor = NSColor.clear.cgColor
        CommandLineBarItem.view?.wantsLayer = true
        CommandLineBarItem.view?.layer?.cornerRadius = 3.0
        CommandLineBarItem.view?.layer?.borderWidth = 1.0
        CommandLineBarItem.view?.layer?.borderColor = NSColor.clear.cgColor
        
        ButtonMap[ClockControlButton] = ClockControlBarItem
        ButtonMap[DebugLogButton] = DebugLogBarItem
        ButtonMap[CommandLineButton] = CommandLineBarItem
    }
    
    var ButtonMap = [NSButton: NSToolbarItem]()
    
    var PreviousButton: NSButton? = nil
    
    func DeHighlight(_ Button: NSButton)
    {
        if let Item = ButtonMap[Button]
        {
            Item.view?.layer?.backgroundColor = NSColor.clear.cgColor
            Item.view?.layer?.borderColor = NSColor.clear.cgColor
        }
    }
    
    func Highlight(_ Button: NSButton)
    {
        if PreviousButton != nil
        {
            DeHighlight(PreviousButton!)
        }
        PreviousButton = Button
        if let Item = ButtonMap[Button]
        {
            Item.view?.layer?.backgroundColor = NSColor.systemPink.cgColor
            Item.view?.layer?.borderColor = NSColor.systemRed.cgColor
        }
    }
    
    @IBOutlet weak var CommandLineBarItem: NSToolbarItem!
    @IBOutlet weak var ClockControlBarItem: NSToolbarItem!
    @IBOutlet weak var DebugLogBarItem: NSToolbarItem!
    
    @IBOutlet weak var CommandLineButton: NSButton!
    @IBOutlet weak var ClockControlButton: NSButton!
    @IBOutlet weak var DebugLogButton: NSButton!
}
