//
//  Utility.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreLocation
import SceneKit

class Utility
{
    /// Mean radius of the Earth in meters.
    public static let EarthRadius: Double = 6367444.7
    
    /// Calculates the haversine distance (two points on the surface of a sphere).
    /// - Note: [Swift Algorithm Club - HaversineDistance](https://github.com/raywenderlich/swift-algorithm-club/blob/master/HaversineDistance/HaversineDistance.playground/Contents.swift)
    /// - Parameter Point1: First point.
    /// - Parameter Point2: Second point.
    /// - Returns: Distance between the two points, in meters.
    public static func HaversineDistance(Point1: GeoPoint2, Point2: GeoPoint2) -> Double
    {
        let Haversine =
            {
                (Angle: Double) -> Double in
                return (1.0 - cos(Angle)) / 2.0
            }
        let AHaversine =
            {
                (Angle: Double) -> Double in
                return 2.0 * asin(sqrt(Angle))
            }
        let Lat1 = Point1.Latitude.Radians
        let Lon1 = Point1.Longitude.Radians
        let Lat2 = Point2.Latitude.Radians
        let Lon2 = Point2.Longitude.Radians
        
        let Distance = EarthRadius * AHaversine(Haversine(Lat2 - Lat1) + cos(Lat1) * cos(Lat2) * Haversine(Lon2 - Lon1))
        return Distance
    }
    
    /// Calculates the distance between the two passed earthquakes. Assumes both earthquakes are at the
    /// surface of the Earth.
    /// - Parameter Quake1: First earthquake.
    /// - Parameter Quake2: Second earthquake.
    /// - Returns: Distance between the two earthquakes, in meters.
    public static func HaversineDistance(Quake1: Earthquake2, Quake2: Earthquake2) -> Double
    {
        return HaversineDistance(Point1: GeoPoint2(Quake1.Latitude, Quake1.Longitude),
                                 Point2: GeoPoint2(Quake2.Latitude, Quake2.Longitude))
    }
    
    /// Calculates the distance between the two coordinates.
    /// - Parameter Latitude1: Latitude of first location.
    /// - Parameter Longitude1: Longitude of first location.
    /// - Parameter Latitude2: Latitude of second location.
    /// - Parameter Longitude2: Longitude of second location.
    /// - Returns: Distance between the two locations, in meters.
    public static func HaversineDistance(Latitude1: Double, Longitude1: Double,
                                         Latitude2: Double, Longitude2: Double) -> Double
    {
        return HaversineDistance(Point1: GeoPoint2(Latitude1, Longitude1),
                                 Point2: GeoPoint2(Latitude2, Longitude2))
    }
    
    /// Return the width of the string.
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - TheFont: The font that will be used to render the string.
    /// - Returns: Width of the string.
    public static func StringWidth(TheString: String, TheFont: NSFont) -> CGFloat
    {
        let FontAttrs = [NSAttributedString.Key.font: TheFont]
        let TextWidth = (TheString as NSString).size(withAttributes: FontAttrs)
        return TextWidth.width
    }
    
    /// Return the height of the string.
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - TheFont: The font that will be used to render the string.
    /// - Returns: Height of the string.
    public static func StringHeight(TheString: String, TheFont: NSFont) -> CGFloat
    {
        let FontAttrs = [NSAttributedString.Key.font: TheFont]
        let TextHeight = (TheString as NSString).size(withAttributes: FontAttrs)
        return TextHeight.height
    }
    
    /// Return the width of the string.
    /// - Note: [Calculate width of string](https://stackoverflow.com/questions/1324379/how-to-calculate-the-width-of-a-text-string-of-a-specific-font-and-font-size)
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - FontName: The font the string will be rendered in.
    ///   - FontSize: The size of the font.
    /// - Returns: The width of the string.
    public static func StringWidth(TheString: String, FontName: String, FontSize: CGFloat) -> CGFloat
    {
        if let TheFont = NSFont(name: FontName, size: FontSize)
        {
            let FontAttrs = [NSAttributedString.Key.font: TheFont]
            let TextWidth = (TheString as NSString).size(withAttributes: FontAttrs)
            return TextWidth.width
        }
        return 0.0
    }
    
    /// Return the height of the string.
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - FontName: The font the string will be rendered in.
    ///   - FontSize: The size of the font.
    /// - Returns: The height of the string.
    public static func StringHeight(TheString: String, FontName: String, FontSize: CGFloat) -> CGFloat
    {
        if let TheFont = NSFont(name: FontName, size: FontSize)
        {
            let FontAttrs = [NSAttributedString.Key.font: TheFont]
            let TextHeight = (TheString as NSString).size(withAttributes: FontAttrs)
            return TextHeight.height
        }
        return 0.0
    }
    
    /// Given a string, a font, and a constraining size, return the size of the largest font that will fit in the
    /// constraint.
    /// - Parameters:
    ///   - HorizontalConstraint: Constraint - the returned font size will ensure the string will fit into this horizontal constraint.
    ///   - TheString: The string to fit into the constraint.
    ///   - FontName: The name of the font to draw the text.
    ///   - Margin: Extra value to subtrct from the HorizontalConstraint.
    /// - Returns: Font size to use with the specified font and text.
    public static func RecommendedFontSize(HorizontalConstraint: CGFloat, TheString: String, FontName: String, MinimumFontSize: CGFloat = 12.0,
                                           Margin: CGFloat = 40.0) -> CGFloat
    {
        let ConstraintWithMargin = HorizontalConstraint - Margin
        var LastGoodSize: CGFloat = 0.0
        for Scratch in 1...500
        {
            let TextWidth = StringWidth(TheString: TheString, FontName: FontName, FontSize: CGFloat(Scratch))
            if (TextWidth > ConstraintWithMargin)
            {
                return LastGoodSize
            }
            LastGoodSize = CGFloat(Scratch)
        }
        return MinimumFontSize
    }
    
    public static func RecommendedFontSize(HorizontalConstraint: CGFloat, VerticalConstraint: CGFloat, TheString: String,
                                           FontName: String, MinimumFontSize: CGFloat = 12.0, HorizontalMargin: CGFloat = 40.0,
                                           VerticalMargin: CGFloat = 20.0) -> CGFloat
    {
        var FinalFontName = FontName
        #if false
        if !StaticFontNames.contains(FontName)
        {
            FinalFontName = FontName.replacingOccurrences(of: " ", with: "")
        }
        #endif
        let HConstraint = HorizontalConstraint - HorizontalMargin
        let VConstraint = VerticalConstraint - VerticalMargin
        var LastGoodSize: CGFloat = 0.0
        for Scratch in 1...500
        {
            let TextWidth = StringWidth(TheString: TheString, FontName: FinalFontName, FontSize: CGFloat(Scratch))
            let TextHeight = StringHeight(TheString: TheString, FontName: FinalFontName, FontSize: CGFloat(Scratch))
            if TextWidth > HConstraint && TextHeight > VConstraint
            {
                return LastGoodSize
            }
            LastGoodSize = CGFloat(Scratch)
        }
        return MinimumFontSize
    }
    
    /// Round the passed Float as specified.
    /// http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    ///
    /// - Parameters:
    ///   - Value: The Float value to round.
    ///   - ToNearest: Where to round the value to.
    /// - Returns: Rounded value.
    public static func RoundTo(_ Value: Float, ToNearest: Float) -> Float
    {
        return roundf(Value / ToNearest) * ToNearest
    }
    
    /// Round the passed Double as specified.
    /// http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    ///
    /// - Parameters:
    ///   - Value: The Double value to round.
    ///   - ToNearest: Where to round the value to.
    /// - Returns: Rounded value.
    public static func RoundTo(_ Value: Double, ToNearest: Double) -> Double
    {
        return round(Value / ToNearest) * ToNearest
    }
    
    /// Round the passed CGFloat as specified.
    /// http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    ///
    /// - Parameters:
    ///   - Value: The CGFloat value to round.
    ///   - ToNearest: Where to round the value to.
    /// - Returns: Rounded value.
    public static func RoundTo(_ Value: CGFloat, ToNearest: CGFloat) -> CGFloat
    {
        return CGFloat(round(Value / ToNearest) * ToNearest)
    }
    
    /// Truncate a double value to the number of places.
    ///
    /// - Parameters:
    ///   - Value: Value to truncate.
    ///   - ToPlaces: Where to truncate the value.
    /// - Returns: Truncated double value.
    public static func Truncate(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces)
        let X1: Double = Double(truncating: X as NSNumber)
        let Working: Int = Int(Value * X1)
        let Final: Double = Double(Working) / X1
        return Final
    }
    
    /// Round a double value to the specified number of places.
    ///
    /// - Parameters:
    ///   - Value: Value to round.
    ///   - ToPlaces: Number of places to round to.
    /// - Returns: Rounded value.
    public static func Round(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces + 1)
        let X1: Double = Double(truncating: X as NSNumber)
        var Working: Int = Int(Value * X1)
        let Last = Working % 10
        Working = Working / 10
        if Last >= 5
        {
            Working = Working + 1
        }
        let Final: Double = Double(Working) / (X1 / 10.0)
        return Final
    }
    
    /// Make a string with the elapsed time.
    /// - Parameters:
    ///   - Seconds: Duration of the elapsed time in seconds.
    ///   - AppendSeconds: If true, the numer of seconds is added to the final string.
    /// - Returns: String equivalent of the elapsed time.
    public static func MakePrettyElapsedTime(_ Seconds: Int, AppendSeconds: Bool = true) -> String
    {
        if Seconds < 0
        {
            return ""
        }
        if Seconds == 0
        {
            return "0 seconds"
        }
        if Seconds == 1
        {
            return "1 second"
        }
        if Seconds < 60
        {
            return "\(Seconds) seconds"
        }
        let Hours = Seconds / (60 * 60)
        let Minutes = (Seconds % 3600) / 60
        var Result = ""
        if Hours > 0
        {
            Result = Result + String(describing: Hours) + ":"
        }
        if Minutes > 0
        {
            let Extra = Minutes < 10 ? "0" : ""
            Result = Result + Extra + String(describing: Minutes) + ":"
        }
        let RemainingSeconds = Seconds % 60
        let Extra = RemainingSeconds < 10 ? "0" : ""
        Result = Result + Extra + String(describing: RemainingSeconds)
        return Result
    }
    
    /// Create a Date structure with the passed time.
    /// - Parameters:
    ///   - Hours: Hours value.
    ///   - Minutes: Minutes value.
    ///   - Seconds: Seconds value.
    /// - Returns: Date structure initialized with the passed time.
    public static func MakeTimeFrom(Hours: Int, Minutes: Int, Seconds: Int = 0) -> Date
    {
        var Comp = DateComponents()
        Comp.hour = Hours
        Comp.minute = Minutes
        Comp.second = Seconds
        let Cal = Calendar.current
        let TheTime = Cal.date(from: Comp)
        return TheTime!
    }
    
    /// Convert an integer into a string and pad left with the specified number of zeroes.
    ///
    /// - Parameters:
    ///   - Value: Value to convert to a string.
    ///   - Count: Number of zeroes to pad left.
    /// - Returns: Value converted to a string then padded left with the specified number of zero characters.
    public static func PadLeft(Value: Int, Count: Int) -> String
    {
        var z = String(describing: Value)
        if z.count < Count
        {
            while z.count < Count
            {
                z = "0" + z
            }
        }
        return z
    }
    
    /// Convert a Date structure into a string.
    ///
    /// - Parameter Raw: The date to convert into a string.
    /// - Returns: String equivalent of the passed date.
    public static func MakeStringFrom(_ Raw: Date) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        let Hour = Cal.component(.hour, from: Raw)
        let Minute = Cal.component(.minute, from: Raw)
        let Second = Cal.component(.second, from: Raw)
        let DatePart = "\(PadLeft(Value: Year, Count: 4))-\(PadLeft(Value: Month, Count: 2))-\(PadLeft(Value: Day, Count: 2)) "
        let TimePart = "\(PadLeft(Value: Hour, Count: 2)):\(PadLeft(Value: Minute, Count: 2)):\(PadLeft(Value: Second, Count: 2))"
        return DatePart + TimePart
    }
    
    /// Given a Date structure, return the date.
    ///
    /// - Parameter Raw: Date structure to convert.
    /// - Returns: Date portion of the date as a string.
    public static func MakeDateStringFrom(_ Raw: Date) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        let DatePart = "\(PadLeft(Value: Year, Count: 4))-\(PadLeft(Value: Month, Count: 2))-\(PadLeft(Value: Day, Count: 2))"
        return DatePart
    }
    
    /// Given a date structure, return a date in the formate day month year{, weekday}.
    ///
    /// - Parameters:
    ///   - Raw: Date structure to convert.
    ///   - AddDay: If true, the day of week is appended to the date.
    /// - Returns: Date portion of the date as a string.
    public static func MakeDateString(_ Raw: Date, AddDay: Bool = true) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        var Final = "\(Day) \(EnglishMonths[Month - 1]) \(Year)"
        if AddDay
        {
            let DayOfWeek = Cal.component(.weekday, from: Raw)
            let WeekDay = EnglishWeekDays[DayOfWeek - 1]
            Final = Final + ", \(WeekDay)"
        }
        return Final
    }
    
    /// Convert the passed string into a Date structure. String must be in the format of:
    /// yyyy-mm-dd hh:mm:ss
    ///
    /// - Parameter Raw: The string to convert.
    /// - Returns: Date equivalent of the string. nil on error.
    public static func MakeDateFrom(_ Raw: String) -> Date?
    {
        var Components = DateComponents()
        let Parts = Raw.split(separator: " ")
        if Parts.count != 2
        {
            return nil
        }
        
        let DatePart = String(Parts[0])
        let DateParts = DatePart.split(separator: "-")
        Components.year = Int(String(DateParts[0]))
        Components.month = Int(String(DateParts[1]))
        Components.day = Int(String(DateParts[2]))
        
        let TimePart = String(Parts[1])
        let TimeParts = TimePart.split(separator: ":")
        Components.hour = Int(String(TimeParts[0]))
        Components.minute = Int(String(TimeParts[1]))
        if TimeParts.count > 2
        {
            Components.second = Int(String(TimeParts[2]))
        }
        else
        {
            Components.second = 0
        }
        
        let Cal = Calendar.current
        return Cal.date(from: Components)
    }
    
    /// Given a Date structure, return a pretty string with the time.
    ///
    /// - Parameters:
    ///   - TheDate: The date structure whose time will be returned in a string.
    ///   - IncludeSeconds: If true, the number of seconds will be included in the string.
    /// - Returns: String representation of the time.
    public static func MakeTimeString(TheDate: Date, IncludeSeconds: Bool = true) -> String
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: TheDate)
        var HourString = String(describing: Hour)
        if Hour < 10
        {
            HourString = "0" + HourString
        }
        let Minute = Cal.component(.minute, from: TheDate)
        var MinuteString = String(describing: Minute)
        if Minute < 10
        {
            MinuteString = "0" + MinuteString
        }
        let Second = Cal.component(.second, from: TheDate)
        var Result = HourString + ":" + MinuteString
        if IncludeSeconds
        {
            var SecondString = String(describing: Second)
            if Second < 10
            {
                SecondString = "0" + SecondString
            }
            Result = Result + ":" + SecondString
        }
        return Result
    }
    
    /// Return a dictionary of attributes to use to draw stroked text in AttributedString-related views/controls.
    ///
    /// - Parameters:
    ///   - Font: The font to use to draw the text.
    ///   - InteriorColor: The color of the text.
    ///   - StrokeColor: The color of the stroke.
    ///   - StrokeThickness: The thickness of the stroke.
    /// - Returns: Dictionary of attributes.
    public static func MakeOutlineTextAttributes(Font: NSFont, InteriorColor: NSColor, StrokeColor: NSColor, StrokeThickness: Int) -> [NSAttributedString.Key : Any]
    {
        return [
            NSAttributedString.Key.strokeColor: StrokeColor,
            NSAttributedString.Key.foregroundColor: InteriorColor,
            NSAttributedString.Key.strokeWidth: -StrokeThickness,
            NSAttributedString.Key.font: Font
        ]
    }
    
    /// Return a dictionary of attributes to use to draw non-stroked text in AttributedString-related views/controls. Explicitly
    /// sets stroke width to 0.
    ///
    /// - Parameters:
    ///   - Font: The font to use to draw the text.
    ///   - InteriorColor: The color of the text.
    /// - Returns: Dictionary of attributes.
    public static func MakeTextAttributes(Font: NSFont, InteriorColor: NSColor) -> [NSAttributedString.Key : Any]
    {
        return [
            NSAttributedString.Key.foregroundColor: InteriorColor,
            NSAttributedString.Key.font: Font,
            NSAttributedString.Key.strokeWidth: 0
        ]
    }
    
    /// List of full English month names.
    public static let EnglishMonths = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    /// List of full English weekday names.
    public static let EnglishWeekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    /// Return a random integer between 0 and Max - 1.
    ///
    /// - Parameter Max: The maximum integer to return.
    /// - Returns: Random integer in specified range.
    public static func RandomInt(Max: UInt32) -> Int
    {
        let R = arc4random_uniform(Max)
        return Int(R)
    }
    
    /// Return a random integer in the specified range.
    ///
    /// - Parameters:
    ///   - Low: Low end of the range, inclusive.
    ///   - High: High end of the range, inclusive.
    /// - Returns: Random value in the specified range.
    public static func RandomIntInRange(Low: UInt32, High: UInt32) -> Int
    {
        let Range = High - Low + 1
        let R = arc4random_uniform(Range) + Low
        return Int(R)
    }
    
    /// Wrapper around drand48 that ensures the seed has been set before the first call.
    ///
    /// - Returns: Random double from drand48().
    public static func drand48s() -> Double
    {
        if !RandomSeedSet
        {
            RandomSeedSet = true
            let TimeInt = UInt32(Date().timeIntervalSinceReferenceDate)
            srand48(Int(TimeInt))
        }
        return drand48()
    }
    
    /// Holds the random seed was set flag.
    private static var RandomSeedSet = false
    
    /// Return a random CGFloat between 0.0 and Max.
    ///
    /// - Parameter Max: The maximum CGFloat to return.
    /// - Returns: Random CGFloat in the specified range.
    public static func RandomCGFloat(Max: CGFloat) -> CGFloat
    {
        let RD = drand48s()
        let Final = CGFloat(RD) * Max
        return Final
    }
    
    /// Return a random double between 0.0 and Max.
    ///
    /// - Parameter Max: The maximum double to return.
    /// - Returns: Random Double in the specified range.
    public static func RandomDouble(Max: Double) -> Double
    {
        return drand48s() * Max
    }
    
    /// Return a random Double in the specified range.
    ///
    /// - Parameters:
    ///   - Low: Low end of the range, inclusive.
    ///   - High: High end of the range, inclusive.
    /// - Returns: Random value in the specified range.
    public static func RandomDoubleInRange(Low: Double, High: Double) -> Double
    {
        let Range = High - Low + 1
        let Final = (drand48s() * Range) + Low
        return Final
    }
    
    /// Return a random CGFloat in the specified range. Wrapper around RandomDoubleInRange.
    ///
    /// - Parameters:
    ///   - Low: Low end of the range, inclusive.
    ///   - High: High end of the range, inclusive.
    /// - Returns: Random value in the specified range.
    public static func RandomCGFloatInRange(Low: CGFloat, High: CGFloat) -> CGFloat
    {
        let RD = RandomDoubleInRange(Low: Double(Low), High: Double(High))
        return CGFloat(RD)
    }
    
    /// Return a random double between 0.0 and 1.0.
    ///
    /// - Returns: Normalized random Double number.
    public static func NormalRandom() -> Double
    {
        return drand48s()
    }
    
    /// Return a random CGFloat between 0.0 and 1.0.
    ///
    /// - Returns: Normalized random CGFloat number.
    public static func NormalCGFloat() -> CGFloat
    {
        return CGFloat(drand48s())
    }
    
    /// Returns a random color.
    ///
    /// - Returns: Random color.
    public static func RandomColor() -> NSColor
    {
        let RR = NormalCGFloat()
        let RG = NormalCGFloat()
        let RB = NormalCGFloat()
        let Final = NSColor(red: RR, green: RG, blue: RB, alpha: 1.0)
        return Final
    }
    
    /// Returns a random color as a CGColor.
    ///
    /// - Returns: Random color as CGColor.
    public static func RandomCGColor() -> CGColor
    {
        return RandomColor().cgColor
    }
    
    /// Returns a random color.
    ///
    /// - Parameter RandomAlpha: If true, alpha is randomized. If false, alpha is set to 1.0.
    /// - Returns: Random color.
    public static func RandomColor(RandomAlpha: Bool) -> NSColor
    {
        let RR = NormalCGFloat()
        let RG = NormalCGFloat()
        let RB = NormalCGFloat()
        let RA = RandomAlpha ? NormalCGFloat() : 1.0
        let Final = NSColor(red: RR, green: RG, blue: RB, alpha: RA)
        return Final
    }
    
    /// Returns a random color as a CGColor.
    ///
    /// - Parameter RandomAlpha: If true, alpha is randomized. If false, alpha is set to 1.0.
    /// - Returns: Random color as CGColor.
    public static func RandomCGColor(RandomAlpha: Bool) -> CGColor
    {
        return RandomColor(RandomAlpha: RandomAlpha).cgColor
    }
    
    /// Returns a random color.
    ///
    /// - Parameter Alpha: The alpha level of the random color.
    /// - Returns: Random color.
    public static func RandomColorWith(Alpha: CGFloat) -> NSColor
    {
        let RR = NormalCGFloat()
        let RG = NormalCGFloat()
        let RB = NormalCGFloat()
        let Final = NSColor(red: RR, green: RG, blue: RB, alpha: Alpha)
        return Final
    }
    
    /// Returns a random color as a CGColor.
    ///
    /// - Parameter Alpha: The alpha level of the random color.
    /// - Returns: Random color as CGColor.
    public static func RandomColorWith(Alpha: CGFloat) -> CGColor
    {
        return RandomColorWith(Alpha: Alpha).cgColor
    }
    
    /// Return the source color darkened by the supplied multiplier.
    ///
    /// - Parameters:
    ///   - Source: The source color to darken.
    ///   - PercentMultiplier: How to darken the source color.
    /// - Returns: Darkened source color.
    public static func DarkerColor(_ Source: NSColor, PercentMultiplier: CGFloat = 0.8) -> NSColor
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        var NewB = Brightness * PercentMultiplier
        if NewB < 0.0
        {
            NewB = 0.0
        }
        let Final = NSColor(hue: Hue, saturation: Saturation, brightness: NewB, alpha: Alpha)
        return Final
    }
    
    /// Return the source color brightened by the supplied multiplier.
    ///
    /// - Parameters:
    ///   - Source: The source color to brighten.
    ///   - PercentMultiplier: How to brighten the source color.
    /// - Returns: Brightened source color.
    public static func BrighterColor(_ Source: NSColor, PercentMultiplier: CGFloat = 1.2) -> NSColor
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        var NewB = Brightness * PercentMultiplier
        if NewB > 1.0
        {
            NewB = 1.0
        }
        let Final = NSColor(hue: Hue, saturation: Saturation, brightness: NewB, alpha: Alpha)
        return Final
    }
    
    /// Change the alpha value of the source color to the supplied alpha value.
    ///
    /// - Parameters:
    ///   - Source: Source color.
    ///   - NewAlpha: New alpha value for the color.
    /// - Returns: New color with the supplied alpha.
    public static func ChangeAlpha(_ Source: NSColor, NewAlpha: CGFloat) -> NSColor
    {
        return Source.withAlphaComponent(NewAlpha)
    }
    
    public static func Spaces(_ Count: Int) -> String
    {
        return String(repeating: " ", count: Count)
    }
    
    /// Convert the raw number of seconds in a duration into the number of days, hours, minutes, and seconds in the total number of seconds.
    ///
    /// - Parameters:
    ///   - RawSeconds: Seconds to convert.
    ///   - Days: Days in RawSeconds.
    ///   - Hours: Hours in RawSeconds.
    ///   - Minutes: Minutes in RawSeconds.
    ///   - Seconds: Seconds in RawSeconds.
    public static func MakeDurationUnits(RawSeconds: Int, Days: inout Int, Hours: inout Int, Minutes: inout Int, Seconds: inout Int)
    {
        let SecondsInDay = 24 * 60 * 60
        let SecondsInHour = 60 * 60
        let SecondsInMinute = 60
        
        var Working = RawSeconds < 0 ? 0 : RawSeconds
        Days = Working / SecondsInDay
        Working = Working % SecondsInDay
        Hours = Working / SecondsInHour
        Working = Working % SecondsInHour
        Minutes = Working / SecondsInMinute
        Seconds = Working % SecondsInMinute
    }
    
    /// Returns the number of seconds in the passed days, hours, minutes, and seconds.
    ///
    /// - Parameters:
    ///   - FromDays: Number of days.
    ///   - FromHours: Number of hours.
    ///   - FromMinutes: Number of minutes.
    ///   - FromSeconds: Number of seconds.
    /// - Returns: Total number of seconds in the passed durations.
    public static func CreateDuration(FromDays: Int, FromHours: Int, FromMinutes: Int, FromSeconds: Int) -> Int
    {
        let SecondsInDay = 24 * 60 * 60
        let SecondsInHour = 60 * 60
        let SecondsInMinute = 60
        
        let Duration = (FromDays * SecondsInDay) + (FromHours * SecondsInHour) + (FromMinutes * SecondsInMinute) + FromSeconds
        return Duration
    }
    
    /// Convert a raw number of seconds into a formatted string with days, hours, minutes and seconds. Leading units of 0 duration
    /// are not included. If 0 is passed in RawSeconds, a string indicating 0 seconds is always returned.
    ///
    /// - Parameters:
    ///   - RawSeconds: Number of seconds to convert. Negative values converted to 0.
    ///   - UseShortLabels: Determines if short or long time unit labels are used.
    /// - Returns: String indicating the duration in terms of days, hours, minutes, and seconds.
    public static func DurationFromSeconds(RawSeconds: Int, UseShortLabels: Bool = true) -> String
    {
        let SecondsInDay = 24 * 60 * 60
        let SecondsInHour = 60 * 60
        let SecondsInMinute = 60
        
        var Results: [Int] = [0, 0, 0, 0]
        let ShortMap: [String] =
            [
                "d",
                "h",
                "m",
                "s"
        ]
        let LongMap: [String] =
            [
                "Day",
                "Hour",
                "Minute",
                "Second"
        ]
        var Working = RawSeconds < 0 ? 0 : RawSeconds
        let Days = Working / SecondsInDay
        Working = Working % SecondsInDay
        let Hours = Working / SecondsInHour
        Working = Working % SecondsInHour
        let Minutes = Working / SecondsInMinute
        let Seconds = Working % SecondsInMinute
        Results[0] = Days
        Results[1] = Hours
        Results[2] = Minutes
        Results[3] = Seconds
        
        var FoundNonZero = false
        var Result = ""
        var Index = 0
        for Duration in Results
        {
            if FoundNonZero || Duration != 0
            {
                FoundNonZero = true
                let Plural = Duration == 1 ? "" : "s"
                if UseShortLabels
                {
                    let ShortLabel = String(ShortMap[Index])
                    let stemp = "\(Duration)\(ShortLabel) "
                    Result = Result + stemp
                }
                else
                {
                    let stemp = "\(Duration) \(LongMap[Index])\(Plural) "
                    Result = Result + stemp
                }
            }
            Index = Index + 1
        }
        if Result.isEmpty
        {
            if UseShortLabels
            {
                Result = "0s"
            }
            else
            {
                Result = "0 Seconds"
            }
        }
        
        return Result
    }
    
    private static let LoremIpsumParagraphs =
        [
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam elementum consectetur nisl. Curabitur tincidunt orci non metus ullamcorper finibus. Vivamus ornare volutpat congue. Duis enim nulla, congue sed elit non, dignissim malesuada nisl. Quisque sit amet turpis ligula. Maecenas quam risus, sollicitudin sit amet dictum eu, auctor in lacus. Quisque rhoncus at ante in suscipit. Suspendisse efficitur arcu fermentum, lacinia sem non, vulputate arcu.",
            "Praesent placerat pellentesque ex eu tincidunt. Suspendisse ornare turpis et sapien elementum, et aliquet sem condimentum. Quisque erat eros, consectetur in nulla sit amet, interdum mollis tellus. Fusce ac maximus mauris. Sed venenatis feugiat lectus, eget egestas arcu vulputate non. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur ultricies ipsum et fermentum blandit.",
            "Nulla in facilisis augue. Sed bibendum est eu varius pharetra. Integer pharetra in enim volutpat rhoncus. Praesent neque ipsum, luctus eget sagittis id, consequat vel orci. Morbi ac turpis scelerisque sem blandit dignissim. Donec vehicula sollicitudin neque at blandit. In eu ultrices odio.",
            "Praesent ultricies rhoncus mauris, ut varius dui efficitur et. Nunc cursus lacus quis lorem efficitur, nec iaculis erat faucibus. Phasellus ut arcu in diam rhoncus suscipit. Suspendisse vestibulum purus eget mi elementum bibendum. Mauris sem magna, ullamcorper in dui auctor, rhoncus vulputate metus. Pellentesque neque ante, scelerisque at tincidunt a, varius id eros. Vivamus eleifend fringilla diam, a bibendum metus facilisis ut. In vehicula elementum ante sed dignissim. Donec in lacus condimentum, convallis magna sit amet, porttitor neque. In laoreet nulla purus, a placerat ligula tincidunt at. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum vehicula auctor lorem at varius.",
            "Aliquam fermentum elit vitae justo vulputate feugiat. Mauris facilisis ultricies mauris nec congue. Nullam mollis lacus et iaculis mattis. Proin consectetur, ligula vel varius varius, lacus nisl venenatis enim, in mollis felis eros bibendum velit. Aenean vitae tempus dolor. Morbi non dui a leo accumsan venenatis dignissim id leo. Nunc tempor sagittis quam, in vulputate ante aliquam et. Nulla mattis sit amet tellus id pretium. Ut interdum lacus a consectetur vulputate.",
            "Pellentesque dictum ipsum sed dolor mattis, nec rutrum odio ultricies. Sed ut varius nunc. In nec ligula sodales, viverra augue vel, sagittis dui. Pellentesque bibendum vitae lectus ultricies viverra. Vestibulum volutpat aliquam lobortis. Sed egestas nisl quam, eu rhoncus magna hendrerit sed. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer bibendum ligula in pellentesque suscipit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc pharetra a ex non ornare. Donec sit amet ornare purus. Proin gravida imperdiet ante in porttitor. Nullam ut semper nunc. Ut ullamcorper consequat est nec convallis. In est libero, elementum at est eu, dignissim faucibus odio. Sed dictum, est vel lobortis faucibus, urna leo varius nisi, non imperdiet arcu metus sed nunc.",
            "Proin id sagittis metus. Nam auctor lobortis enim sed scelerisque. Curabitur blandit rutrum ultricies. Morbi laoreet dictum libero, scelerisque eleifend lacus. Nulla varius neque massa, cursus suscipit ligula dignissim id. Aliquam erat volutpat. Sed massa metus, consectetur id ante eu, condimentum dictum quam. Integer posuere erat nulla, nec molestie sem euismod vitae. Donec sit amet dui vel mauris rutrum egestas at eu sem. Nullam id arcu luctus, hendrerit lorem et, posuere nisi. In hac habitasse platea dictumst. Fusce non est sed felis mollis vehicula.",
            "Sed mattis laoreet molestie. Sed consequat in erat nec venenatis. Phasellus ac dui sed erat varius vehicula. Morbi tempus massa nibh, eu scelerisque enim consequat in. Donec lobortis tincidunt sapien nec sodales. Aliquam sit amet dapibus orci. Phasellus venenatis diam tincidunt, mollis velit vitae, gravida lorem. Curabitur efficitur, massa quis rhoncus efficitur, tortor justo dapibus nisi, quis fringilla felis felis id leo. Duis lectus ante, rutrum id felis aliquet, imperdiet volutpat turpis. Quisque lectus leo, elementum vel facilisis id, elementum ac enim. Cras nec lacus a ipsum rutrum blandit. Aliquam aliquam erat id arcu semper, ac viverra dui ultricies. Donec ornare malesuada felis in tincidunt. Duis faucibus porta sem eu hendrerit.",
            "Phasellus sed diam sagittis, efficitur orci nec, fringilla mi. Maecenas id hendrerit dolor. Praesent tincidunt nisl ac augue sollicitudin, in dictum risus ullamcorper. Aliquam luctus libero a ligula scelerisque venenatis. Donec consequat metus tortor, venenatis tristique dolor viverra et. In dignissim diam non elit ultricies, nec consequat sapien maximus. Sed gravida pellentesque tellus id bibendum. Vestibulum rhoncus enim a arcu volutpat lobortis. Aliquam lobortis massa malesuada nibh faucibus, id mollis nunc volutpat. Suspendisse tincidunt, justo ut finibus convallis, lacus metus pretium odio, sed dignissim leo lectus aliquet libero. Suspendisse tincidunt orci et consequat euismod. Vivamus feugiat nunc ut lorem pharetra, vel porttitor sem malesuada. Pellentesque scelerisque porttitor maximus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sed metus scelerisque, mattis magna porta, eleifend est.",
            "Nam sed eleifend nunc, at interdum lacus. Praesent pulvinar mauris non urna gravida, eget rhoncus arcu sagittis. Vivamus vitae ante diam. Vestibulum maximus mauris auctor magna molestie blandit. Vivamus eget molestie metus. Aenean nec nunc sit amet leo varius iaculis. Morbi eget nunc condimentum, posuere ipsum vel, porta nibh. Vestibulum orci lectus, laoreet ac quam ac, ornare fringilla orci. Duis dictum tellus mattis nisi imperdiet ultricies. Pellentesque nibh risus, rhoncus a purus vitae, tristique fringilla dolor. Ut ornare lectus consectetur egestas laoreet. Vivamus sodales libero dui, non ornare orci pulvinar fringilla. Sed a sollicitudin massa. Ut at dui congue, mollis velit eu, venenatis leo. Integer sodales eget dui sed bibendum.",
    ]
    
    public static func LoremIpsum(_ Paragraphs: Int) -> String
    {
        var Result: String = ""
        var Count = Paragraphs
        if Count < 1
        {
            Count = 1
        }
        if Count > 10
        {
            Count = 10
        }
        for Index in 0 ..< Count
        {
            Result = Result + LoremIpsumParagraphs[Index]
        }
        return Result
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into a `UIColor`. Color order is: rrggbbaa or rrggbb.
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Tuple of color channel information.
    public static func ColorChannelsFrom(_ RawString: String) -> (Red: CGFloat, Green: CGFloat, Blue: CGFloat, Alpha: CGFloat)?
    {
        var Working = RawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if Working.isEmpty
        {
            return nil
        }
        if Working.uppercased().starts(with: "0X")
        {
            Working = Working.replacingOccurrences(of: "0x", with: "")
            Working = Working.replacingOccurrences(of: "0X", with: "")
        }
        if Working.starts(with: "#")
        {
            Working = Working.replacingOccurrences(of: "#", with: "")
        }
        switch Working.count
        {
            case 8:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff000000) >> 24) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff0000) >> 16) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff00) >> 8) / 255.0
                    let Alpha: CGFloat = CGFloat((Value & 0x000000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: Alpha)
            }
            
            case 6:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff0000) >> 16) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff00) >> 8) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: 1.0)
            }
            
            default:
                break
        }
        return nil
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into a `UIColor`. Color order is: rrggbbaa or rrggbb.
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Color represented by the raw string on success, nil on parse failure.
    public static func ColorFrom(_ RawString: String) -> NSColor?
    {
        if let (Red, Green, Blue, Alpha) = ColorChannelsFrom(RawString)
        {
            return NSColor(red: Red, green: Green, blue: Blue, alpha: Alpha)
        }
        return nil
    }
    
    /// Resizes an NSImage such that the longest dimension of the returned image is `Longest`. If the
    /// image is smaller than `Longest`, it is *not* resized.
    /// - Parameter Image: The image to resize.
    /// - Parameter Longest: The new longest dimension.
    /// - Returns: Resized image. If the longest dimension of the original image is less than `Longest`, the
    ///            original image is returned unchanged.
    public static func ResizeImage(Image: NSImage, Longest: CGFloat) -> NSImage
    {
        let ImageMax = max(Image.size.width, Image.size.height)
        if ImageMax <= Longest
        {
            return Image
        }
        let Ratio = Longest / ImageMax
        let NewSize = NSSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        let NewImage = NSImage(size: NewSize)
        NewImage.lockFocus()
        Image.draw(in: NSMakeRect(0, 0, NewSize.width, NewSize.height),
                   from: NSMakeRect(0, 0, Image.size.width, Image.size.height),
                   operation: NSCompositingOperation.sourceOver,
                   fraction: CGFloat(1))
        NewImage.unlockFocus()
        NewImage.size = NewSize
        return NewImage
    }
    
    /// Given the passed placemark, create an address string.
    /// - Note: The Apple API that creates the address is throttled to one address a minute (although when
    ///         there is low demand, it is entirely possible to get one a second).
    /// - Parameter From: The placemark from the system.
    /// - Returns: Address constructed from the placemark.
    public static func ConstructAddress(From: CLPlacemark) -> String
    {
        var Address = ""
        if let Name = From.name
        {
            Address.append(Name + "\n")
        }
        if let Country = From.country
        {
            Address.append(Country + " ")
        }
        if let PostCode = From.postalCode
        {
            Address.append(PostCode + " ")
        }
        if let Administrative = From.administrativeArea
        {
            Address.append(Administrative + " ")
        }
        if !Address.isEmpty
        {
            Address.append("\n")
        }
        var AddedLine2 = false
        if let SubAdministrative = From.subAdministrativeArea
        {
            AddedLine2 = true
            Address.append(SubAdministrative + " ")
        }
        if let Locality = From.locality
        {
            AddedLine2 = true
            Address.append(Locality + " ")
        }
        if let SubLocality = From.subLocality
        {
            AddedLine2 = true
            Address.append(SubLocality + " ")
        }
        if AddedLine2
        {
            Address.append("\n")
        }
        if let Thoroughfare = From.thoroughfare
        {
            Address.append(Thoroughfare + " ")
        }
        if let SubThoroughfare = From.subThoroughfare
        {
            Address.append(SubThoroughfare + " ")
        }
        if let TimeZone = From.timeZone
        {
            Address.append(TimeZone.abbreviation()!)
        }
        return Address
    }
    
    /// Create an "opposite" color from the passed color. The general idea is the returned color
    /// will be contrasting enough to show up against the source color.
    /// - Parameter From: The source color used to create an "opposite" color.
    /// - Returns: Color that hopefully constrasts with the passed color.
    public static func OppositeColor(From: NSColor) -> NSColor
    {
        let (H, S, B) = From.HSB
        if B > 0.8
        {
            return NSColor.black
        }
        if B < 0.2
        {
            return NSColor.white
        }
        if S < 0.2
        {
            return NSColor(calibratedHue: H, saturation: 1.0, brightness: 1.0 - B, alpha: 1.0)
        }
        let Final = NSColor(calibratedHue: 1.0 - H, saturation: S, brightness: 1.0 - B, alpha: 1.0)
        return Final
    }
    
    // MARK: - 3D utilities.
    
    /// Calculated the distance between two three dimensional points.
    /// - Parameter X1: First X coordinate.
    /// - Parameter Y1: First Y coordinate.
    /// - Parameter Z1: First Z coordinate.
    /// - Parameter X2: Second X coordinate.
    /// - Parameter Y2: Second Y coordinate.
    /// - Parameter Z2: Second Z coordinate.
    /// - Returns: Distance (unitless) between the two points.
    public static func Distance3D(X1: Double, Y1: Double, Z1: Double,
                                  X2: Double, Y2: Double, Z2: Double) -> Double
    {
        let XSq = (X2 - X1) * (X2 - X1)
        let YSq = (Y2 - Y1) * (Y2 - Y1)
        let ZSq = (Z2 - Z1) * (Z2 - Z1)
        return sqrt(XSq + YSq + ZSq)
    }
    
    /// Returns a transparent spherical node with a 3D-extruded sentence on it. Intended to be used
    /// for the about view.
    /// - Parameter Radius: Radius of the sphere with the sentence.
    /// - Parameter Words: Words of the sentence to display.
    /// - Returns: Node that can be used in the about view.
    public static func MakeAboutSentence(Radius: Double, Words: [String]) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = "Hour Node"
        
        let StartAngle = -100
        var Angle = StartAngle
        for Word in Words
        {
            var WorkingAngle: CGFloat = CGFloat(Angle)
            var PreviousEnding: CGFloat = 0.0
            for (_, Letter) in Word.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: 5.0)
                var LetterColor = NSColor.systemYellow
                var SpecularColor = NSColor.white
                var VerticalOffset: CGFloat = 0.8
                
                if Word == Versioning.ApplicationName
                {
                    HourText.font = NSFont(name: "Avenir-Black", size: 28.0)
                    LetterColor = NSColor.systemRed
                    SpecularColor = NSColor.systemOrange
                }
                else
                {
                    HourText.font = NSFont(name: "Avenir-Heavy", size: 24.0)
                    VerticalOffset = 0.6
                }
                
                var CharWidth: Float = 0
                if Letter == " "
                {
                    CharWidth = 3.5
                }
                else
                {
                    CharWidth = Float(abs(HourText.boundingBox.max.x - HourText.boundingBox.min.x))
                }
                PreviousEnding = CGFloat(CharWidth)
                if Letter == "V"
                {
                    PreviousEnding = CGFloat(12.0)
                }
                if Letter == "l"
                {
                    PreviousEnding = CGFloat(6.0)
                }
                if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Letter)
                {
                    PreviousEnding = CGFloat(10.0)
                }
                WorkingAngle = WorkingAngle - (PreviousEnding * 0.5)
                HourText.firstMaterial?.diffuse.contents = LetterColor
                HourText.firstMaterial?.specular.contents = SpecularColor
                HourText.flatness = 0.1
                let X = CGFloat(Radius) * cos(Radians)
                let Z = CGFloat(Radius) * sin(Radians)
                let HourTextNode = SCNNode(geometry: HourText)
                HourTextNode.scale = SCNVector3(0.07, 0.07, 0.07)
                HourTextNode.position = SCNVector3(X, -VerticalOffset, Z)
                let HourRotation = (90.0 - Double(WorkingAngle) + 00.0).Radians
                HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
                Node.addChildNode(HourTextNode)
            }
            Angle = Angle + 65
        }
        
        return Node
    }
    
    /// Create an `SCNNode` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - TODO: Have the text follow the curve of the globe.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter TextColor: The color of the word.
    /// - Returns: `SCNNode` with the word as a 3D object.
    public static func MakeFloatingWord(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                        Latitude: Double, Longitude: Double,
                                        Extrusion: CGFloat = 1.0,
                                        TextColor: NSColor = NSColor.gray) -> SCNNode
    {
        let WordNode = SCNNode()
        WordNode.position = SCNVector3(0.0, 0.0, 0.0)
        let WordFont = NSFont.systemFont(ofSize: 24.0)
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = 0.0
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = NSColor.white
            let LetterNode = SCNNode(geometry: LetterShape)
            LetterNode.position = SCNVector3(CumulativeLetterLocation, 0.0, 0.0)
            LetterNode.name = "LetterNode"
            CumulativeLetterLocation = CumulativeLetterLocation + LetterSize.width
            WordNode.addChildNode(LetterNode)
        }
        WordNode.scale = SCNVector3(Scale, Scale, Scale)
        return WordNode
    }
    
    /// Create an `SCNNode` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - TODO: Have the text follow the curve of the globe.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter Mask: The light mask. Defaults to `0`.
    /// - Parameter TextFont: The font to use to draw the text. Defaults to `nil`. If not specified
    ///                       of if `nil` is passed, the current system font (of size `24.0`) is
    ///                       used.
    /// - Parameter TextColor: The color of the word.
    /// - Parameter OnSurface: Where the word will be plotted.
    /// - Parameter WithTag: Tag value to assign to the word. If nil, "WordLetterNode" is used.
    /// - Returns: Array with letter nodes.
    public static func MakeFloatingWord(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                        Latitude: Double, Longitude: Double,
                                        Extrusion: CGFloat = 1.0, Mask: Int = 0,
                                        TextFont: NSFont? = nil,
                                        TextColor: NSColor = NSColor.gray,
                                        OnSurface: SCNNode, WithTag: String? = nil) -> [SCNNode]
    {
        var WordFont: NSFont = NSFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
         WordFont = NSFont.systemFont(ofSize: 24.0)
        }
        var LetterNodes = [SCNNode]()
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude)
        let EqCircumference = 2.0 * Radius * Double.pi
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = NSColor.white
            let LetterNode = SCNNode(geometry: LetterShape)
            LetterNode.categoryBitMask = Mask
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
            LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = ToECEF(Latitude, Double(CumulativeLetterLocation),
                                   LatitudeOffset: -1.0, LongitudeOffset: -0.5,
                                   Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let YRotation = -Latitude
            let XRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
            OnSurface.addChildNode(LetterNode)
            #if true
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * 10.0
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
            #else
            //http://mathforum.org/library/drmath/view/54158.html
            let Circumference = cos(EqCircumference.Radians)
            var AngleAdjustment = Double(LetterSize.width) / Circumference
            AngleAdjustment = AngleAdjustment * 10.0
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
            #endif
            LetterNodes.append(LetterNode)
        }
        return LetterNodes
    }
    
    /// Create an `SCNNode` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - TODO: Have the text follow the curve of the globe.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter Mask: The light mask. Defaults to `0`.
    /// - Parameter TextFont: The font to use to draw the text. Defaults to `nil`. If not specified
    ///                       of if `nil` is passed, the current system font (of size `24.0`) is
    ///                       used.
    /// - Parameter TextColor: The color of the word.
    /// - Parameter WithTag: Tag value to assign to the word. If nil, "WordLetterNode" is used.
    public static func MakeFloatingWord(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                        Latitude: Double, Longitude: Double,
                                        Extrusion: CGFloat = 1.0, Mask: Int = 0,
                                        TextFont: NSFont? = nil,
                                        TextColor: NSColor = NSColor.gray,
                                        WithTag: String? = nil) -> SCNNode
    {
        var WordFont: NSFont = NSFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = NSFont.systemFont(ofSize: 24.0)
        }
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude)
        let EqCircumference = 2.0 * Radius * Double.pi
        let FinalNode = SCNNode()
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = NSColor.white
            let LetterNode = SCNNode(geometry: LetterShape)
            LetterNode.categoryBitMask = Mask
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = ToECEF(Latitude, Double(CumulativeLetterLocation),
                                   LatitudeOffset: -1.0, LongitudeOffset: -0.5,
                                   Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let YRotation = -Latitude
            let XRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
            FinalNode.addChildNode(LetterNode)
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * 10.0
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
        }
        return FinalNode
    }
    
    /// Given an array of words, place a set of words in the hour ring over the Earth.
    /// - TODO: Split into multiple functions rather than change the behavior via parameters.
    /// - Note: Pay attention to the word order - it must be reversed in `Words` in order for
    ///         words to appear correctly as people would expect.
    /// - Parameter Radius: The radius of the word.
    /// - Parameter Words: Array of words (if order is significant, the first word in the order
    ///                    must be the last entry in the array) to display as expected.
    /// - Parameter Scale: The scale to apply to the text node. Defaults to `0.07`.
    /// - Parameter Extrusion: The extrusion depth of the text. Defaults to `5.0`.
    /// - Parameter IsAboutText: If true, the text is drawn in the context of the About Flatland
    ///                          display. Otherwise, it is drawn without regards to that context.
    /// - Parameter TextColor: The color of the text to use if `IsAboutText` is false.
    /// - Returns: Node for words to display above a spherical Earth.
    public static func MakeSentence(Radius: Double, Words: [String], Scale: CGFloat = 0.07,
                                    Extrusion: CGFloat = 5.0, IsAboutText: Bool = true,
                                    TextColor: NSColor = NSColor.gray,
                                    StartingAngle: Int = -100) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = "Hour Node"
        
        let StartAngle = StartingAngle
        var Angle = StartAngle
        for Word in Words
        {
            var WorkingAngle: CGFloat = CGFloat(Angle)
            var PreviousEnding: CGFloat = 0.0
            for (_, Letter) in Word.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: 5.0)
                var LetterColor = NSColor.systemYellow
                var SpecularColor = NSColor.white
                var VerticalOffset: CGFloat = 0.8
                if IsAboutText
                {
                    if Word == Versioning.ApplicationName
                    {
                        HourText.font = NSFont(name: "Avenir-Black", size: 28.0)
                        LetterColor = NSColor.systemRed
                        SpecularColor = NSColor.systemOrange
                    }
                    else
                    {
                        HourText.font = NSFont(name: "Avenir-Heavy", size: 24.0)
                        VerticalOffset = 0.6
                    }
                }
                else
                {
                    HourText.font = NSFont.systemFont(ofSize: 24.0)
                    VerticalOffset = 0.6
                    LetterColor = TextColor
                    SpecularColor = NSColor.white
                }
                var CharWidth: Float = 0
                if Letter == " "
                {
                    CharWidth = 3.5
                }
                else
                {
                    CharWidth = Float(abs(HourText.boundingBox.max.x - HourText.boundingBox.min.x))
                }
                PreviousEnding = CGFloat(CharWidth)
                if Letter == "V"
                {
                    PreviousEnding = CGFloat(12.0)
                }
                if Letter == "l"
                {
                    PreviousEnding = CGFloat(6.0)
                }
                if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Letter)
                {
                    PreviousEnding = CGFloat(10.0)
                }
                WorkingAngle = WorkingAngle - (PreviousEnding * 0.5)
                HourText.firstMaterial?.diffuse.contents = LetterColor
                HourText.firstMaterial?.specular.contents = SpecularColor
                HourText.flatness = 0.1
                let X = CGFloat(Radius) * cos(Radians)
                let Z = CGFloat(Radius) * sin(Radians)
                let HourTextNode = SCNNode(geometry: HourText)
                HourTextNode.scale = SCNVector3(Scale, Scale, Scale)
                HourTextNode.position = SCNVector3(X, -VerticalOffset, Z)
                if IsAboutText
                {
                    let HourRotation = (90.0 - Double(WorkingAngle) + 00.0).Radians
                    HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
                }
                Node.addChildNode(HourTextNode)
            }
            if IsAboutText
            {
                Angle = Angle + 65
            }
        }
        
        return Node
    }
    
    /// Convert the passed latitude and longitude values into a 3D coordinate that can be plotted
    /// on a sphere.
    /// - Note: See [How to map latitude and logitude to a 3D sphere](https://stackoverflow.com/questions/36369734/how-to-map-latitude-and-longitude-to-a-3d-sphere)
    /// - Parameter Latitude: The latitude portion of the 2D coordinate.
    /// - Parameter Longitude: The longitude portion of the 2D coordinate.
    /// - Parameter LatitudeOffset: Offset added to the latitude. Defaults to `0.0`.
    /// - Parameter LongitudeOffset: Offset added to the longitude. Defaults to `0.0`.
    /// - Parameter Radius: The radius of the sphere.
    /// - Parameter RadiusOffset: Offset added to the radius. Defaults to `0.0`.
    /// - Returns: Tuple with the X, Y, and Z coordinates for the location on the sphere.
    public static func ToECEF(_ Latitude: Double, _ Longitude: Double,
                              LatitudeOffset: Double = 0.0, LongitudeOffset: Double = 0.0,
                              Radius: Double, RadiusOffset: Double = 0.0) -> (Double, Double, Double)
    {
        let Lat = (90 - (Latitude + LatitudeOffset)).Radians
        let Lon = (90 + (Longitude + LongitudeOffset)).Radians
        let X = -((Radius + RadiusOffset) * sin(Lat) * cos(Lon))
        let Z = ((Radius + RadiusOffset) * sin(Lat) * sin(Lon))
        let Y = ((Radius + RadiusOffset) * cos(Lat))
        return (X, Y, Z)
    }
}
