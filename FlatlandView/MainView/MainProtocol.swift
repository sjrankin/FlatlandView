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
    func MouseAtLocation(Latitude: Double, Longitude: Double)
    
    /// Called when the mouse moves in follow-mouse mode.
    func MouseAtLocation(Latitude: Double, Longitude: Double, _ X: Double, _ Y: Double)
    
    /// Show or hide the mouse location.
    func ShowMouseLocationView(_ Show: Bool)
    
    /// Returns the current earthequake class.
    func GetEarthquakeController() -> USGS?
    
    func SetStatusText(_ Text: String)
    
    func SetDisappearingStatusText(_ Text: String, HideAfter: Double)
    
    func ClearStatusText()
    
    func ExitProgram()
    
    func ResetSettings()
}

enum ChildWindows: String, CaseIterable
{
    case PreferenceWindow = "PreferenceWindow"
    case SettingsWindow = "SettingsWindow"
    case DebuggerWindow = "DebuggerWindow"
}
