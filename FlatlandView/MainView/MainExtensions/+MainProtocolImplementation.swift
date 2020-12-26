//
//  +MainProtocolImplementation.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController: MainProtocol
{
    // MARK: - Main protocol functions
    
    /// Refresh called from someone who changed something. Provides alternative method for setting
    /// changes.
    /// - Parameter From: The caller's label.
    func Refresh(_ From: String)
    {
    }
    
    /// Handle auxiliary window closing events.
    /// - Parameter WhatClosed: Indicates which window closed.
    func DidClose(_ WhatClosed: String)
    {
        switch WhatClosed
        {
            case "MainSettings":
                MainSettingsDelegate = nil
                SettingsWindowOpen = false
                
            default:
                break
        }
    }
    
    /// Insert debug earthquake at the specified location.
    func InsertEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    {
        #if DEBUG
        Earthquakes?.InsertDebugEarthquake(Latitude: Latitude, Longitude: Longitude, Magnitude: Magnitude)
        #endif
    }
    
    /// Insert debug earthquake at a random location.
    func InsertEarthquake(Magnitude: Double)
    {
        #if DEBUG
        let Latitude = Double.random(in: -90.0 ... 90.0)
        let Longitude = Double.random(in: -180.0 ... 180.0)
        Earthquakes?.InsertDebugEarthquake(Latitude: Latitude, Longitude: Longitude, Magnitude: Magnitude)
        #endif
    }
    
    /// Force fetch earthquakes.
    func ForceFetchEarthquakes()
    {
        #if DEBUG
        Earthquakes?.ForceFetch()
        #endif
    }
    
    /// Insert a cluster of earthquakes for debugging.
    /// - Parameter Count: Number of earthquakes to insert.
    func InsertEarthquakeCluster(_ Count: Int)
    {
        #if DEBUG
        Earthquakes?.InsertEarthquakeCluster(Count)
        #endif
    }
    
    /// Update the view type in the controls.
    func UpdateViewType()
    {
    }
    
    /// Obsolete.
    func ItemViewerClosed()
    {
    }
    
    /// Returns the main program's app delegate.
    /// - Returns: Main program app delegate.
    func GetAppDelegate() -> AppDelegate
    {
        return MainApp
    }
    
    /// Called when a child window is closed.
    /// - Parameter ChildWindow: The child window that was closed.
    func ChildWindowClosed(_ ChildWindow: ChildWindows)
    {
        switch ChildWindow
        {
            case .DebuggerWindow:
                DebuggerOpen = false
                
            case .PreferenceWindow:
                PreferencesWindowOpen = false
                
            case .SettingsWindow:
                SettingsWindowOpen = false
        }
    }
    
    /// Display the geographic location under the mouse.
    func MouseAtLocation(Latitude: Double, Longitude: Double, Caller: String)
    {
        ShowMouseLocation(Latitude: Latitude, Longitude: Longitude, Caller: Caller)
    }
    
    /// Show or hide the mouse location.
    /// - Parameter Show: Determines whether the mouse location view is visible or hidden.
    func ShowMouseLocationView(_ Show: Bool)
    {
        SetMouseLocationVisibility(Visible: Show)
    }
    
    /// Returns the current earthquake class.
    func GetEarthquakeController() -> USGS?
    {
        return Earthquakes
    }
    
    /// Returns the set of current earthquakes.
    func GetCurrentEarthquakes() -> [Earthquake]
    {
        return LatestEarthquakes
    }
    
    /// Sends the passed text to the simple status display.
    /// - Parameter Text: The text to display.
    func SetStatusText(_ Text: String)
    {
        ShowStatusText(Text)
    }
    
    /// Sends the passed text to the simple status display.
    /// - Parameter Text: The text to display.
    /// - Parameter HideAfter: The duration in seconds for the amount of time to hide the text after
    ///                        it is displayed.
    func SetDisappearingStatusText(_ Text: String, HideAfter: Double)
    {
        ShowStatusText(Text, For: HideAfter)
    }
    
    /// Clears the status display of text.
    func ClearStatusText()
    {
        ShowStatusText("")
    }
    
    /// Push a message to the status bar. It will show up for `PeristFor` seconds when no other
    /// messages are being shown.
    /// - Parameter Text: The text to show.
    /// - Parameter PersistFor: How long to persist the message.
    func PushStatusMessage(_ Text: String, PersistFor: Double)
    {
        PushMessage(Text, Duration: PersistFor, ID: UUID())
    }
    
    /// Remove any pushed messages.
    func RemovePushStatusMessage()
    {
        RemovePushedMessage()
    }
    
    /// Force an exit of Flatland.
    /// - Notes: [Terminal application](https://developer.apple.com/forums/thread/106825)
    func ExitProgram()
    {
        for Running in NSWorkspace.shared.runningApplications
        {
            if Running.localizedName == "Flatland"
            {
                Running.terminate()
            }
        }
    }
    
    /// Reset settings here.
    func ResetSettings()
    {
        
    }
    
    /// Returns the connected-to-internet status.
    /// - Returns: True if the system is connected to the internet, false if not.
    func ConnectedToInternet() -> Bool
    {
        return CurrentlyConnected
    }
    
    func GetWorldHeritageSites() -> [WorldHeritageSite]
    {
        return GetAllWorldHeritageSites()
    }
    
    /// Move the 3D globe (only valid for 3D globes) to the specified location.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longiutde: The longitude of the location.
    /// - Parameter UdpateOpacity: If true, opacity is updated. If false, no changes are made.
    func MoveMapTo(Latitude: Double, Longitude: Double, UpdateOpacity: Bool)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
        {
            Main3DView.MoveMapTo(Latitude: Latitude, Longitude: Longitude, UpdateOpacity: UpdateOpacity)
        }
    }
    
    /// Lock the 3D globe to the time and reset its position.
    func LockMapToTimer()
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
        {
            Main3DView.LockMapToTimer()
        }
    }
}
