//
//  Geocoder.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreLocation

/// Class that runs the reverse geocoder to get information on a location.
class Geocoder
{
    /// Number of places latitude and longitude values are truncated to in relation to reverse geocoding.
    public static let LookUpPrecision = 4
    
    /// Use Apple APIs to get the reverse geocoded information for the passed location.
    /// - Notes:
    ///   - Calling this API too often will result in throttling by Apple's servers.
    ///   - Locations are cached (across instantiations) to reduce stressing Apple's servers too much.
    ///   - This function assumes an internet connection - if no connection exists, errors (`nil` values) are
    ///     returned in the completion block.
    ///   - Control returns immediately to the caller with results following asynchronously.
    /// - Parameter Latitude: The latitude of the location. Precision truncated to `LookUpPrecision` places.
    /// - Parameter Longitude: The longitude of the location. Precision truncated to `LookUpPrecision` places.
    /// - Parameter Completion: Completion block called when data is returned by Apple's servers. The passed
    ///                         parameter to the completion block is a `CachedLocation` instance on success,
    ///                         nil on failure.
    public static func Reverse(Latitude: Double, Longitude: Double, Completion: ((CachedLocation?) -> ())? = nil)
    {
        let FinalLatitude = Latitude.RoundedTo(LookUpPrecision)
        let FinalLongitude = Longitude.RoundedTo(LookUpPrecision)
        if let Cached = DBIF.GetLocation(Latitude: FinalLatitude, Longitude: FinalLongitude)
        {
            Completion?(Cached)
            return
        }
        let Location = CLLocation(latitude: FinalLatitude, longitude: FinalLongitude)
        CLGeocoder().reverseGeocodeLocation(Location)
        {
            Placemarks, Error in
            if let Error = Error
            {
                Debug.Print("Reverse geocoding error: \(Error.localizedDescription)")
                Completion?(nil)
            }
            else
            {
                if let FinalPlacemark = Placemarks?.first
                {
                    let Cached = DBIF.SaveLocation(Latitude: FinalLatitude, Longitude: FinalLatitude, Location: FinalPlacemark)
                    Completion?(Cached)
                }
                else
                {
                    Completion?(nil)
                }
            }
        }
    }
}
