//
//  Main2Window.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics

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
    
    /// Returns the current window location.
    /// - Returns: location of the upper-left corner of the window.
    func WindowLocation() -> CGPoint
    {
        if window!.windowNumber < 0
        {
            return CGPoint.zero
        }
        let CurrentID = CGWindowID(window!.windowNumber)
        if let WindowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: AnyObject]]
        {
            for SomeWindow in WindowList
            {
                let Number = SomeWindow[kCGWindowNumber as String]!
                let Bounds = CGRect(dictionaryRepresentation: SomeWindow[kCGWindowBounds as String] as! CFDictionary)!
                let WindowName = SomeWindow[kCGWindowName as String] as? String ?? ""
                let WindowNumber = Number as! UInt32
                if WindowNumber == CurrentID && WindowName == "FlatlandView"
                {
                    return CGPoint(x: Bounds.origin.x, y: Bounds.origin.y)
                }
            }
        }
        return CGPoint.zero
    }
    
    /// Handle window moved notifications.
    /// - Parameter notification: The notification with window position information.
    func windowDidMove(_ notification: Notification)
    {
        let WindowOrigin = WindowLocation()
        let VC = window?.contentViewController as? Main2Controller
        VC?.WindowMovedTo(WindowOrigin)
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
