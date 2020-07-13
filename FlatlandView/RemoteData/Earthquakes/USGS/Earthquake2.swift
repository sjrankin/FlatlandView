//
//  Earthquake2.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Encapsulates one or more earthquakes. Encapsulated earthquakes are those that are in a small
/// geographic region.
class Earthquake2: KMDataPoint
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
    init(_ Other: Earthquake2)
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
    var GreatestMagnitudeEarthquake: Earthquake2?
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
    var Related: [Earthquake2]? = nil
    
    /// Adds another earthquake to this earthquake if it occurs within a specific timeframe and
    /// distance.
    /// - Note: If the earthquake is already in the related list, do not add it again. In this case
    ///         `true` is returned to prevent the caller from adding it elsewhere.
    /// - Parameter Other: The other earthquake to add if it is close enough geographically and
    ///                    chronologically.
    /// - Returns: True if `Other` was added to this earthquake, false if not.
    @discardableResult func AddIfRelated(_ Other: Earthquake2) -> Bool
    {
        if IsRelated(Other)
        {
            if Related == nil
            {
                Related = [Earthquake2]()
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
    
    func AddToRelated(_ Other: Earthquake2)
    {
        if Related == nil
        {
            Related = [Earthquake2]()
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
    func IsRelated(_ Quake: Earthquake2, MaxTimeDelta: Double = DefaultTimeDelta,
                   MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
    {
        let TimeDelta = abs(Quake.Time.timeIntervalSinceReferenceDate - Time.timeIntervalSinceReferenceDate)
        if TimeDelta > MaxTimeDelta
        {
            return false
        }
        return IsCloseBy(Quake)
    }
    
    func IsCloseBy(_ Quake: Earthquake2, MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
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
    func DistanceTo(_ Quake: Earthquake2) -> Double
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
    public static func AddEarthquake(New Quake: Earthquake2, To Current: inout [Earthquake2])
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
    
    public func AddRelated(_ Quake: Earthquake2)
    {
        if Related == nil
        {
            Related = [Earthquake2]()
        }
        Related?.append(Quake)
    }
    
    public var Marked: Bool = false
    
    var description: String
    {
        return "\(Latitude),\(Longitude)"
    }
    
    #if false
    /// Takes all cluster earthquakes in the passed list and changes them such that the top-most
    /// earthquake is the one with the greatest magnitude.
    /// - Parameter From: Source earthquake list.
    /// - Returns: Array of earthquakes as described.
    public static func LargestList(_ From: [Earthquake2]) -> [Earthquake2]
    {
        var Final = [Earthquake2]()
        for Quake in From
        {
            if Quake.IsCluster
            {
                if let Biggest = Quake.GreatestMagnitudeEarthquake
                {
                    let NewQuake = Earthquake2(Biggest)
                    if let InSameArea = Quake.Related
                    {
                        NewQuake.Related = [Earthquake2]()
                        for SmallerQuake in InSameArea
                        {
                            NewQuake.Related?.append(SmallerQuake)
                        }
                    }
                    Final.append(NewQuake)
                }
            }
            else
            {
                Final.append(Quake)
            }
        }
        return Final
    }
    
    /// Takes the passed list of potentially clustered earthquakes and returns a flat list with all
    /// earthquakes at the same level.
    /// - Parameter From: The source list of earthquakes.
    /// - Returns: List of earthquakes with no sub-lists.
    public static func FlatList(_ From: [Earthquake2]) -> [Earthquake2]
    {
        var Final = [Earthquake2]()
        for Quake in From
        {
            if Quake.IsCluster
            {
                if let Clustered = Quake.Related
                {
                    for Small in Clustered
                    {
                        Final.append(Small)
                    }
                }
                let NewQuake = Earthquake2(Quake)
                Final.append(NewQuake)
            }
            else
            {
                Final.append(Quake)
            }
        }
        return Final
    }
    
    public static func Combined(_ From: [Earthquake2]) -> [Earthquake2]
    {
        //First, scan the passed array to see if it already has combined earthquakes. If so,
        //return the array as is.
        for Quake in From
        {
            if Quake.IsCluster
            {
                return From
            }
        }
        
        var Final = [Earthquake2]()
        for Quake in From
        {
            if ContainsEarthquake(Code: Quake.Code, In: Final)
            {
                continue
            }
            for FQuake in Final
            {
                if FQuake.IsRelated(Quake, MaxDistanceDelta: 100.0)
                {
                    FQuake.AddToRelated(Quake)
                    continue
                }
            }
            Final.append(Quake)
        }
        Final = FinalizeCombined(Final)
        return Final
    }
    
    public static func FinalizeCombined(_ List: [Earthquake2]) -> [Earthquake2]
    {
        var Final = [Earthquake2]()
        for Quake in List
        {
            if !Quake.IsCluster
            {
                Final.append(Quake)
            }
            else
            {
                var Quakes = [Earthquake2]()
                Quakes.append(Quake)
                Quakes.append(contentsOf: Quake.Related!)
                Quakes.sort(by: {$0.Magnitude > $1.Magnitude})
                let Biggest = Quakes.first!
                Quakes.removeFirst()
                Biggest.Related = Quakes
                Final.append(Biggest)
            }
        }
        return Final
    }
    
    public static func ContainsEarthquake(Code: String, In List: [Earthquake2]) -> Bool
    {
        for Quake in List
        {
            if Quake.Contains(Code: Quake.Code)
            {
                return true
            }
        }
        return false
    }
    #endif
}
