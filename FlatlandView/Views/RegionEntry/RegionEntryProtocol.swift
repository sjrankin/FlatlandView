//
//  RegionEntryProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for the region entry dialog to communicate with the globe.
protocol RegionEntryProtocol: class
{
    /// Notify implementors that editing was successfully completed.
    func RegionEntryCompleted(Name: String, Color: NSColor, Corner1: GeoPoint, Corner2: GeoPoint)
    /// Notify implementors that a radial region editing session was successfully completed.
    func RadialRegionEntryCompleted(Name: String, Color: NSColor, Center: GeoPoint, Radius: Double)
    /// Notify implementors that region creation was canceled.
    func RegionEntryCanceled()
    /// Plot the upper-left (north west) corner of the region.
    func PlotUpperLeftCorner(Latitude: Double, Longitude: Double)
    /// Plot the lower-right (south east) corner of the region.
    func PlotLowerRightCorner(Latitude: Double, Longitude: Double)
    /// Remove the upper-left corner of the region.
    func RemoveUpperLeftCorner()
    /// Remove the lower-right corner of the region.
    func RemoveLowerRightCorner()
    /// Set the mouse pointer to a starting pin.
    func SetStartPin()
    /// Set the mouse pointer to an ending pin.
    func SetEndPin()
    /// Set the mouse point to its normal state.
    func ResetMousePointer()
    /// Plot a transient region from region data entered by the user.
    func PlotTransient(ID: UUID, Point1: GeoPoint, Point2: GeoPoint, Color: NSColor)
    /// Plot a polar transient from region data entered by the user.
    func PlotTransient(ID: UUID, NorthPole: Bool, Radius: Double, Color: NSColor)
    /// Plot a radial transient.
    func PlotTransient(ID: UUID, Center: GeoPoint, Radius: Double, Color: NSColor)
    /// Update a transient region.
    func UpdateTransient(ID: UUID, Point1: GeoPoint, Point2: GeoPoint, Color: NSColor)
    /// Update a transient polar region.
    func UpdateTransient(ID: UUID, NorthPole: Bool, Radius: Double, Color: NSColor)
    /// Update a transient radial region.
    func UpdateTransient(ID: UUID, Center: GeoPoint, Radius: Double, Color: NSColor)
    /// Remove transient regions.
    func RemoveTransientRegions()
    /// Remove the specified transient region.
    func RemoveTransientRegion(ID: UUID)
    /// Clear the mouse pointer.
    func ClearMousePointer()
    /// Removes plotted pins.
    func RemovePins()
    /// Remove a transient radial layer.
    func RemoveRadialTransientRegion(ID: UUID)
}
