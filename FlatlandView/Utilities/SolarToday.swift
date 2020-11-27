//
//  SolarToday.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Calculates various time events for a geographical point for a given date.
class SolarToday
{
    /// Type alias for the initializer closure.
    typealias GeocoderCompletedType = ((Bool) -> ())
    
    /// Initializer.
    /// - Note: Data will become available asynchronously and is dependent on a working internet connection to
    ///         Apple's servers to get certain information.
    /// - Warning: If the caller does not specify the closure, the caller will not be notified when all
    ///            results will be available.
    /// - Parameter For: The date to get the times for.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Completed: The closure that will receive the notification when data are available. The
    ///                        parameter will be true on success, false on failure.
    init?(For When: Date, Latitude: Double, Longitude: Double, _ Completed: GeocoderCompletedType? = nil)
    {
        SolarDate = When
        self.Latitude = Latitude
        self.Longitude = Longitude
        GeocoderCompleted = Completed
        let Location = CLLocation(latitude: Latitude, longitude: Longitude)
        if !CLLocationCoordinate2DIsValid(Location.coordinate)
        {
            return nil
        }
        let GeoCoder = CLGeocoder()
        GeoCoder.reverseGeocodeLocation(Location, completionHandler: GeocoderCompletion)
    }
    
    /// Closure to finalized location and times. Called by `reverseGeocodeLocation`.
    /// - Parameter Placemarks: Array of returned placemarks.
    /// - Parameter Err: If present the error returned.
    func GeocoderCompletion(_ Placemarks: [CLPlacemark]?, _ Err: Error?)
    {
        if let SomeError = Err
        {
            Debug.Print("Error \(SomeError.localizedDescription) returned by reverseGeocodeLocation.")
            GeocoderCompleted?(false)
        }
        if let PM = Placemarks?[0]
        {
            Country = PM.country ?? "unknown"
            let TimeZoneDescription = PM.timeZone?.description ?? "unknown"
            Timezone = PM.timeZone
            let Offset = PM.timeZone?.secondsFromGMT()
            var OffsetString = ""
            if let TZOffset = Offset
            {
                let OffsetValue = TZOffset / (60 * 60)
                var OffsetSign = ""
                if OffsetValue > 0
                {
                    OffsetSign = "+"
                }
                OffsetString = "\(OffsetSign)\(OffsetValue)"
            }
            PrettyTimezoneName = "\(CleanupTimezone(TimeZoneDescription)) \(OffsetString)"
            if let TZ = PM.timeZone
            {
                TimezoneSeconds = TZ.secondsFromGMT(for: SolarDate!)
            }
            CalculateTimes()
            GeocoderCompleted?(true)
            return
        }
        GeocoderCompleted?(false)
    }
    
    /// Clean up the raw timezone string.
    /// - Parameter Raw: The timezone string from Apple.
    /// - Returns: Cleaned up string with the "(something)" string removed.
    func CleanupTimezone(_ Raw: String) -> String
    {
        let Parts = Raw.split(separator: "(", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return Raw
        }
        let CleanedUp = String(Parts[0]).trimmingCharacters(in: .whitespaces)
        return CleanedUp
    }
    
    /// Calculate the times for the date and location.
    func CalculateTimes()
    {
        
    }
    
    private var GeocoderCompleted: GeocoderCompletedType? = nil
    fileprivate(set) var SolarDate: Date? = nil
    fileprivate(set) var Sunrise: Date? = nil
    fileprivate(set) var Sunset: Date? = nil
    fileprivate(set) var LocalNoon: Date? = nil
    fileprivate(set) var DaylightHours: Double? = nil
    fileprivate(set) var DaylightPercent: Double? = nil
    fileprivate(set) var Latitude: Double? = nil
    fileprivate(set) var Longitude: Double? = nil
    fileprivate(set) var Timezone: TimeZone? = nil
    fileprivate(set) var TimezoneSeconds: Int? = nil
    fileprivate(set) var PrettyTimezoneName: String? = nil
    fileprivate(set) var Country: String? = nil
}
