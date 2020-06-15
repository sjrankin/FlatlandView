//
//  Earthquake.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Encapsulates one earthquake.
class Earthquake
{
    /// USGS earthquake code/ID.
    var Code: String = ""
    
    /// Holds the place name. May be blank.
    private var _Place: String = ""
    /// Get or set the name of the place of the earthquake. May be blank.
    var Place: String
    {
        get
        {
            return _Place
        }
        set
        {
            _Place = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    /// The magnitude of the earthquake.
    var Magnitude: Double = 0.0
    
    /// Date/time the earthquake occurred.
    var Time: Date = Date()
    
    /// Tsunami value. If 1, tsunami information _may_ exist but also may not exist.
    var Tsunami: Int = 0
    
    /// Latitude of the earthquake.
    var Latitude: Double = 0.0
    
    /// Longitude of the earthquake.
    var Longitude: Double = 0.0
    
    /// Depth of the earthquake in kilometers.
    var Depth: Double = 0.0
}
