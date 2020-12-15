//
//  MainProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol MainProtocol: class
{
    /// Called when the main window should be refreshed.
    func Refresh(_ From: String)
    
    /// Called when a window is closed.
    func DidClose(_ WhatClosed: String)
    
    /// Insert debug earthquake at the specified location.
    func InsertEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    
    /// Insert debug earthquake at a random location.
    func InsertEarthquake(Magnitude: Double)
    
    /// Insert a debug cluster of earthquakes.
    func InsertEarthquakeCluster(_ Count: Int)
    
    /// Fetch earthquakes out of sequence.
    func ForceFetchEarthquakes()
    
    /// Update the view type in the controls.
    func UpdateViewType()
    
    /// Called when the item viewer closes.
    func ItemViewerClosed()
    
    /// Returns the app delegate.
    func GetAppDelegate() -> AppDelegate
    
    /// Called when a child window closes.
    func ChildWindowClosed(_ ChildWindow: ChildWindows)
    
    /// Called when the mouse moves in follow-mouse mode.
    func MouseAtLocation(Latitude: Double, Longitude: Double, Caller: String)
    
    /// Show or hide the mouse location.
    func ShowMouseLocationView(_ Show: Bool)
    
    /// Returns the current earthequake class.
    func GetEarthquakeController() -> USGS?
    
    /// Returns the set of current earthquakes the main view has.
    func GetCurrentEarthquakes() -> [Earthquake]
    
    /// Sets the text of the status bar.
    /// - Parameter Text: The text to set.
    func SetStatusText(_ Text: String)
    
    /// Set text in the status bar that will disappear after the specified amount of time.
    /// - Parameter Text: The text to set.
    /// - Parameter HideAfter: The duration, in seconds, the text will be visible.
    func SetDisappearingStatusText(_ Text: String, HideAfter: Double)
    
    /// Clear text from the status bar.
    func ClearStatusText()
    
    /// Push a message to the status bar. It will show up for `PeristFor` seconds when no other
    /// messages are being shown.
    /// - Parameter Text: The text to show.
    /// - Parameter PersistFor: How long to persist the message.
    func PushStatusMessage(_ Text: String, PersistFor: Double)
    
    /// Remove any pushed messages.
    func RemovePushStatusMessage()
    
    /// Stop program execution.
    func ExitProgram()
    
    /// Reset settings to default values.
    func ResetSettings()
    
    /// Return connected to internet flag.
    func ConnectedToInternet() -> Bool
    
    /// Returns an array of UNESCO World Heritage Sites.
    /// - Returns: Array of World Heritage Site data.
    func GetWorldHeritageSites() -> [WorldHeritageSite2]
}

/// Flatland's child windows.
enum ChildWindows: String, CaseIterable
{
    /// Preferences window.
    case PreferenceWindow = "PreferenceWindow"
    /// Settings window.
    case SettingsWindow = "SettingsWindow"
    /// Debugger window.
    case DebuggerWindow = "DebuggerWindow"
}
