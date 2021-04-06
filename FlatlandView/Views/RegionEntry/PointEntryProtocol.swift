//
//  PointEntryProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol PointEntryProtocol: AnyObject
{
    func PointEntryComplete(Name: String, Color: NSColor, Point: GeoPoint)
    func PointEntrySessionComplete(Name: String, Color: NSColor, Point: GeoPoint)
    func PointEntryCanceled()
    func PlotPoint(Latitude: Double, Longitude: Double)
    func MovePlottedPoint(Latitude: Double, Longitude: Double)
    func RemovePin()
    func ResetMousePointer()
    func ClearMousePointer()
    func DeletePOI()
    func ResetFromPointEntry()
}
