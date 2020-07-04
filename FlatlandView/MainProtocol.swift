//
//  MainProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol MainProtocol: class
{
    /// Called when the main window should be refreshed.
    func Refresh(_ From: String)
    
    /// Called when a window is closed.
    func DidClose(_ WhatClosed: String)
    
    /// Debug time changed.
    func DebugTimeChanged(_ NewTime: Date)
    
    /// Debug rotation changed.
    func DebugRotationChanged(_ NewRotation: Double)
    
    /// Insert debug earthquake at the specified location.
    func InsertEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    
    /// Insert debug earthquake at a random location.
    func InsertEarthquake(Magnitude: Double)
    
    /// Fetch earthquakes out of sequence.
    func ForceFetchEarthquakes()
}
