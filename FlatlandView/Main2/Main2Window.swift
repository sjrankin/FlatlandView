//
//  Main2Window.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Main2Window: NSWindowController, NSWindowDelegate
{
    override func windowDidLoad()
    {
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
    @IBOutlet weak var HourSegment: NSSegmentedControl!
    @IBOutlet weak var ViewSegment: NSSegmentedControl!
}
