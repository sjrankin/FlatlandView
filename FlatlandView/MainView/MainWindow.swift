//
//  MainWindow.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics

class MainWindow: NSWindowController, NSWindowDelegate
{
    override func windowDidLoad()
    {
        window?.acceptsMouseMovedEvents = true
        WorldLockButton.toolTip = "Locks or unlocks camera motion for views."
        InitializeViewSegments()
    }
    
    func InitializeViewSegments()
    {
        HourSegment.wantsLayer = true
        HourSegment.layer?.borderWidth = 0.5
        HourSegment.layer?.borderColor = NSColor.gray.cgColor
        HourSegment.layer?.cornerRadius = 5.0
        ViewSegment.wantsLayer = true
        ViewSegment.layer?.borderWidth = 0.5
        ViewSegment.layer?.borderColor = NSColor.gray.cgColor
        ViewSegment.layer?.cornerRadius = 5.0
        
        let HourArea = NSTrackingArea(rect: HourSegment.bounds,
                                      options: [.mouseEnteredAndExited, .activeAlways],
                                      owner: self,
                                      userInfo: ["Segment": "Hour"])
        HourSegment.addTrackingArea(HourArea)
        let ViewArea = NSTrackingArea(rect: ViewSegment.bounds,
                                      options: [.mouseEnteredAndExited, .activeAlways],
                                      owner: self,
                                      userInfo: ["Segment": "View"])
        ViewSegment.addTrackingArea(ViewArea)
    }
    
    /// Handle mouse entered a tracking area. This is used to highlight a segment control.
    /// - Parameter with: The passed event.
    override func mouseEntered(with event: NSEvent)
    {
        if let Segment = event.trackingArea?.userInfo?.values.first as? String
        {
            let AccentColor = NSColor.controlAccentColor
            switch Segment
            {
                case "Hour":
                    HourSegment.layer?.borderColor = AccentColor.cgColor
                    
                case "View":
                    ViewSegment.layer?.borderColor = AccentColor.cgColor
                    
                default:
                    break
            }
        }
    }

    /// Handle mouse exited a tracking area. This is used to unhighlight a segment control.
    /// - Parameter with: The passed event.
    override func mouseExited(with event: NSEvent)
    {
        if let Segment = event.trackingArea?.userInfo?.values.first as? String
        {
            switch Segment
            {
                case "Hour":
                    HourSegment.layer?.borderColor = NSColor.gray.cgColor
                    
                case "View":
                    ViewSegment.layer?.borderColor = NSColor.gray.cgColor
                    
                default:
                    break
            }
        }
    }
    
    /// Handle resize window events.
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize
    {
        let VC = window?.contentViewController as? MainController
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
        let VC = window?.contentViewController as? MainController
        VC?.WindowMovedTo(WindowOrigin)
    }

    /// Handle closing window events.
    func windowWillClose(_ notification: Notification)
    {
        let VC = window?.contentViewController as? MainController
        VC?.WillClose()
    }
    
    /// Change the image of the passed toolbar item to the passed image.
    /// - Parameter Item: The item to change.
    /// - Parameter To: The new image.
    func ChangeToolbarItemImage(Item: NSToolbarItem, To Image: NSImage)
    {
        Item.image = Image
    }
    
    /// Change the image of the show info button.
    /// - Parameter To: The new image.
    func ChangeShowInfoImage(To Image: NSImage)
    {
        ChangeToolbarItemImage(Item: ItemInfoButton, To: Image)
    }
    
    @IBOutlet weak var DebuggerButton: NSToolbarItem!
    @IBOutlet weak var WorldLockButton: NSButton!
    @IBOutlet weak var WorldLockBarButton: NSToolbarItem!
    @IBOutlet weak var ItemInfoButton: NSToolbarItem!
    @IBOutlet weak var MainToolBar: NSToolbar!
    @IBOutlet weak var HourSegment: NSSegmentedControl!
    @IBOutlet weak var ViewSegment: NSSegmentedControl!
}
