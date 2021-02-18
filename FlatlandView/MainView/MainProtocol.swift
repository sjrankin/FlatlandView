//
//  MainProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

protocol MainProtocol: AnyObject
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
    func GetWorldHeritageSites() -> [WorldHeritageSite]
    
    /// Move the 3D globe (only valid for 3D globes) to the specified location.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longiutde: The longitude of the location.
    /// - Parameter UpdateOpacity: Flag that determines whether opacity on the nodes on the Earth are updated.
    func MoveMapTo(Latitude: Double, Longitude: Double, UpdateOpacity: Bool)
    
    /// Lock the 3D globe to the time and reset its position.
    func LockMapToTimer()
    
    /// Set the euler angles for the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node to change.
    /// - Parameter Angles: New euler angles.
    func SetNodeEulerAngles(EditID: UUID, _ Angles: SCNVector3)
    
    /// Get the euler angles for the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node whose euler angles are returned.
    /// - Returns: Euler angles for the node whose edit ID is `EditID`, nil if not found.
    func GetNodeEulerAngles(EditID: UUID) -> SCNVector3?
    
    /// Set the location of the node whose edit ID is passed. The node is moved by this call.
    /// - Parameter EditID: The edit ID of the node to change.
    /// - Parameter Latitude: The new latitude value for the node.
    /// - Parameter Longitude: The new longitude value for the node.
    func SetNodeLocation(EditID: UUID, _ Latitude: Double, _ Longitude: Double)

    /// Get the location of the node whose edit ID is passed.
    /// - Parameter EditID: The edit ID of the node whose location is returned.
    /// - Returns: Tuple of the latitude and longitude of the node. Nil if not found.
    func GetNodeLocation(EditID: UUID) -> (Latitude: Double, Longitude: Double)?
    
    /// Lock or unlock the camera watching the world.
    /// - Parameter Locked: Sets the lock value of the camera.
    /// - Parameter ResetPosition: If true, the camera is reset to its default position. Otherwise,
    ///                            the camera is not moved.
    func SetWorldLock(_ Locked: Bool, ResetPosition: Bool)
    
    /// Make the main window focused ("key" in Apple terminology).
    func FocusWindow()
    
    /// Point the camera as the passed point.
    /// - Parameter At: The point on the globe where to point the camera.
    func PointCamera(At Point: GeoPoint)
    
    /// Reset the camera to its "natural" location.
    func ResetCameraPosition()
    
    /// Set the camera orientation.
    /// - Parameter Pitch: The pitch (X) value.
    /// - Parameter Yaw: The yaw (Y) value.
    /// - Parameter Roll: The roll (Z) value.
    func SetCameraOrientation(Pitch: Double, Yaw: Double, Roll: Double, ValuesAreRadians: Bool)
    
    /// Get the 3D point of view node.
    /// - Returns: The 3D point of view node.
    func Get3DPointOfView() -> SCNNode?

    /// Returns an array of user POI data.
    /// - Returns: Array of user POI data.
    func GetUserPOIData() -> [POI2]?
    
    /// Saves the passed array of user POI data.
    /// - Parameter POIData: Array of POI data to save.
    func SetUserPOIData(_ POIData: [POI2])
    
    /// Returns an array of additional cities.
    /// - Returns: Array of additional/other cities.
    func GetAdditionalCityData() -> [City2]?
    
    /// Saves the passed array of additional cities.
    /// - Parameter OtherCities: Array of additional cities to save.
    func SetAdditionalCityData(_ OtherCities: [City2])
    
    /// Unconditionally makes the mouse visible.
    func MakeMouseVisible()
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
    /// Live status window.
    case LiveStatusWindow = "LiveStatusWindow"
}
