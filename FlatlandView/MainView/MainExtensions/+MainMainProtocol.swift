//
//  +MainMainProtocol.swift
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
        if let Window = self.view.window
        {
            if let MainWindow = Window.windowController as? MainWindow
            {
                var Index = 0
                switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
                {
                    case .CubicWorld:
                        Index = 4
                        
                    case .FlatNorthCenter:
                        Index = 0
                        
                    case .FlatSouthCenter:
                        Index = 1
                        
                    case .Globe3D:
                        Index = 2
                        
                    case .Rectangular:
                        Index = 3
                }
                MainWindow.ViewSegment.selectedSegment = Index
            }
        }
    }
    
    /// Obsolete.
    func ItemViewerClosed()
    {
    }
    
    /// Display information in the proper view with data sent to us. If the data is nil, the color is
    /// changed to indicate stale data.
    /// - Parameter ItemData: The data to display.
    func DisplayNodeInformation(ItemData: DisplayItem?)
    {
        if Settings.GetBool(.ShowDetailedInformation)
        {
            if let ItemToDisplay = ItemData
            {
                DisplayItem(ItemToDisplay: ItemToDisplay)
            }
            else
            {
                SetValueTextColor(To: NSColor.lightGray)
            }
        }
    }
}
