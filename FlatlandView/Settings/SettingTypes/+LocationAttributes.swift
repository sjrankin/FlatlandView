//
//  +LocationAttributes.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - Settings related to attributes of locations.
    
    /// Returns the default city group color.
    /// - Parameter For: The city group for which the default color will be returned.
    /// - Returns: Color for the specified city group.
    public static func DefaultCityGroupColor(For: CityGroups) -> NSColor
    {
        switch For
        {
            case .AfricanCities:
                return NSColor.blue
                
            case .AsianCities:
                return NSColor.brown
                
            case .EuropeanCities:
                return NSColor.magenta
                
            case .NorthAmericanCities:
                return NSColor.green
                
            case .SouthAmericanCities:
                return NSColor.cyan
                
            case .WorldCities:
                return NSColor.red
                
            case .CapitalCities:
                return NSColor.yellow
        }
    }
    
    /// Determines if the specific longitude line should be drawn.
    /// - Parameter Longitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    public static func DrawLongitudeLine(_ Longitude: Latitudes) -> Bool
    {
        switch Longitude
        {
            case .AntarcticCircle, .ArcticCircle:
                return Settings.GetBool(.Show3DPolarCircles)
                
            case .Equator:
                return Settings.GetBool(.Show3DEquator)
                
            case .TropicOfCancer, .TropicOfCapricorn:
                return Settings.GetBool(.Show3DTropics)
        }
    }
    
    /// Determines if the specific latitude line should be drawn.
    /// - Parameter Latitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    public static func DrawLatitudeLine(_ Latitude: Longitudes) -> Bool
    {
        switch Latitude
        {
            case .PrimeMeridian, .OtherPrimeMeridian:
                return Settings.GetBool(.Show3DPrimeMeridians)
                
            case .AntiPrimeMeridian, .OtherAntiPrimeMeridian:
                return Settings.GetBool(.Show3DPrimeMeridians)
        }
    }
}
