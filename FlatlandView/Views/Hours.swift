//
//  Hours.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class Hours
{
    /// Creates a list of hours to display.
    /// - Parameter ViewType: The current view type.
    /// - Parameter HourType: The type of hour to display.
    /// - Returns: Array of tuples. Each tuple is the string to display and the integer value of the string.
    public static func GetHours(ViewType: ViewTypes, HourType: HourValueTypes) -> [(String, Int)]
    {
        var Results = [(String, Int)]()
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        var InitialOffset = 0
        if ViewType == .FlatSouthCenter
        {
            InitialOffset = 5
        }
        else
        {
            InitialOffset = 6
        }
        HourList = HourList.Shift(By: InitialOffset)
        if let LocalLongitude = Settings.GetDoubleNil(.LocalLongitude)
        {
            var DeskOffset = 0
            var Long = Int(LocalLongitude / 15.0)
            var Multiplier = 1
            if ViewType == .FlatSouthCenter
            {
                Multiplier = -1
                DeskOffset = 7
            }
            else
            {
                Multiplier = 1
                DeskOffset = -7
            }
            Long = Long * Int(Multiplier) + DeskOffset
            HourList = HourList.Shift(By: Long)
        }
        
        for Hour in 0 ... 23
        {
            var DisplayHour = (Hour + 6) % 24
            
            switch HourType
            {
                case .Solar:
                    var SolarHours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
                    if ViewType == .FlatNorthCenter
                    {
                        DisplayHour = SolarHours[(Hour + 18) % 24]
                    }
                    else
                    {
                        SolarHours = SolarHours.reversed()
                        DisplayHour = SolarHours[(Hour + 5) % 24]
                    }
                    Results.append(("\(DisplayHour)", DisplayHour))
                
                case .RelativeToLocation:
                    //Only valid if the user has entered local coordinates.
                    if let _ = Settings.GetDoubleNil(.LocalLongitude)
                    {
                        DisplayHour = HourList[Hour]
                        if ViewType == .FlatNorthCenter
                        {
                            DisplayHour = DisplayHour * -1
                        }
                    }
                    Results.append(("\(DisplayHour)", DisplayHour))
                
                case .RelativeToNoon:
                    DisplayHour = DisplayHour - 12
                    if ViewType == .FlatNorthCenter
                    {
                        DisplayHour = (DisplayHour + 12) % 24
                        if DisplayHour > 12
                        {
                            DisplayHour = DisplayHour - 24
                        }
                    }
                    else
                    {
                        DisplayHour = DisplayHour * -1
                    }
                    Results.append(("\(DisplayHour)", DisplayHour))
                
                default:
                    return []
            }
        }
        
        return Results
    }
}
