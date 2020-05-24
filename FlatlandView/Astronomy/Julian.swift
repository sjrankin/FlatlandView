//
//  Julian.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Julian
{
    /// Seasonal definitions.
    ///
    /// - Spring: The spring season (northern hemisphere).
    /// - Summer: The summer season (northern hemisphere).
    /// - Fall: The fall season (northern hemisphere).
    /// - Winter: The winter season (northern hemisphere).
    public enum Seasons
    {
        case Spring
        case Summer
        case Fall
        case Winter
    }
    
    /// Convert a Gregorian Date into a Julian Date.
    ///
    /// - Parameter For: The Gregorian Date to convert.
    /// - Returns: The Julian Date equivalent to the passed Gregorian Date.
    public static func GetJD(For: Date) -> Double
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: For)
        let Month = Cal.component(.month, from: For)
        let Day = Cal.component(.day, from: For)
        var G: Int = 1
        if Year < 1582
        {
            G = 0
        }
        var F = Double(Day) - 0.5
        var J = -Int(7 * (Int((Month + 9) / 12) + Year) / 4)
        var J3: Int = 0
        if G != 0
        {
            let S = (Month - 9) < 0 ? -1 : 1
            let A = abs(Month - 9)
            J3 = Int(Year + (S * Int(A / 7)))
            J3 = -Int((Int(J3 / 100) + 1) * (3 / 4))
        }
        J = J + Int(275 * (Month / 9)) + Day + (G * J3)
        J = J + 1721027 + (2 * G) + (367 * Year)
        if F >= 0
        {
            return Double(J)
        }
        F = F + 1
        return Double(J - 1)
    }
    
    /// Raise a value to a power.
    ///
    /// - Parameters:
    ///   - Y: The value to raise.
    ///   - Exponent: The power to raise Y to.
    /// - Returns: Y raised to the Exponent power.
    private static func BigY(_ Y: Double, _ Exponent: Int) -> Double
    {
        switch Exponent
        {
            case 1:
                return Y
            
            case 2:
                return Y * Y
            
            case 3:
                return Y * Y * Y
            
            case 4:
                return Y * Y * Y * Y
            
            default:
                return Y
        }
    }
    
    /// Return the Julian Date for the base seasonal date, eg, equinox or solstice.
    ///
    /// - Parameters:
    ///   - Season: The season.
    ///   - Y: Modified year (see caller).
    /// - Returns: The Julian Date for the year and season.
    public static func GetJDE(Season: Seasons, Y: Double) -> Double
    {
        var JDE: Double = 0.0
        switch Season
        {
            case .Spring:
                JDE = 2451623.80984 + (365242.37404 * Y) + (0.05169 * BigY(Y,2)) - (0.0411 * BigY(Y,3)) - (0.00057 * BigY(Y,4))
            
            case .Summer:
                JDE = 2451716.56767 + (365241.62603 * Y) + (0.00325 * BigY(Y,2)) + (0.00888 * BigY(Y,3)) - (0.00030 * BigY(Y,4))
            
            case .Fall:
                JDE = 2451810.21715 + (365242.01767 * Y) - (0.11575 * BigY(Y,2)) + (0.00337 * BigY(Y,3)) + (0.00078 * BigY(Y,4))
            
            case .Winter:
                JDE = 2541900.05952 + (365242.74049 * Y) - (0.06223 * BigY(Y,2)) - (0.00823 * BigY(Y,3)) - (0.00032 * BigY(Y,4))
        }
        return JDE
    }
    
    /// Converts a fractional day into the time.
    ///
    /// - Parameter Fraction: The fraction to convert into a time. Invalid fractions (< 0.0 or > 1.0) return a time of (0,0,0). This value should be normalized by the caller.
    /// - Returns: The time based on the fraction of the day.
    public static func FractionalDayToTime(_ Fraction: Double) -> (Int, Int, Int)
    {
        if Fraction < 0.0
        {
            return (0,0,0)
        }
        if Fraction > 1.0
        {
            return (0,0,0)
        }
        let FractionSeconds: Int = Int(Fraction * (24.0 * 60.0 * 60.0))
        let Hours = FractionSeconds / (60 * 60)
        let MinuteSeconds = FractionSeconds - (Hours * 60 * 60)
        let Minutes = MinuteSeconds / 60
        let Seconds = MinuteSeconds % 60
        return (Hours, Minutes, Seconds)
    }
    
    /// Convert the passed Julian Date to a Gregorian Date.
    ///
    /// - Parameter JD: The Julian Date to convert.
    /// - Returns: Tuple in the form/order of: (Year, Month, Day) where Day is a double with a fractional value representing the time.
    public static func JulianDateToGregorian(_ JD: Double) -> (Int, Int, Double)
    {
        let jd = JD + 0.5
        let Z = modf(jd).0
        let F = modf(jd).1
        var A: Double = 0
        if Z < 22299161
        {
            let a: Double = Double(Int((Z - 1867216.25) / 36524.25))
            A = Z + 1 + a - Double(Int(a / 4.0))
        }
        else {
            A = Z
        }
        let B = A + 1524.0
        let C = Int((B - 122.1) / 365.25)
        let D: Double = Double(Int(365.25 * Double(C)))
        let E: Double = Double(Int((B - D) / 30.6001))
        let Day: Double = B - D - Double(Int(30.6001 * E)) + F
        var Month = 0
        if E < 14
        {
            Month = Int(E - 1.0)
        }
        else
        {
            Month = Int(E - 13.0)
        }
        var Year = 0
        if Month > 2
        {
            Year = C - 4716
        }
        else
        {
            Year = C - 4715
        }
        return (Year, Month, Day)
    }
}
