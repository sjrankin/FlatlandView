//
//  AppDelegate.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 5/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
    }
    
    func applicationWillFinishLaunching(_ notification: Notification)
    {
        print("At applicationWillFinishLaunching")
    }

    /// Close the application after the last window is closed.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }
}

