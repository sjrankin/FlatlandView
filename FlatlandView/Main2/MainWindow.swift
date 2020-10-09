//
//  MainWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/30/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Main window class.
class MainWindow: NSWindowController, NSWindowDelegate
{
    /// Early initializations.
    override func windowDidLoad()
    {
        //Make sure we get mouse events.
        window?.acceptsMouseMovedEvents = true
    }
    
    /// Handle resize window events.
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize
    {
        let VC = window?.contentViewController as? Main2Controller
        VC?.WindowResized(To: frameSize)
        return frameSize
    }
    
    /// Handle closing window events.
    func windowWillClose(_ notification: Notification)
    {
        let VC = window?.contentViewController as? Main2Controller
        VC?.WillClose()
    }
    
    @IBOutlet weak var MainToolBar: NSToolbar!
    @IBOutlet weak var UpTimeLabel: NSTextField!
    @IBOutlet weak var EarthquakeButton: NSButton!
    @IBOutlet weak var HourSegment: NSSegmentedControl!
    @IBOutlet weak var ViewSegment: NSSegmentedControl!
}