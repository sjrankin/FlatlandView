//
//  Extensions.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

// MARK: - Double extensions.

extension Double
{
    /// Returns a rounded value of the instance double.
    /// - Note: This "rounding" is nothing more than truncation.
    /// - Parameter Count: Number of places to round to.
    /// - Returns: Rounded value.
    func RoundedTo(_ Count: Int) -> Double
    {
        let Multiplier = pow(10.0, Count)
        let Value = Int(self * Double(truncating: Multiplier as NSNumber))
        return Double(Value) / Double(truncating: Multiplier as NSNumber)
    }
    
    /// Converts the instance value from (an assumed) degrees to radians.
    /// - Returns: Value converted to radians.
    func ToRadians() -> Double
    {
        return self * Double.pi / 180.0
    }
    
    /// Converts the instance value from (an assumed) radians to degrees.
    /// - Returns: Value converted to degrees.
    func ToDegrees() -> Double
    {
        return self * 180.0 / Double.pi
    }
    
    /// Converts the instance value from assumed degrees to radians.
    /// - Returns: Value converted to radians.
    var Radians: Double
    {
        get
        {
            return ToRadians()
        }
    }
    
    /// Converts the instance value from assumed radians to degrees.
    /// - Returns: Value converted to degrees.
    var Degrees: Double
    {
        get
        {
            return ToDegrees()
        }
    }
}

// MARK: - CGFloat extensions.

extension CGFloat
{
    /// Returns a rounded value of the instance CGFloat.
    /// - Note:
    ///     - This "rounding" is nothing more than truncation.
    /// - Parameter Count: Number of places to round to.
    /// - Returns: Rounded value.
    func RoundedTo(_ Count: Int) -> CGFloat
    {
        let Multiplier = pow(10.0, Count)
        let Value = Int(self * CGFloat(Double(truncating: Multiplier as NSNumber)))
        return CGFloat(Value) / CGFloat(Double(truncating: Multiplier as NSNumber))
    }
    
    /// Converts the instance value from (an assumed) degrees to radians.
    /// - Returns: Value converted to radians.
    func ToRadians() -> CGFloat
    {
        return self * CGFloat.pi / 180.0
    }
    
    /// Converts the instance value from (an assumed) radians to degrees.
    /// - Returns: Value converted to degrees.
    func ToDegrees() -> CGFloat
    {
        return self * 180.0 / CGFloat.pi
    }
    
    /// Converts the instance value from assumed degrees to radians.
    /// - Returns: Value converted to radians.
    var Radians: CGFloat
    {
        get
        {
            return ToRadians()
        }
    }
    
    /// Converts the instance value from assumed radians to degrees.
    /// - Returns: Value converted to degrees.
    var Degrees: CGFloat
    {
        get
        {
            return ToDegrees()
        }
    }
}

// MARK: - Date extensions.

/// Date extensions.
/// - Note: See [Converting UTC date formal to local](https://stackoverflow.com/questions/29392874/converting-utc-date-format-to-local-nsdate)
extension Date
{
    /// Create a date with the given components.
    /// - Year: The year of the date.
    /// - Month: The month of the date.
    /// - Day: The day of the date.
    /// - Hour: The hour of the day.
    /// - Minute: The minute of the day.
    /// - Second: The second of the day.
    /// - TimeZoneLabel: Valid time zone identifier. If not specified, the current calendar's time
    ///                  zone is used.
    public static func DateFactory(Year: Int, Month: Int, Day: Int, Hour: Int, Minute: Int, Second: Int,
                                   TimeZoneLabel: String? = "UTC") -> Date?
    {
        if Month < 1 || Month > 12
        {
            return nil
        }
        if Day < 1
        {
            return nil
        }
        if Month == 2
        {
            if IsLeapYear(Year)
            {
                if Day > 29
                {
                    return nil
                }
            }
            else
            {
                if Day > 28
                {
                    return nil
                }
            }
        }
        if [1, 3, 5, 7, 8, 10, 12].contains(Month)
        {
            if Day > 31
            {
                return nil
            }
        }
        if Hour < 0 || Hour > 23
        {
            return nil
        }
        if Minute < 0 || Minute > 59
        {
            return nil
        }
        if Second < 0 || Second > 59
        {
            return nil
        }
        var Cal: Calendar!
        if let ZoneLabel = TimeZoneLabel
        {
            Cal = Calendar(identifier: .gregorian)
            if let TZ = TimeZone(identifier: ZoneLabel)
            {
                Cal.timeZone = TZ
            }
            else
            {
                return nil
            }
        }
        else
        {
            Cal = Calendar.current
        }
        var Components = DateComponents()
        Components.year = Year
        Components.month = Month
        Components.day = Day
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Second
        return Cal.date(from: Components)
    }
    
    /// Create a date with the given components. The time is set to 00:00:00.
    /// - Year: The year of the date.
    /// - Month: The month of the date.
    /// - Day: The day of the date.
    public static func DateFactory(Year: Int, Month: Int, Day: Int) -> Date?
    {
        return Date.DateFactory(Year: Year, Month: Month, Day: Day, Hour: 0, Minute: 0, Second: 0)
    }
    
    /// Determines if a given year is a leap year.
    /// - Parameter Year: The year to determine for leap yearness.
    /// - Returns: True if the passed year is a leap year, false if not.
    public static func IsLeapYear(_ Year: Int) -> Bool
    {
        if Year % 400 == 0
        {
            return true
        }
        if Year % 100 == 0
        {
            return false
        }
        if Year % 4 == 0
        {
            return true
        }
        return false
    }
    
    /// Convert a local date to UTC.
    /// - Returns: UTC date equivalent of the instance local date.
    func ToUTC() -> Date
    {
        let TZ = TimeZone.current
        let Seconds = -TimeInterval(TZ.secondsFromGMT(for: self))
        return Date(timeInterval: Seconds, since: self)
    }
    
    /// Convert a UTC date to a local date.
    /// - Returns: Local date equivalent of the instance UTC date.
    func ToLocal() -> Date
    {
        let TZ = TimeZone.current
        let Seconds = TimeInterval(TZ.secondsFromGMT(for: self))
        return Date(timeInterval: Seconds, since: self)
    }
    
    /// Given a number of seconds, return the number of hours, minutes, and remaining seconds in
    /// the total count of seconds.
    /// - Parameter SourceSeconds: Total number of seconds.
    /// - Returns: Tuple with the number of hours, minutes, and seconds.
    static func SecondsToTime(_ SourceSeconds: Int) -> (Hour: Int, Minute: Int, Second: Int)
    {
        let Hours = SourceSeconds / (60 * 60)
        let Minutes = (SourceSeconds - (Hours * 60 * 60)) / 60
        let Seconds = SourceSeconds - ((Hours * 60 * 60) + (Minutes * 60))
        return (Hours, Minutes, Seconds)
    }
    
    static func PrettyTimeParts(From TotalSeconds: Int, Separator: String = ", ") -> String
    {
        if TotalSeconds <= 0
        {
            return "0s"
        }
        let (Hour, Minute, Second) = SecondsToTime(TotalSeconds)
        var Parts = [String]()
        if Hour > 0
        {
            Parts.append("\(Hour)h")
        }
        if Minute > 0
        {
            Parts.append("\(Minute)m")
        }
        if Second > 0
        {
            Parts.append("\(Second)s")
        }
        var Result = ""
        for Index in 0 ..< Parts.count
        {
            Result.append(Parts[Index])
            if Index < Parts.count - 1
            {
                Result.append(Separator)
            }
        }
        return Result
    }
    
    /// Return a date (only the time components are valid) based on the percent of a day that
    /// has passed.
    /// - Parameter Percent: Percent of a day that has passed. Used to calculate the time.
    /// - Parameter WithOffset: Offset value.
    /// - Returns: Date structure with only the time components being valid.
    static func DateFrom(Percent: Double, WithOffset: Int = 0) -> Date
    {
        var Components = DateComponents()
        let Current = Int(abs((24 * 60 * 60) * Percent) - 1)
        let Hours = Current / (60 * 60)
        let Minutes = (Current - (Hours * 60 * 60)) / 60
        let Seconds = Current - ((Hours * 60 * 60) + (Minutes * 60))
        Components.hour = Hours
        Components.minute = Minutes
        Components.second = Seconds
        Components.year = 2020
        Components.month = 4
        Components.day = 12
        let Cal = Calendar(identifier: .gregorian)
        let D = Cal.date(from: Components)
        return D!
    }
    
    /// Converts the passed date's time components into a pretty string.
    /// - Parameter From: The date whose time components will be used to generate a pretty string.
    /// - Returns: String value of the time components of `From`.
    static func PrettyTime(From: Date) -> String
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: From)
        let Minute = Cal.component(.minute, from: From)
        let Second = Cal.component(.second, from: From)
        var HourS = "\(Hour)"
        if Hour < 10
        {
            HourS = " " + HourS
        }
        var MinuteS = "\(Minute)"
        if Minute < 10
        {
            MinuteS = "0" + MinuteS
        }
        var SecondS = "\(Second)"
        if Second < 10
        {
            SecondS = "0" + SecondS
        }
        return "\(HourS):\(MinuteS):\(SecondS)"
    }
    
    /// Converts the passed date's date components into a pretty string.
    /// - Parameter From: The date whose date components will be used to generate a pretty string.
    /// - Returns: String value of the date components of `From`.
    static func PrettyDate(From: Date) -> String
    {
        let Cal = Calendar.current
        let Day = Cal.component(.day, from: From)
        let Month = Cal.component(.month, from: From)
        let Year = Cal.component(.year, from: From)
        let MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month - 1]
        return "\(Day) \(MonthName) \(Year)"
    }
    
    /// Converts the passed date's date and time components into a pretty string.
    /// - Parameter From: The date whose date and time components will be used to generate a pretty string.
    /// - Returns: String value of the date and time components of `From`.
    static func PrettyDateTime(From: Date) -> String
    {
        let NiceTime = From.PrettyTime()
        let NiceDate = From.PrettyDate()
        return "\(NiceDate), \(NiceTime)"
    }
    
    /// Converts the instance date's time components into a pretty string.
    /// - Returns: String value of the time components of the instance date.
    func PrettyTime() -> String
    {
        return Date.PrettyTime(From: self)
    }
    
    /// Converts the instance date's date components into a pretty string.
    /// - Returns: String value of the date components of the instance date.
    func PrettyDate() -> String
    {
        return Date.PrettyDate(From: self)
    }
    
    /// Converts the instance date's time and date components into a pretty string.
    /// - Returns: String value of the time and date components of the instance date.
    func PrettyDateTime() -> String
    {
        return Date.PrettyDateTime(From: self)
    }
    
    /// Returns the time zone of the instance date.
    /// - Returns: Time zone for the the instance date. May be nil if not known or set.
    func GetTimeZone() -> TimeZone?
    {
        let Cal = Calendar(identifier: .gregorian)
        let Components = Cal.dateComponents([.timeZone], from: self)
        let TZ = Components.timeZone
        return TZ
    }
    
    /// Returns the number of seconds represented by the time component (*not* the date component)
    /// of the instance date.
    /// - Returns: Number of seconds represented by the time components of the instance value.
    func AsSeconds() -> Int
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: self)
        let Minute = Cal.component(.minute, from: self)
        let Second = Cal.component(.second, from: self)
        return Second + (Minute * 60) + (Hour * 60 * 60)
    }
    
    /// The year component value for the instance value.
    public var Year: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.year, from: self)
        }
    }
    
    /// The month component value for the instance value.
    public var Month: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.month, from: self)
        }
    }
    
    /// The day component value for the instance value.
    public var Day: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.day, from: self)
        }
    }
    
    /// The hour component value for the instance value.
    public var Hour: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.hour, from: self)
        }
    }
    
    /// The minute component value for the instance value.
    public var Minute: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.minute, from: self)
        }
    }
    
    /// The second component value for the instance value.
    public var Second: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.second, from: self)
        }
    }
    
    /// Given a number of seconds, return the number of years, days, hours, minutes, and remaining
    /// seconds the value represents.
    /// - Parameter SecondCount: The number of seconds to convert to the returned units.
    /// - Returns: Tuple of years, days, hours, minutes, and seconds `SecondCount` represents.
    public static func UnitDuration(_ SecondCount: Int) -> (Years: Int, Days: Int, Hours: Int, Minutes: Int, Seconds: Int)
    {
        var Working = SecondCount
        let YearCount = Working / SecondsIn(.Year)
        if YearCount > 0
        {
            Working = Working - (YearCount * SecondsIn(.Year))
        }
        let DayCount = Working / SecondsIn(.Day)
        if DayCount > 0
        {
            Working = Working - (DayCount * SecondsIn(.Day))
        }
        let HourCount = Working / SecondsIn(.Hour)
        if HourCount > 0
        {
            Working = Working - (HourCount * SecondsIn(.Hour))
        }
        let MinuteCount = Working / SecondsIn(.Minute)
        if MinuteCount > 0
        {
            Working = Working - (MinuteCount * SecondsIn(.Minute))
        }
        if Working > 59
        {
            fatalError("Too many seconds left over! (\(Working)")
        }
        return (YearCount, DayCount, HourCount, MinuteCount, Working)
    }
    
    /// Returns the number of seconds in the specified time unit.
    /// - Parameter Unit: The time unit whose number of seconds is returned.
    /// - Returns: Number of seconds in the specified time unit.
    public static func SecondsIn(_ Unit: TimeUnits) -> Int
    {
        switch Unit
        {
            case .Minute:
                return 60
            
            case .Hour:
                return 60 * 60
            
            case .Day:
                return 24 * 60 * 60
            
            case .Year:
                return 365 * 24 * 60 * 60
        }
    }
}

// MARK: - NSImage extensions.

/// Extension methods for UIImage.
extension NSImage
{
    /// Initializer that creates a solid color image of the passed size.
    /// - Note: Do *not* use the draw swatch function as it incorrectly draws transparent colors.
    /// - Parameter Color: The color to use to create the image.
    /// - Parameter Size: The size of the image.
    convenience init(Color: NSColor, Size: NSSize)
    {
        self.init(size: Size)
        lockFocus()
        let FinalColor = Color.usingColorSpace(.sRGB)!
        FinalColor.setFill()
        unlockFocus()
    }
    
    #if false
    /// Rotate the instance image to the number of passed radians.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Radians: Number of radians to rotate the image to.
    /// - Returns: Rotated image.
    func Rotate(Radians: CGFloat) -> NSImage
    {
        var NewSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: Radians)).size
        NewSize.width = floor(NewSize.width)
        NewSize.height = floor(NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, self.scale)
        let Context = UIGraphicsGetCurrentContext()
        Context?.translateBy(x: NewSize.width / 2, y: NewSize.height / 2)
        Context?.rotate(by: Radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))
        let Rotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Rotated!
    }
    #else
    //https://stackoverflow.com/questions/31699235/rotate-nsimage-in-swift-cocoa-mac-osx
    func Rotate(Radians: CGFloat) -> NSImage
    {
        let SinDegrees = abs(Radians)
        let CosDegrees = abs(Radians)
        let newSize = CGSize(width: size.height * SinDegrees + size.width * CosDegrees,
                             height: size.width * SinDegrees + size.height * CosDegrees)
        
        let imageBounds = NSRect(x: (newSize.width - size.width) / 2,
                                 y: (newSize.height - size.height) / 2,
                                 width: size.width, height: size.height)
        
        let otherTransform = NSAffineTransform()
        otherTransform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
        otherTransform.rotate(byRadians: Radians)
        otherTransform.translateX(by: -newSize.width / 2, yBy: -newSize.height / 2)
        
        let rotatedImage = NSImage(size: newSize)
        rotatedImage.lockFocus()
        otherTransform.concat()
        draw(in: imageBounds, from: CGRect.zero, operation: NSCompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    #endif
    
    /// Rotate the instance image of the number of passed degrees.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Degrees: Number of degrees to rotate the image to.
    /// - Returns: Rotated image.
    func Rotate(Degrees: CGFloat) -> NSImage
    {
        return Rotate(Radians: Degrees.Radians)
    }
    
    //https://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-an-uiimage-in-swift-programmatically
    func Alpha(_ Value: CGFloat) -> NSImage
    {
        let ImageRect = NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let ImageRep = self.bestRepresentation(for: ImageRect, context: nil, hints: nil) else
        {
            fatalError("Error creating image representation.")
        }
        let Image = NSImage(size: self.size, flipped: false, drawingHandler:
        {
            _ in
            return ImageRep.draw(in: NSRect(origin: NSPoint.zero, size: self.size),
                                 from: NSRect(origin: NSPoint.zero, size: self.size),
                                 operation: .copy, fraction: Value, respectFlipped: false,
                                 hints: nil)
        }
        )
        return Image
    }
    
    /// Write the instance image to a file.
    /// - Note: See [How to save an NSImage as a file.](https://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file)
    /// - Parameter ToURL: The URL where to save the image.
    /// - Returns: True on success, false if the image cannot be saved.
    public func WritePNG(ToURL: URL) -> Bool
    {
        guard let Data = tiffRepresentation,
            let Rep = NSBitmapImageRep(data: Data),
            let ImgData = Rep.representation(using: .png, properties: [.compressionFactor: NSNumber(floatLiteral: 1.0)]) else
        {
            print("Error getting data for image to save.")
            return false
        }
        do
        {
            try ImgData.write(to: ToURL)
        }
        catch
        {
            print("Error writing data: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    public func WritePNG(ToURL: URL, With BackgroundColor: NSColor) -> Bool
    {
        let BlackImage = NSImage(Color: NSColor.black, Size: self.size)
        BlackImage.lockFocus()
        let SelfRect = NSRect(origin: CGPoint.zero, size: self.size)
        self.draw(at: NSPoint.zero, from: SelfRect, operation: .overlay, fraction: 1.0)
        BlackImage.unlockFocus()
        return BlackImage.WritePNG(ToURL: ToURL)
    }
}

// MARK: - UIColor extensions.

extension NSColor
{
    /// Create a UIColor using a hex string generated by `Hex`.
    /// - Note: The format of `HexString` is `#rrggbbaa` where `rr`, `gg`, `bb`, and `aa`
    ///         are all hexidecimal values. Badly formatted strings will result in nil
    ///         being returned.
    /// - Parameter HexString: The string to use as the source value for the color.
    /// - Returns: Nil on error, UIColor on success.
    convenience init?(HexString: String)
    {
        if let (Red, Green, Blue, Alpha) = Utility.ColorChannelsFrom(HexString)
        {
            self.init(red: Red, green: Green, blue: Blue, alpha: Alpha)
        }
        else
        {
            return nil
        }
    }
    
    /// Returns the value of the color as a hex string. The string has the prefix
    /// `#` and is in RGBA order.
    /// - Note: This property converts all colors to sRGB prior to conversion to a hex string.
    var Hex: String
    {
        get
        {
            let Working = self.usingColorSpace(.sRGB)
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            Working!.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let IRed = Int(Red * 255.0)
            let SRed = String(format: "%02x", IRed)
            let IGreen = Int(Green * 255.0)
            let SGreen = String(format: "%02x", IGreen)
            let IBlue = Int(Blue * 255.0)
            let SBlue = String(format: "%02x", IBlue)
            let IAlpha = Int(Alpha * 255.0)
            let SAlpha = String(format: "%02x", IAlpha)
            let Final = "#" + SRed + SGreen + SBlue + SAlpha
            return Final
        }
    }
    
    /// Returns the YUV equivalent of the instance color, in Y, U, V order.
    /// - See
    ///   - [YUV](https://en.wikipedia.org/wiki/YUV)
    ///   - [FourCC YUV to RGB Conversion](http://www.fourcc.org/fccyvrgb.php)
    var YUV: (Y: CGFloat, U: CGFloat, V: CGFloat)
    {
        get
        {
            let Wr: CGFloat = 0.299
            let Wg: CGFloat = 0.587
            let Wb: CGFloat = 0.114
            let Umax: CGFloat = 0.436
            let Vmax: CGFloat = 0.615
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Y = (Wr * Red) + (Wg * Green) + (Wb * Blue)
            let U = Umax * ((Blue - Y) / (1.0 - Wb))
            let V = Vmax * ((Red - Y) / (1.0 - Wr))
            return (Y, U, V)
        }
    }
    
    /// Returns the CMYK equivalent of the instance color, in C, M, Y, K order.
    var CMYK: (C: CGFloat, Y: CGFloat, M: CGFloat, K: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let K: CGFloat = 1.0 - max(Red, max(Green, Blue))
            var C: CGFloat = 0.0
            var M: CGFloat = 0.0
            var Y: CGFloat = 0.0
            if K == 1.0
            {
                C = 1.0
            }
            else
            {
                C = abs((1.0 - Red - K) / (1.0 - K))
            }
            if K == 1.0
            {
                M = 1.0
            }
            else
            {
                M = abs((1.0 - Green - K) / (1.0 - K))
            }
            if K == 1.0
            {
                Y = 1.0
            }
            else
            {
                Y = abs((1.0 - Blue - K) / (1.0 - K))
            }
            return (C, M, Y, K)
        }
    }
    
    /// Returns the hue, saturation, and brightness channels. Convenience property for calling
    /// getHue on the color.
    var HSB: (H: CGFloat, S: CGFloat, B: CGFloat)
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        return (H: Hue, S: Saturation, B: Brightness)
    }
    
    /// Returns the CIE LAB equivalent of the instance color, in L, A, B order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var LAB: (L: CGFloat, A: CGFloat, B: CGFloat)
    {
        get
        {
            let (X, Y, Z) = self.XYZ
            var Xr = X / 111.144                //X referent is X10 incandescent/tungsten
            var Yr = Y / 100.0                  //Y referent is X10 incandescent/tungsten
            var Zr = Z / 35.2                   //Z referent is X10 incandescent/tungsten
            if Xr > 0.008856
            {
                Xr = pow(Xr, (1.0 / 3.0))
            }
            else
            {
                Xr = (7.787 * Xr) + (16.0 / 116.0)
            }
            if Yr > 0.008856
            {
                Yr = pow(Yr, (1.0 / 3.0))
            }
            else
            {
                Yr = (7.787 * Yr) + (16.0 / 116.0)
            }
            if Zr > 0.008856
            {
                Zr = pow(Zr, (1.0 / 3.0))
            }
            else
            {
                Zr = (7.787 * Zr) + (16.0 / 116.0)
            }
            let L = (Xr * 116.0) - 16.0
            let A = 500.0 * (Xr - Yr)
            let B = 200.0 * (Yr - Zr)
            return (L, A, B)
        }
    }
    
    /// Returns the XYZ equivalent of the instance color, in X, Y, Z order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var XYZ: (X: CGFloat, Y: CGFloat, Z: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            if Red > 0.04045
            {
                Red = pow(((Red + 0.055) / 1.055), 2.4)
            }
            else
            {
                Red = Red / 12.92
            }
            if Green > 0.04045
            {
                Green = pow(((Green + 0.055) / 1.055), 2.4)
            }
            else
            {
                Green = Green / 12.92
            }
            if Blue > 0.04045
            {
                Blue = pow(((Blue + 0.055) / 1.055), 2.4)
            }
            else
            {
                Blue = Blue / 12.92
            }
            Red = Red * 100.0
            Green = Green * 100.0
            Blue = Blue * 100.0
            let X = (Red * 0.4124) + (Green * 0.3576) * (Blue * 0.1805)
            let Y = (Red * 0.2126) + (Green * 0.7152) * (Blue * 0.0722)
            let Z = (Red * 0.0193) + (Green * 0.1192) * (Blue * 0.9505)
            return (X, Y, Z)
        }
    }
    
    /// Returns the HSL equivalent of the instance color, in H, S, L order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var HSL: (H: CGFloat, S: CGFloat, L: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Min = min(Red, Green, Blue)
            let Max = max(Red, Green, Blue)
            let Delta = Max - Min
            let L: CGFloat = (Max + Min) / 2.0
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            if Delta != 0.0
            {
                if L < 0.5
                {
                    S = Max / (Max + Min)
                }
                else
                {
                    S = Max / (2.0 - Max - Min)
                }
                let DeltaR = (((Max - Red) / 6.0) + (Max / 2.0)) / Max
                let DeltaG = (((Max - Green) / 6.0) + (Max / 2.0)) / Max
                let DeltaB = (((Max - Blue) / 6.0) + (Max / 2.0)) / Max
                if Red == Max
                {
                    H = DeltaB - DeltaG
                }
                else
                    if Green == Max
                    {
                        H = (1.0 / 3.0) + (DeltaR - DeltaB)
                    }
                    else
                        if Blue == Max
                        {
                            H = (2.0 / 3.0) + (DeltaG - DeltaR)
                }
                if H < 0.0
                {
                    H = H + 1.0
                }
                if H > 1.0
                {
                    H = H - 1.0
                }
            }
            return (H, S, L)
        }
    }
    
    /// Returns the greatest channel magnitude.
    var GreatestMagnitude: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return max(Red, Green, Blue)
        }
    }
    
    /// Returns the least channel magnitude.
    var LeastMagnitude: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return min(Red, Green, Blue)
        }
    }
    
    /// Returns a brightened version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's brightness component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Brightened color.
    func Brighten(By Percent: CGFloat) -> NSColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = 1.0 + Percent
        Brightness = Brightness * Multiplier
        return NSColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
    
    /// Returns a darkened version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's brightness component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Darkened color.
    func Darken(By Percent: CGFloat) -> NSColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = Percent
        Brightness = Brightness * Multiplier
        return NSColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
    
    /// Returns a more saturated version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's saturation component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Increased saturation color.
    func Saturate(By Percent: CGFloat) -> NSColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = 1.0 + Percent
        Saturation = Saturation * Multiplier
        return NSColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
    
    /// Returns a desaturated version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's saturation component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Desaturated color.
    func Desaturate(By Percent: CGFloat) -> NSColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = Percent
        Saturation = Saturation * Multiplier
        return NSColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
    
    /// Returns the normalized red value.
    var r: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Red
        }
    }
    
    /// Returns the normalized green value.
    var g: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Green
        }
    }
    
    /// Returns the normalized blue value.
    var b: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Blue
        }
    }
    
    /// Returns the normalized alpha value.
    var a: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Alpha
        }
    }
    
    static func Random(MinRed: CGFloat = 0.5, MinGreen: CGFloat = 0.5, MinBlue: CGFloat = 0.5) -> NSColor
    {
        let Red = CGFloat.random(in: MinRed ... 1.0)
        let Green = CGFloat.random(in: MinGreen ... 1.0)
        let Blue = CGFloat.random(in: MinBlue ... 1.0)
        return NSColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
    }
    
    static func Random(MaxRed: CGFloat = 0.5, MaxGreen: CGFloat = 0.5, MaxBlue: CGFloat = 0.5) -> NSColor
    {
        let Red = CGFloat.random(in: 0.0 ... MaxRed)
        let Green = CGFloat.random(in: 0.0 ... MaxGreen)
        let Blue = CGFloat.random(in: 0.0 ... MaxBlue)
        return NSColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
    }
    
    static func Random() -> NSColor
    {
        let Red = CGFloat.random(in: 0.0 ... 1.0)
        let Green = CGFloat.random(in: 0.0 ... 1.0)
        let Blue = CGFloat.random(in: 0.0 ... 1.0)
        return NSColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
    }
    
    static func Random(RedLow: CGFloat = 0.2, RedHigh: CGFloat = 0.8, GreenLow: CGFloat = 0.2,
                       GreenHigh: CGFloat = 0.8, BlueLow: CGFloat = 0.2, BlueHigh: CGFloat = 0.8) -> NSColor
    {
        var ARedLow = RedLow
        var ARedHigh = RedHigh
        if ARedLow > ARedHigh
        {
            swap(&ARedLow, &ARedHigh)
        }
        var AGreenLow = GreenLow
        var AGreenHigh = GreenHigh
        if AGreenLow > AGreenHigh
        {
            swap(&AGreenLow, &AGreenHigh)
        }
        var ABlueLow = BlueLow
        var ABlueHigh = BlueHigh
        if ABlueLow > ABlueHigh
        {
            swap(&ABlueLow, &ABlueHigh)
        }
        let Red = CGFloat.random(in: ARedLow ... ARedHigh)
        let Green = CGFloat.random(in: AGreenLow ... AGreenHigh)
        let Blue = CGFloat.random(in: ABlueLow ... ABlueHigh)
        return NSColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
    }
    
    /// Compare the instance color with the passed color using a common colorspace.
    /// - Note: Both the instance color and the passed color are converted to the `sRGB`
    ///         colorspace.
    /// - Parameter Other: The other color to compare to the instance color.
    /// - Returns: True if the colors are the same in the common colorspace, false if not.
    func SameAs(_ Other: NSColor) -> Bool
    {
        let SelfColor = self.usingColorSpace(.sRGB)
        let OtherColor = Other.usingColorSpace(.sRGB)
        if SelfColor == OtherColor
        {
            return true
        }
        return false
    }
    
    // MARK: - Named colors.
    
    static var Maroon: NSColor
    {
        get
        {
            return NSColor(HexString: "#800000")!
        }
    }
    
    static var Gold: NSColor
    {
        get
        {
        return NSColor(HexString: "#ffd700")!
        }
    }
    
    static var LightSkyBlue: NSColor
    {
        get
        {
            return NSColor(HexString: "#87cefa")!
        }
    }
    
    static var PrussianBlue: NSColor
    {
        get
        {
            return NSColor(HexString: "#003171")!
        }
    }
    
    static var Pistachio: NSColor
    {
        get
        {
            return NSColor(HexString: "#93c572")!
        }
    }
    
    static var Lime: NSColor
    {
        get
        {
            return NSColor(HexString: "#bfff00")!
        }
    }
    
    static var Midori: NSColor
    {
        get
        {
            return NSColor(HexString: "#2a603b")!
        }
    }
    
    static var Botan: NSColor
    {
        get
        {
            return NSColor(HexString: "#a4345d")!
        }
    }
    
    static var Shironeri: NSColor
    {
        get
        {
            return NSColor(HexString: "#ffddca")!
        }
    }
    
    static var Ajiiro: NSColor
    {
        get
        {
            return NSColor(HexString: "#ebf6f7")!
        }
    }
    
    static var ArtichokeGreen: NSColor
    {
        get
        {
            return NSColor(HexString: "#4b6f44")!
        }
    }
    
    static var TeaGreen: NSColor
    {
        get
        {
            return NSColor(HexString: "#d0f0c0")!
        }
    }
    
    static var PacificBlue: NSColor
    {
        get
        {
            return NSColor(HexString: "#009dc4")!
        }
    }
    
    static var UltraPink: NSColor
    {
        get
        {
            return NSColor(HexString: "#ff6fff")!
        }
    }
    
    static var Sunglow: NSColor
    {
        get
        {
            return NSColor(HexString: "#ffcc33")!
        }
    }
    
    static var Scarlet: NSColor
    {
        get
        {
            return NSColor(HexString: "#ff2400")!
        }
    }
}

// MARK: - NSBezierPath extensions.

extension NSBezierPath
{
    //https://www.smashingmagazine.com/2017/10/from-ios-to-macos-development/
    public var cgPath: CGPath
    {
        let Path = CGMutablePath()
        var Points = [CGPoint](repeating: .zero, count: 3)
        for Index in 0 ..< self.elementCount
        {
            let SomeType = self.element(at: Index, associatedPoints: &Points)
            switch SomeType
            {
                case .moveTo:
                    Path.move(to: Points[0])
                
                case .lineTo:
                    Path.addLine(to: Points[0])
                
                case .curveTo:
                    Path.addCurve(to: Points[2], control1: Points[0], control2: Points[1])
                
                case .closePath:
                    Path.closeSubpath()
                
                @unknown default:
                    fatalError("Sneaky extra case value enountered: \(SomeType)")
            }
        }
        return Path
    }
}

// MARK: - String extensions.

extension String
{
    public static func WithTrailingZero(_ Raw: Double) -> String
    {
        let Converted = "\(Raw)"
        if Converted.hasSuffix(".0")
        {
            return Converted
        }
        if Raw == Double(Int(Raw))
        {
            return Converted + ".0"
        }
        return Converted
    }
}

// MARK: - Array extenions.

/// Array extensions.
extension Array
{
    /// Shift the contents of an array by a specified amount.
    /// - Note: See [Shift arrays in Swift](https://stackoverflow.com/questions/31554670/shift-swift-array/44739098)
    /// - Parameter By: The number of elements to shift the array, positive or negative.
    /// - Rturns: Shifted array.
    public func Shift(By Index: Int) -> Array
    {
        if Index == 0
        {
            return self
        }
        let AdjustedIndex = Index %% self.count
        return Array(self[AdjustedIndex ..< self.count] + self[0 ..< AdjustedIndex])
    }
}

infix operator %%
/// Modulo operator.
/// - Note: See [Shift arrays in Swift](https://stackoverflow.com/questions/31554670/shift-swift-array/44739098)
/// - dividend: The dividend value.
/// - divisor: The divisor value. Fails is 0.
/// - Returns: Infix modulo.
public func %%(_ dividend: Int, _ divisor: Int) -> Int
{
    precondition(divisor > 0, "modulus must be positive")
    let Reminder = dividend % divisor
    return Reminder >= 0 ? Reminder: Reminder + divisor
}

/// Time units.
public enum TimeUnits
{
    /// Represents a calendar year.
    case Year
    /// Represents a calendar day.
    case Day
    /// Represents an hour.
    case Hour
    /// Represents a minute.
    case Minute
}
