//
//  Earthquake2.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Encapsulates one or more earthquakes.
class Earthquake2: Equatable
{
    /// Initializer.
    /// - Parameter Sequence: For debugging purposes.
    init(Sequence: Int)
    {
        self.Sequence = Sequence
    }
    
    /// The sequence value.
    var Sequence: Int = 0
    
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
    
    /// Returns the greatest magnitude. If a given earthquake is not a cluster, this is merely the
    /// same value as in `Magnitude`. This this earthquake represents a cluster of earthquakes, the
    /// largest earthquake's magnitude will be returned.
    var GreatestMagnitude: Double
    {
        get
        {
            if let Group = Related
            {
                if !Group.isEmpty
                {
                    if let MaxMag = Group.max(by: {$0.Magnitude > $1.Magnitude})?.Magnitude
                    {
                        return MaxMag
                    }
                }
            }
                return Magnitude
        }
    }
    
    /// Returns `true` if this instance contains a cluster of earthqakes, false if not.
    var IsCluster: Bool
    {
        get
        {
            if let Group = Related
            {
                if !Group.isEmpty
                {
                    return true
                }
            }
            return false
        }
    }
    
    /// Date/time the earthquake occurred.
    var Time: Date = Date()
    
    /// Returns the difference between the current time and the time of the earthquake. Smaller
    /// values indicate more recent earthquakes.
    func GetAge() -> Double
    {
        let Now = Date()
        let Delta = Now.timeIntervalSinceReferenceDate - Time.timeIntervalSinceReferenceDate
        return Delta
    }
    
    /// Tsunami value. If 1, tsunami information _may_ exist but also may not exist.
    var Tsunami: Int = 0
    
    /// Latitude of the earthquake.
    var Latitude: Double = 0.0
    
    /// Longitude of the earthquake.
    var Longitude: Double = 0.0
    
    /// Depth of the earthquake in kilometers.
    var Depth: Double = 0.0
    
    /// Status of the event.
    var Status: String = ""
    
    /// When updated.
    var Updated: Int = 0
    
    /// Shakemap intensity.
    var MMI: Double = 0.0
    
    /// Reports from the DYFI system.
    var Felt: Int = 0
    
    /// Subjective significance value. Greater values indicate greater significance.
    var Significance: Int = 0
    
    /// How to compare earthquakes.
    static func == (lhs: Earthquake2, rhs: Earthquake2) -> Bool
    {
        return lhs.Code == rhs.Code
    }
    
    /// Related earthquakes. Used for aftershocks.
    var Related: [Earthquake2]? = nil
    
    static let DefaultTimeDelta = 5.0 * 24.0 * 60.0 * 50.0
    static let DefaultClusterDistance = 300.0
    
    /// Determines if the passed earthquake is spatially and chronologically related (but *not* geologically)
    /// to this earthquake. Used to group earthquakes together to reduce the clutter of the display.
    /// - Parameter Quake: Other earthquake to compare to this earthquake.
    /// - Parameter MaxTimeDelta: Maximum amount of time away from this earthquake the other earthquake
    ///                           must be to be related.
    /// - Parameter MaxDistanceDelta: Maximum distance from this earthquake the other earthquake must
    ///                               be to be related.
    /// - Returns: True if the passed earthquake is chronologically and spatially close to this earthquake,
    ///            false otherwise.
    func IsRelated(_ Quake: Earthquake2, MaxTimeDelta: Double = DefaultTimeDelta,
                   MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
    {
        let TimeDelta = abs(Quake.Time.timeIntervalSinceReferenceDate - Time.timeIntervalSinceReferenceDate)
        if TimeDelta > MaxTimeDelta
        {
            return false
        }
        var LatD = (Latitude - Quake.Latitude)
        var LonD = (Longitude - Quake.Longitude)
        LatD = LatD * LatD
        LonD = LonD * LonD
        let Distance = sqrt(LatD + LonD)
        if Distance > MaxDistanceDelta
        {
            return false
        }
        return true
    }
}
