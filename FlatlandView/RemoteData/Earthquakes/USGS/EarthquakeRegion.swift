//
//  EarthquakeRegion.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains one earthquake region. This is a region defined by the user to have different, user-specified
/// local parameters for displaying earthquakes.
class EarthquakeRegion: CustomStringConvertible
{
    /// Create an empty earthquake region.
    init()
    {
        IsFallback = false
        AlwaysInvisible = false
        IsEnabled = true
        _ID = UUID()
    }
    
    /// Create the fallback earthquake region.
    init(FallBack: Bool)
    {
        IsFallback = true
        IsEnabled = true
        AlwaysInvisible = true
        MinimumMagnitude = 5.0
        MaximumMagnitude = 10.0
        UpperLeft = GeoPoint2(90.0, -180.0)
        LowerRight = GeoPoint2(-90.0, 180.0)
        RegionName = "World Fallback"
        RegionColor = NSColor.clear
        BorderWidth = 0.0
        Notification = .None
        SoundName = .None
        NotifyOnNewEarthquakes = false
        Age = 5
        _ID = UUID()
    }
    
    /// Returns the string value of the region. Used for serialization.
    var description: String
    {
        get
        {
            var Value = "\(RegionName)"
            Value.append("\t")
            Value.append("\(RegionColor.Hex)")
            Value.append("\t")
            Value.append("\(BorderWidth)")
            Value.append("\t")
            Value.append("\(UpperLeft)")
            Value.append("\t")
            Value.append("\(LowerRight)")
            Value.append("\t")
            Value.append("\(MinimumMagnitude)")
            Value.append("\t")
            Value.append("\(MaximumMagnitude)")
            Value.append("\t")
            Value.append("\(Age)")
            Value.append("\t")
            Value.append("\(Notification.rawValue)")
            Value.append("\t")
            Value.append("\(SoundName.rawValue)")
            Value.append("\t")
            Value.append("\(IsFallback)")
            Value.append("\t")
            Value.append("\(IsEnabled)")
            Value.append("\t")
            Value.append("\(NotifyOnNewEarthquakes)")
            return Value
        }
    }
    
    /// Enabled flag.
    var IsEnabled: Bool = true
    /// If true, this is the fallback region, which is the entire world. Defaults to false.
    var IsFallback: Bool = false
    /// If true, the region never has its area plotted on the map. Defaults to false.
    var AlwaysInvisible: Bool = false
    /// The minimum magnitude to display.
    var MinimumMagnitude: Double = 5.0
    /// The maximum magnitude to display.
    var MaximumMagnitude: Double = 10.0
    /// Upper-left corner of the region.
    var UpperLeft: GeoPoint2 = GeoPoint2(45.0, 120.0)
    /// Lower-right corner of the region.
    var LowerRight: GeoPoint2 = GeoPoint2(40.0, 125.0)
    /// The name of the region.
    var RegionName: String = ""
    /// The color of the border of the region.
    var RegionColor: NSColor = NSColor.red
    /// The width of the earthquake region.
    var BorderWidth: Double = 0.0
    /// How to display notifications.
    var Notification: EarthquakeNotifications = .None
    /// Sound to play (depending on the value in `Notification`).
    var SoundName: NotificationSounds = .None
    /// How many days in the past to display earthquakes.
    var Age: Int = 5
    /// Notify on new earthquakes.
    var NotifyOnNewEarthquakes: Bool = false
    
    /// Decode a serialized earthquake region.
    /// - Parameter Raw: The raw, serialized earthquake region.
    /// - Returns: A populated `EarthquakeRegion` class on success, nil on error.
    public static func Decode(Raw: String) -> EarthquakeRegion?
    {
        let Parts = Raw.split(separator: "\t", omittingEmptySubsequences: true)
        if Parts.count != 13
        {
            return nil
        }
        let Region = EarthquakeRegion()
        for Index in 0 ..< Parts.count
        {
            let Part = String(Parts[Index])
            switch Index
            {
                case 0:
                    Region.RegionName = Part
                    
                case 1:
                    Region.RegionColor = NSColor(HexString: Part)!
                    
                case 2:
                    Region.BorderWidth = Double(Part)!
                    
                case 3:
                    if let UL = GeoPoint2(Raw: Part)
                    {
                        Region.UpperLeft = UL
                    }
                    else
                    {
                        return nil
                    }
                    
                case 4:
                    if let LR = GeoPoint2(Raw: Part)
                    {
                        Region.LowerRight = LR
                    }
                    else
                    {
                        return nil
                    }
                    
                case 5:
                    Region.MinimumMagnitude = Double(Part)!
                    
                case 6:
                    Region.MaximumMagnitude = Double(Part)!
                    
                case 7:
                    Region.Age = abs(Int(Part)!)
                    
                case 8:
                    Region.Notification = EarthquakeNotifications(rawValue: Part)!
                    
                case 9:
                    Region.SoundName = NotificationSounds(rawValue: Part)!
                    
                case 10:
                    Region.IsFallback = Bool(Part)!
                    
                case 11:
                    Region.IsEnabled = Bool(Part)!
                    
                case 12:
                    Region.NotifyOnNewEarthquakes = Bool(Part)!
                    
                default:
                    return nil
            }
        }
        return Region
    }
    
    /// Holds the instance ID of the region.
    private var _ID: UUID!
    /// Get the instance ID of the region.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
}


