//
//  +MainWindowing.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController: NSWindowDelegate
{
    // MARK: - Window delegate functions
    
    /// Initializes the window delegate so we receive window-based events.
    func SetWindowDelegate()
    {
        ParentWindow = self.view.window
        ParentWindow?.delegate = self
    }
    
    /// Handle window will resize events.
    /// - Parameter sender: The window that will resize.
    /// - Parameter to: New window size.
    /// - Returns: A window size that can be used to constrain the resizing. In our case,
    ///            we just return the same value that was passed to us.
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize
    {
        WindowResized(To: frameSize)
        return frameSize
    }
    
    /// Returns the current window location.
    /// - Returns: location of the upper-left corner of the window.
    func WindowLocation() -> CGPoint
    {
        if ParentWindow!.windowNumber < 0
        {
            return CGPoint.zero
        }
        let CurrentID = CGWindowID(ParentWindow!.windowNumber)
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
    
    /// Handle window location changed events.
    /// - Parameter notification: Not used.
    func windowDidMove(_ notification: Notification)
    {
        let WindowOrigin = WindowLocation()
        WindowMovedTo(WindowOrigin)
    }
    
    /// Handle window closing events.
    /// - Parameter notification: Not used.
    func windowWillClose(_ notification: Notification)
    {
        WillClose()
    }
    
    // MARK: - Window handling
    
    /// Handle closing events.
    func WillClose()
    {
        Debug.Print("Flatland closing.")
        if NSColorPanel.sharedColorPanelExists
        {
            if NSColorPanel.shared.isVisible
            {
                NSColorPanel.shared.close()
            }
        }
        MainSettingsDelegate?.MainClosing()
        AboutDelegate?.MainClosing()
        TodayDelegate?.MainClosing()
        QuakeDelegate?.MainClosing()
        DebugDelegate?.MainClosing()
        LiveStatusController?.MainClosing()
        Main2DView.KillTimers()
        Rect2DView.KillTimers() 
        Main3DView.KillTimers()
        ForceKillThreads()
        Debug.Print("  Flatland cleaned up.")
    }
    
    /// Handle new window size.
    func WindowResized(To: NSSize)
    {
        if !Started
        {
            return
        }
        StatusBar2.ParentWindowSizeChanged(NewSize: To)
        Settings.SetNSSize(.WindowSize, To)
        UpdateMouseWindowLocation()
    }
    
    func WindowMovedTo(_ Origin: CGPoint)
    {
        if !Started
        {
            return
        }
        Settings.SetCGPoint(.WindowOrigin, Origin)
    }
    
    /// Returns the ID of the window.
    /// - Returns: The ID of the main window.
    func WindowID() -> CGWindowID
    {
        return CGWindowID(view.window!.windowNumber)
    }
}
