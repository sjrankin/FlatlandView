//
//  RegionEntryProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol RegionEntryProtocol: class
{
    func RegionEntryCompleted(Name: String, Color: NSColor, Corner1: GeoPoint, Corner2: GeoPoint)
    func RegionEntryCanceled()
}
