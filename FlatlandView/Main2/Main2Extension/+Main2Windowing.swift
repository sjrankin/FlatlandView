//
//  +Main2Windowing.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Main2Controller
{
    // MARK: - Window handling
    
    /// Handle closing events.
    func WillClose()
    {
        MainSettingsDelegate?.MainClosing()
        AboutDelegate?.MainClosing()
        TodayDelegate?.MainClosing()
        
        print("Flatland closing.")
    }
    
    func WindowResized(To: NSSize)
    {
        if !Started
        {
            return
        }
    }
    
    /// Returns the ID of the window.
    /// - Returns: The ID of the main window.
    func WindowID() -> CGWindowID
    {
        return CGWindowID(view.window!.windowNumber)
    }
}
