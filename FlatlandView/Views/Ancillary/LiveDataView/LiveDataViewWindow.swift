//
//  LiveDataViewWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LiveDataViewWindow: NSWindowController, NSWindowDelegate
{
    override func windowDidLoad()
    {
        super.windowDidLoad()
        self.window?.delegate = self
    }
    
    func windowDidResize(_ notification: Notification)
    {
        print("Window resized")
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        if let OldFrame = Settings.GetRect(.LiveViewWindowFrame)
        {
            window?.setFrame(OldFrame, display: true)
        }
    }
}
