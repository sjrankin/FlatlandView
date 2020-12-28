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
/// - Note: See [ComCatDocumentation - Event Terms](https://earthquake.usgs.gov/data/comcat/data-eventterms.php)
class Earthquake: KMDataPoint, Hashable, CustomStringConvertible
{
    /// Number of dimensions.
    static var NumDimensions: UInt = 2
    
    /// Dimensional data.
    var Dimensions = [Double]()
    
    /// Initializer.
    required init(Values: [Double])
    {
        GreatestMagnitudeValue = 0.0
        Marked = false
        Latitude = Values[0]
        Longitude = Values[1]
        Dimensions = [Latitude, Longitude]
    }
    
    /// Initializer.
    /// - Parameter Latitude: The latitude of the earthquake.
    /// - Parameter Longitude: The longitude of the earthquake.
    /// - Parameter Magnitude: The magnitude of the earthquake.
    /// - Parameter IsDebug: Sets the debug flag. Defaults to `false`.
    init(Latitude: Double, Longitude: Double, Magnitude: Double, IsDebug: Bool = false)
    {
        GreatestMagnitudeValue = 0.0
        Marked = false
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Magnitude = Magnitude
        DebugQuake = IsDebug
        if IsDebug
        {
            Title = "Injected debug earthquake"
        }
    }
    
    /// Initializer.
    /// - Parameter Sequence: For debugging purposes.
    init(Sequence: Int)
    {
        self.Sequence = Sequence
        GreatestMagnitudeValue = 0.0
        Marked = false
        Dimensions = [Double]()
    }
    
    /// Initializer - uses data from the supplied earthquake to populate this instance.
    /// - Parameter Other: The other earthquake that will be used to populate this instance.
    /// - Parameter IncludeRelated: If true, related earthquakes in `Other` are assigned to this
    ///                             instance.
    /// - Parameter IsBiggest: Flag that determines if the quake is the biggest in a set.
    init(_ Other: Earthquake, IncludeRelated: Bool = false, IsBiggest: Bool = false)
    {
        _IsBiggest = IsBiggest
        GreatestMagnitudeValue = 0.0
        EventID = Other.EventID
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
        MagType = Other.MagType
        MagError = Other.MagError
        MagNST = Other.MagNST
        DMin = Other.DMin
        Alert = Other.Alert
        Title = Other.Title
        Types = Other.Types
        EventType = Other.EventType
        Detail = Other.Detail
        TZ = Other.TZ
        Net = Other.Net
        NST = Other.NST
        Gap = Other.Gap
        IDs = Other.IDs
        HorizontalError = Other.HorizontalError
        CDI = Other.CDI
        RMS = Other.RMS
        NPH = Other.NPH
        LocationSource = Other.LocationSource
        MagSource = Other.MagSource
        EventPageURL = Other.EventPageURL
        Sources = Other.Sources
        DepthError = Other.DepthError
        Marked = false
        DebugQuake = Other.DebugQuake
        if IncludeRelated
        {
            if let OtherRelated = Other.Related
            {
                Related = OtherRelated
            }
        }
    }
    
    /// Holds the biggest earthquake flag.
    private var _IsBiggest: Bool = false
    /// Get the biggest earthquake flag.
    public var IsBiggest: Bool
    {
        get
        {
            return _IsBiggest
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
            objc_sync_enter(EarthquakeLock)
            defer{objc_sync_exit(EarthquakeLock)}
            if let Quake = GreatestMagnitudeEarthquake
            {
                return Quake.Magnitude
            }
            return 0.0
        }
    }
    
    var GreatestMagnitudeValue: Double = 0.0
    
    /// Returns the earthquake with the greatest magnitude. If there are no related earthquakes,
    /// `self` is returned.
    var GreatestMagnitudeEarthquake: Earthquake?
    {
        get
        {
            objc_sync_enter(EarthquakeLock)
            defer{objc_sync_exit(EarthquakeLock)}
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
    
    /// Return the location of the earthquake as a `GeoPoint` class.
    /// - Returns: A `GeoPoint` instance initialized with the location of the earthquake.
    func LocationAsGeoPoint() -> GeoPoint
    {
        return GeoPoint(Latitude, Longitude)
    }
    
    /// Depth of the earthquake in kilometers.
    var Depth: Double = 0.0
    
    /// Uncertainty of the depth.
    var DepthError: Double = 0.0
    
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
    
    /// Unique (per instance) ID of the earthquake.
    var ID: UUID = UUID()
    
    /// The event ID.
    var EventID: String = ""
    
    /// How magnitude was calculated.
    /// - Notes: See [Magnitude Types](https://www.usgs.gov/natural-hazards/earthquake-hazards/science/magnitude-types?qt-science_center_objects=0#qt-science_center_objects)
    var MagType: String = ""
    
    /// Uncertainty of reported magnitude of event.
    var MagError: Double = 0.0
    
    /// Number of seismic stations used to calculate magnitude.
    var MagNST: Int = 0
    
    /// Horizontal distance from the epicenter to the nearest station in degrees.
    var DMin: Double = 0.0
    
    /// Alert level from PAGER.
    var Alert: String = ""
    
    /// Title.
    var Title: String = ""
    
    /// List of product types associated with this event.
    var Types: String = ""
    
    /// Type of seismic event.
    var EventType: String = ""
    
    /// Link to GeoJSON detail.
    var Detail: String = ""
    
    /// Timezone offset from UTC in minutes at the epicenter.
    var TZ: Int? = nil
    
    /// Link to USGS event page for the event.
    var EventPageURL: String = ""
    
    /// List of network contributors.
    var Sources: String = ""
    
    /// ID of data contributors.
    var Net: String = ""
    
    /// Number of seismic stations used to determine location.
    var NST: Int = 0
    
    /// The largest azimuthal gap between adjacent stations.
    var Gap: Double = 0
    
    /// List of event IDs associated with an event.
    var IDs: String = ""
    
    /// Uncertainty of reported location of even in kilometers.
    var HorizontalError: Double = 0.0
    
    /// Maximum reported intensity for the event - computed by DYFI. Should be reported as a Roman numeral.
    var CDI: Double = 0.0
    
    /// Root mean square travel time residual in seconds.
    var RMS: Double = 0.0
    
    /// Number of phases used.
    var NPH: String = ""
    
    /// Network that authored the report.
    var LocationSource: String = ""
    
    /// Network that generated the magnitude.
    var MagSource: String = ""
    
    /// Distance from something else. If nil, no distance used.
    var ContextDistance: Double? = nil
    
    /// If true, the earthquake was injected and is intended for debug use.
    var DebugQuake: Bool = false
    
    // MARK: - Code for data manipulation
    
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
    
    /// Remove duplicate earthquakes from the related earthquake list. If there are no child earthquakes,
    /// no action is taken.
    public func RemoveDuplicates()
    {
        if let Children = Related
        {
            var Unique = [String: Earthquake]()
            for Quake in Children
            {
                if let _ = Unique[Quake.Code]
                {
                    continue
                }
                Unique[Quake.Code] = Quake
            }
            Related = Children
        }
    }
    
    /// Adds another earthquake to this earthquake if it occurs within a specific timeframe and
    /// distance.
    /// - Note: If the earthquake is already in the related list, do not add it again. In this case
    ///         `true` is returned to prevent the caller from adding it elsewhere.
    /// - Parameter Other: The other earthquake to add if it is close enough geographically and
    ///                    chronologically.
    /// - Returns: True if `Other` was added to this earthquake, false if not.
    @discardableResult func AddIfRelated(_ Other: Earthquake) -> Bool
    {
        objc_sync_enter(EarthquakeLock)
        defer{objc_sync_exit(EarthquakeLock)}
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
            if Other.Magnitude > GreatestMagnitudeValue
            {
                GreatestMagnitudeValue = Other.Magnitude
            }
            return true
        }
        return false
    }
    
    func AddToRelated(_ Other: Earthquake)
    {
        objc_sync_enter(EarthquakeLock)
        defer{objc_sync_exit(EarthquakeLock)}
        if Related == nil
        {
            Related = [Earthquake]()
        }
        Related?.append(Other)
        if Other.Magnitude > GreatestMagnitudeValue
        {
            GreatestMagnitudeValue = Other.Magnitude
        }
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
    
    private var EarthquakeLock = NSObject()
    
    /// Add an earthquake related to this earthquake as a sub-earthquake. "Related" only means the passed
    /// earthquake happened within a certain distance and time of this earthquake, not that they are necessarily
    /// due to the same cause.
    /// - Note: Only one thread at a time is allowed to access this function and it is synchronized to
    ///         enforce that.
    /// - Parameter Quake: The quake to add to this quake's related earthquakes.
    public func AddRelated(_ Quake: Earthquake)
    {
        objc_sync_enter(EarthquakeLock)
        defer{objc_sync_exit(EarthquakeLock)}
        if Related == nil
        {
            Related = [Earthquake]()
        }
        Related?.append(Quake)
        if Quake.Magnitude > GreatestMagnitudeValue
        {
            GreatestMagnitudeValue = Quake.Magnitude
        }
    }
    
    public var Marked: Bool = false
    
    var description: String
    {
        if let Related = Related
        {
            return "\(Magnitude.RoundedTo(3))@(\(Latitude),\(Longitude))#=\(Related.count), Max=\(GreatestMagnitude)"
        }
        else
        {
            return "\(Magnitude.RoundedTo(3))@(\(Latitude),\(Longitude))#=0"
        }
    }
    
    // MARK: - Hashable functions.
    
    static func == (lhs: Earthquake, rhs: Earthquake) -> Bool
    {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(Code)
    }
    
    var hasValue: Int
    {
        return ObjectIdentifier(self).hashValue
    }
}
