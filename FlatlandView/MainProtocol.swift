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
    
    /// Called by views to request information to be displayed.
    func DisplayNodeInformation(ItemData: DisplayItem?)
}
