//
//  +MainWindowing.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    // MARK: - Window handling
    
    /// Handle closing events.
    func WillClose()
    {
        MainSettingsDelegate?.MainClosing()
        AboutDelegate?.MainClosing()
        TodayDelegate?.MainClosing()
        QuakeDelegate?.MainClosing()
        
        print("Flatland closing.")
    }
    
    /// Handle new window size.
    func WindowResized(To: NSSize)
    {
        if !Started
        {
            return
        }
        Settings.SetNSSize(.WindowSize, To)
    }
    
    func WindowMovedTo(_ Origin: CGPoint)
    {
        if !Started
        {
            return
        }
        Settings.SetCGPoint(.WindowOrigin, Origin)
        //print("Window moved to \(Origin)")
    }
    
    /// Returns the ID of the window.
    /// - Returns: The ID of the main window.
    func WindowID() -> CGWindowID
    {
        return CGWindowID(view.window!.windowNumber)
    }
}
