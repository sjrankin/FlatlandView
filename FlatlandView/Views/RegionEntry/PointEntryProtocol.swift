//
//  PointEntryProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for communication from the point creation code and the parent code.
protocol PointEntryProtocol: AnyObject
{
    /// Point entry is complete.
    /// - Parameter Name: Name of the point.
    /// - Parameter Color: Color of the pointer.
    /// - Parameter Point: Location of the point.
    /// - Parameter ID: ID of the edited point. If nil, a new point was created.
    func PointEntryComplete(Name: String, Color: NSColor, Point: GeoPoint, ID: UUID?)

    /// Point entry is complete. Not currently used.
    /// - Parameter Name: Name of the point.
    /// - Parameter Color: Color of the pointer.
    /// - Parameter Point: Location of the point.
    func PointEntrySessionComplete(Name: String, Color: NSColor, Point: GeoPoint)
    
    /// Point entry canceled by user.
    func PointEntryCanceled()
    
    /// Plot a point on the surface of the globe.
    /// - Parameter Latitude: Latitude of the point to plot.
    /// - Parameter Longitude: Longitude of the point to plot.
    func PlotPoint(Latitude: Double, Longitude: Double)
    
    /// Move a plotted point on the globe.
    /// - Parameter Latitude: Latitude of the point to plot.
    /// - Parameter Longitude: Longitude of the point to plot.
    func MovePlottedPoint(Latitude: Double, Longitude: Double)
    
    /// Remove the pin from the globe. (Pins are used to mark the point on the globe.)
    func RemovePin()
    
    /// Reset the mouse pointer to its default shape/appearance.
    func ResetMousePointer()
    
    /// Remove the mouse pointer.
    func ClearMousePointer()
    
    /// Delete the point.
    /// - Parameter ID: ID of the user POI to delete.
    func DeletePOI(ID: UUID)
    
    /// Reset the globe state from point entry.
    func ResetFromPointEntry()
}
