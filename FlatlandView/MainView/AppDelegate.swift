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
    }
    
    func applicationWillFinishLaunching(_ notification: Notification)
    {
        Debug.Print("At applicationWillFinishLaunching")
    }

    /// Close the application after the last window is closed.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
    }
    
    @IBOutlet weak var LockUnlockMenuItem: NSMenuItem!
    @IBOutlet weak var DecorateMenuItem: NSMenuItem!
    @IBOutlet weak var MagnitudeFilterMenu: NSMenuItem!
    @IBOutlet weak var AgeFilterMenu: NSMenuItem!
    @IBOutlet weak var EarthquakeMenu: NSMenuItem!
    @IBOutlet weak var MainMenu: NSMenu!
}
