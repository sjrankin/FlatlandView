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
    /// Handle resize window events.
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize
    {
        let VC = window?.contentViewController as? MainView
        VC?.WindowResized(To: frameSize)
        return frameSize
    }
    
    /// Handle closing window events.
    func windowWillClose(_ notification: Notification)
    {
        let VC = window?.contentViewController as? MainView
        VC?.WillClose()
    }
}
