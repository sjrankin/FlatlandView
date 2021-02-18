//
//  RegionMouseClickProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol to tell region editors the mouse was clicked on the map.
protocol RegionMouseClickProtocol: AnyObject
{
    /// Mouse click event a geographic point on the map.
    func MouseClicked(At: GeoPoint)
}
