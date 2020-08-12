//
//  GlobeProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol GlobeProtocol: class
{
    func PlotSatellite(Satellite: Satellites, At: GeoPoint2)
}
