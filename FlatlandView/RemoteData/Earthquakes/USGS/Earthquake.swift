//
//  Earthquake.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Encapsulates one or more earthquakes. Encapsulated earthquakes are those that are in a small
/// geographic region.
class Earthquake: KMDataPoint
{
    /// Number of dimensions.
    static var NumDimensions: UInt = 2
    
    /// Dimensional data.
    var Dimensions = [Double]()
    
    /// Initializer.
    required init(Values: [Double])
    {
        Marked = false
        Latitude = Values[0]
        Longitude = Values[1]
        Dimensions = [Latitude, Longitude]
    }
    
    /// Initializer.
    /// - Parameter Sequence: For debugging purposes.
    init(Sequence: Int)
    {
        self.Sequence = Sequence
        Marked = false
        Dimensions = [Double]()
    }
    
    /// Initializer - uses data from the supplied earthquake to populate this instance.
    /// - Parameter Other: The other earthquake that will be used to populate this instance.
    /// - Parameter IncludeRelated: If true, related earthquakes in `Other` are assigned to this
    ///                             instance.
    init(_ Other: Earthquake, IncludeRelated: Bool = false)
    {
        Sequence = Other.Sequence
        Code = Other.Code
        Place = Other.Place
        Magnitude = Other.Magnitude
        Time = Other.Time
        Tsunami = Other.Tsunami
        Latitude = Other.Latitude
        Longitude = Other.Longitude
        Dimensions = [Latitude, Longitude]
        Depth = Other.Depth
        Status = Other.Status
        Updated = Other.Updated
        MMI = Other.MMI
        Felt = Other.Felt
        Significance = Other.Significance
        Marked = false
        if IncludeRelated
        {
            if let OtherRelated = Other.Related
            {
                Related = OtherRelated
            }
        }
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
    /// largest earthquake's magnitude will be returned. `0.0` returned on error.
    var GreatestMagnitude: Double
    {
        get
        {
            if let Quake = GreatestMagnitudeEarthquake
            {
                return Quake.Magnitude
            }
            return 0.0
        }
    }
    
    /// Returns the earthquake with the greatest magnitude. If there are no related earthquakes,
    /// `self` is returned.
    var GreatestMagnitudeEarthquake: Earthquake?
    {
        get
        {
            if let Group = Related
            {
                if !Group.isEmpty
                {
                    let Sorted = Group.sorted(by: {$0.Magnitude > $1.Magnitude})
                    return Sorted[0]
                }
            }
            return self
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
    
    /// Returns the number of related earthquakes.
    var ClusterCount: Int
    {
        get
        {
            if let Group = Related
            {
                return Group.count
            }
            return 0
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
    
    /// Get or set the latitude of the earthquake.
    var Latitude: Double = 0.0
    
    /// Longitude of the earthquake.
    var Longitude: Double = 0.0
    
    /// Set the location of the earthquake.
    /// - Parameter Latitude: The latitude of the earthquake.
    /// - Parameter Longitude: The longitude of the earthquake.
    func SetLocation(_ Latitude: Double, _ Longitude: Double)
    {
        Dimensions = [Latitude, Longitude]
        self.Latitude = Latitude
        self.Longitude = Longitude
    }
    
    /// Return the location of the earthquake as a `GeoPoint2` class.
    /// - Returns: A `GeoPoint2` instance initialized with the location of the earthquake.
    func LocationAsGeoPoint2() -> GeoPoint2
    {
        return GeoPoint2(Latitude, Longitude)
    }
    
    /// Depth of the earthquake in kilometers.
    var Depth: Double = 0.0
    
    /// Status of the event.
    var Status: String = ""
    
    /// When updated.
    var Updated: Date? = nil
    
    /// Shakemap intensity.
    var MMI: Double = 0.0
    
    /// Reports from the DYFI system.
    var Felt: Int = 0
    
    /// Subjective significance value. Greater values indicate greater significance.
    var Significance: Int = 0
    
    /*
    #if true
    static func == (lhs: Earthquake2, rhs: Earthquake2) -> Bool
    {
        return lhs.Latitude == rhs.Latitude && lhs.Longitude == rhs.Longitude
    }
    #else
    /// How to compare earthquakes.
    /// - Note: Earthquakes are compared by their unique IDs assigned by the USGS.
    static func == (lhs: Earthquake2, rhs: Earthquake2) -> Bool
    {
        return lhs.Code == rhs.Code
    }
    #endif
 */
 
    /// Determines if this earthquake (or any clustered/related earthquakes) have the specified
    /// Code value.
    /// - Parameter Code: The value to look for.
    /// - Returns: True if this or any sub-earthquake has a Code of `Code`, false otherwise.
    func Contains(Code: String) -> Bool
    {
        if self.Code == Code
        {
            return true
        }
        if let Clustered = Related
        {
            for RelatedEarthquake in Clustered
            {
                if RelatedEarthquake.Contains(Code: Code)
                {
                    return true
                }
            }
        }
        return false
    }
    
    /// Related earthquakes. Used for aftershocks.
    var Related: [Earthquake]? = nil
    
    /// Adds another earthquake to this earthquake if it occurs within a specific timeframe and
    /// distance.
    /// - Note: If the earthquake is already in the related list, do not add it again. In this case
    ///         `true` is returned to prevent the caller from adding it elsewhere.
    /// - Parameter Other: The other earthquake to add if it is close enough geographically and
    ///                    chronologically.
    /// - Returns: True if `Other` was added to this earthquake, false if not.
    @discardableResult func AddIfRelated(_ Other: Earthquake) -> Bool
    {
        if IsRelated(Other)
        {
            if Related == nil
            {
                Related = [Earthquake]()
            }
            for Already in Related!
            {
                if Already.Code == Other.Code
                {
                    //If the earthquake is already present, return true but do not add it.
                    return true
                }
            }
            Related?.append(Other)
            return true
        }
        return false
    }
    
    func AddToRelated(_ Other: Earthquake)
    {
        if Related == nil
        {
            Related = [Earthquake]()
        }
        Related?.append(Other)
    }
    
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
    func IsRelated(_ Quake: Earthquake, MaxTimeDelta: Double = DefaultTimeDelta,
                   MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
    {
        let TimeDelta = abs(Quake.Time.timeIntervalSinceReferenceDate - Time.timeIntervalSinceReferenceDate)
        if TimeDelta > MaxTimeDelta
        {
            return false
        }
        return IsCloseBy(Quake)
    }
    
    func IsCloseBy(_ Quake: Earthquake, MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
    {
        let DistanceToQuake = Distance(To: Quake)
        if DistanceToQuake > MaxDistanceDelta
        {
            return false
        }
        return true
    }
    
    /// Returns the distance between the instance earthquake to the passed earthquake.
    /// - Parameter Quake: The quake used to calculate the distance.
    /// - Returns: Distance between the instance earthquake and the passed earthquake, in kilometers.
    func DistanceTo(_ Quake: Earthquake) -> Double
    {
        #if true
        return DistanceTo(Quake.Latitude, Quake.Longitude)
        #else
        let Lat1 = Latitude.Radians
        let Lon1 = Longitude.Radians
        let Lat2 = Quake.Latitude.Radians
        let Lon2 = Quake.Longitude.Radians
        let LonDelta = Lon2 - Lon1
        let LatDelta = Lat2 - Lat1
        let Step1 = pow(sin(LatDelta / 2), 2) +
            cos(Lat1) * cos(Lat2) * pow(sin(LonDelta / 2), 2)
        let Step2 = 2 * asin(sqrt(Step1))
        let Step3 = Step2 * 6371
        return Step3
        #endif
    }
    
    /// Returns the distance between the instance earthquake and the passed coordinates.
    /// - Parameter OtherLatitude: The latitude of the other point.
    /// - Parameter OtherLongitude: The longitude of the other point.
    /// - Returns: Distance between the instance earthquake and the passed coordinate, in kilometers.
    func DistanceTo(_ OtherLatitude: Double, _ OtherLongitude: Double) -> Double
    {
        let Lat1 = Latitude.Radians
        let Lon1 = Longitude.Radians
        let Lat2 = OtherLatitude.Radians
        let Lon2 = OtherLongitude.Radians
        let LonDelta = Lon2 - Lon1
        let LatDelta = Lat2 - Lat1
        let Step1 = pow(sin(LatDelta / 2), 2) +
            cos(Lat1) * cos(Lat2) * pow(sin(LonDelta / 2), 2)
        let Step2 = 2 * asin(sqrt(Step1))
        let Step3 = Step2 * 6371
        return Step3
    }
    
    /// Construct the earthquake list.
    /// - Note: Duplicate earthquakes are not added.
    /// - Parameter New: The new earthquake to add to the list.
    /// - Parameter To: The existing earthquake list.
    public static func AddEarthquake(New Quake: Earthquake, To Current: inout [Earthquake])
    {
        for Existing in Current
        {
            let Added = Existing.AddIfRelated(Quake)
            if Added
            {
                return
            }
        }
        for Existing in Current
        {
            if Existing.Code == Quake.Code
            {
                return
            }
        }
        Current.append(Quake)
    }
    
    public func AddRelated(_ Quake: Earthquake)
    {
        if Related == nil
        {
            Related = [Earthquake]()
        }
        Related?.append(Quake)
    }
    
    public var Marked: Bool = false
    
    var description: String
    {
        return "\(Latitude),\(Longitude)"
    }
    
    // MARK: - Hashable functions.
    
    static func == (lhs: Earthquake, rhs: Earthquake) -> Bool
    {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hasValue: Int
    {
        return ObjectIdentifier(self).hashValue
    }
}
