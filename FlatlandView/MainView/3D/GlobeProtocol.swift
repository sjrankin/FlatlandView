//
//  GlobeProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for the 3D Globe Node.
protocol GlobeProtocol: class
{
    /// Plot a satellite.
    /// - Parameter Satellite: The satellite to plot.
    /// - Parameter At: Where to plot the satellite.
    func PlotSatellite(Satellite: Satellites, At: GeoPoint)
}
