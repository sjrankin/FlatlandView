//
//  InputValidation.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Class that helps with validating user input.
class InputValidation
{
    // MARK: - Number validation
    
    /// Validate a number entered by the user. Numbers may be in one of the following formats:
    /// - Integer - determined if there are no decimal points in the string.
    /// - Double - determined by the presence of a decimal point in the string.
    /// - Hex - determined by leading `#` or `0x` strings.
    /// - Parameter Raw: The raw value to parse.
    /// - Returns: Results code with the value and type on success, error code on failure.
    public static func ValidNumber(_ Raw: String) -> Result<(Double, NumericValueTypes), ValidationResult>
    {
        var Working = Raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if Working.isEmpty
        {
            return .failure(.MissingInput)
        }
        var NumberType = NumericValueTypes.Normal
        var IsHex = false
        if Working.starts(with: "#")
        {
            NumberType = .HexPound
            IsHex = true
            Working.removeFirst()
        }
        if Working.starts(with: "0x")
        {
            NumberType = .Hex0X
            IsHex = true
            Working.removeFirst(2)
        }
        if IsHex
        {
            if Working.isEmpty
            {
                return .failure(.MalFormedHexValue)
            }
            if let HexValue = Int(Working, radix: 16)
            {
                return .success((Double(HexValue), NumberType))
            }
            return .failure(.MalFormedHexValue)
        }
        if Working.contains(".")
        {
            if let DValue = Double(Working)
            {
                return .success((DValue, .Double))
            }
            else
            {
                return .failure(.CannotParseDouble)
            }
        }
        if let IValue = Int(Working)
        {
            return .success((Double(IValue), .Integer))
        }
        return .failure(.CannotParse)
    }
    
    // MARK: - Color channel validation
    
    /// Validate a color channel entered by the user. Color channel strings may be in one of these forms:
    /// - `#`hex number ranging from 0 to FF
    /// - `0x`hex number ranging from 0 to FF
    /// - Integer ranging from 0 to 255
    /// - Double value ranging from 0.0 to 1.0. Any double value greater than 1.0 is treated as an integer.
    ///   Double values are triggered by the presence of a decimal point in the string.
    /// - Parameter Raw: The raw input string to validate.
    /// - Returns: Result code with the validated value on success, an error code on failure. The value returned
    ///            on success is a normal value. The input type is returned as the second item in the tuple.
    public static func ChannelValidation(_ Raw: String) -> Result<(Double, NumericValueTypes), ValidationResult>
    {
        if Raw.isEmpty
        {
            return .failure(.MissingInput)
        }
        
        let ConversionResult = ValidNumber(Raw)
        switch ConversionResult
        {
            case .failure(let Why):
                return .failure(Why)
                
            case .success(let (Value, InputType)):
                if Value < 0.0 || Value > 255.0
                {
                    return .failure(.ChannelValueOutOfRange)
                }
                if Value >= 0.0 && Value <= 1.0
                {
                    return .success((Value, .Normal))
                }
                if Value - Double(Int(Value)) == 0.0
                {
                    return .success((Value, .Integer))
                }
                return .success((Value, InputType))
        }
    }
    
    /// Validate a color channel entered by the user. Color channel strings must be a normal (double) value.
    /// - Parameter Raw: The raw input string to validate.
    /// - Returns: Result code with the validated value on success, an error code on failure.
    public static func NormalizedChannelValidation(_ Raw: String) -> Result<Double, ValidationResult>
    {
        if Raw.isEmpty
        {
            return .failure(.MissingInput)
        }
        if let Value = Double(Raw)
        {
            if Value < 0.0 || Value > 1.0
            {
                return .failure(.NotNormalized)
            }
            return .success(Value)
        }
        return .failure(.NotANumber)
    }
    
    // MARK: - Latitude/longitude validation
    
    /// Extract alpha (but not "+" or "-" from the passed string.
    /// - Parameter From: The source string to extract alpha characters from.
    /// - Returns: Tuple with a string with alpha characters removed and an array with the removed characters.
    private static func ExtractAlphaComponents(From: String) -> (Cleaned: String, Alpha: [String])
    {
        var Working = From.replacingOccurrences(of: " ", with: "")
        Working = Working.lowercased()
        var Result = ""
        var AlphaValues = [String]()
        for Char in Working
        {
            let ActualChar = String(Char)
            if Range(uncheckedBounds: ("a","z")).contains(ActualChar)
            {
                AlphaValues.append(ActualChar)
                continue
            }
            Result.append(ActualChar)
        }
        return (Cleaned: Result, Alpha: AlphaValues)
    }
    
    /// Validate a string that may contain a latitude value entered by the user.
    /// - Note: Valid input formats are:
    ///     - Any double value in the range of -90.0 to 90.0.
    ///     - Any positive double value in the range of 0.0 to 90.0 with a hemispherical suffix of either
    ///       `s` or `n`.
    /// - Note: All spaces are removed before validation.
    /// - Parameter Raw: The raw string entered by the user. The value is treated as case insensitive.
    /// - Returns: Result code with the validated value on success, an error code on failure.
    public static func LatitudeValidation(_ Raw: String) -> Result<Double, ValidationResult>
    {
        if Raw.isEmpty
        {
            return .failure(.MissingInput)
        }
        let Working = Raw.lowercased()
        let (Stripped, Chars) = ExtractAlphaComponents(From: Working)
        if Chars.count > 1
        {
            return .failure(.TooManyHemispheres)
        }
        if Chars.count == 1
        {
            if Chars[0] == "e" || Chars[0] == "w"
            {
                return .failure(.WrongHemisphere)
            }
        }
        var Multiplier = 1.0
        if Chars.count == 1
        {
            if Chars[0] == "s"
            {
                Multiplier = -1.0
            }
        }
        if var ActualValue = Double(Stripped)
        {
            if ActualValue < 0.0 && Multiplier == -1.0
            {
                Multiplier = 1.0
            }
            ActualValue = ActualValue * Multiplier
            if ActualValue < -90.0 || ActualValue > 90.0
            {
                return .failure(.LatitudeOutOfRange)
            }
            return .success(ActualValue)
        }
        return .failure(.CannotParse)
    }
    
    /// Validate a string that may contain a longitude value entered by the user.
    /// - Note: Valid input formats are:
    ///     - Any double value in the range of -180.0 to 180.0.
    ///     - Any positive double value in the range of 0.0 to 180.0 with a hemispherical suffix of either
    ///       `w` or `e`.
    /// - Note: All spaces are removed before validation.
    /// - Parameter Raw: The raw string entered by the user. The value is treated as case insensitive.
    /// - Returns: Result code with the validated value on success, an error code on failure.
    public static func LongitudeValidation(_ Raw: String) -> Result<Double, ValidationResult>
    {
        if Raw.isEmpty
        {
            return .failure(.MissingInput)
        }
        let Working = Raw.lowercased()
        let (Stripped, Chars) = ExtractAlphaComponents(From: Working)
        if Chars.count > 1
        {
            return .failure(.TooManyHemispheres)
        }
        if Chars.count == 1
        {
            if Chars[0] == "n" || Chars[0] == "s"
            {
                return .failure(.WrongHemisphere)
            }
        }
        var Multiplier = 1.0
        if Chars.count == 1
        {
            if Chars[0] == "w"
            {
                Multiplier = -1.0
            }
        }
        if var ActualValue = Double(Stripped)
        {
            if ActualValue < 0.0 && Multiplier == -1.0
            {
                Multiplier = 1.0
            }
            ActualValue = ActualValue * Multiplier
            if ActualValue < -180.0 || ActualValue > 180.0
            {
                return .failure(.LongitudeOutOfRange)
            }
            return .success(ActualValue)
        }
        return .failure(.CannotParse)
    }
    
    // MARK: - Distance validation
    
    /// Array of unit names.
    public static let UnitNames = ["km", "mi"]
    
    /// Validate a string the user entered for a distance.
    /// Notes:
    ///  - All distances are intended to be double values.
    ///  - Unless specified, the units are the same as the user setting value. If specified, that unit is used.
    ///  - Explicit units are shown in `UnitNames` and are specified immediately after the numeric value or
    ///    with a space between the numeric value and the unit. Capitalization is ignored.
    /// - Parameter Raw: The raw value entered by the user.
    /// - Returns: Result with success having the value and the units as determined by this function, or
    ///            failure with the reason why.
    public static func DistanceValidation(_ Raw: String) -> Result<(Value: Double, Units: InputUnits), ValidationResult>
    {
        if Raw.isEmpty
        {
            return .failure(.MissingInput)
        }
        var Working = Raw.lowercased()
        var WorkingUnits = Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers)
        var FoundUnit = false
        
        //Do a quick check for unknown units.
        let Parts = Working.split(separator: " ", omittingEmptySubsequences: true)
            if Parts.count == 2
            {
                let SomeUnit = String(Parts[1]).lowercased()
                if !UnitNames.contains(SomeUnit)
                {
                    return .failure(.UnknownUnit)
                }
            }

        //Check for known units.
        if Working.hasSuffix("km")
        {
            WorkingUnits = .Kilometers
            FoundUnit = true
            Working = Working.replacingOccurrences(of: "km", with: "")
        }
        if Working.hasSuffix("mi")
        {
            if FoundUnit
            {
                return .failure(.TooManyUnits)
            }
            WorkingUnits = .Miles
            Working = Working.replacingOccurrences(of: "mi", with: "")
        }
        
        //Condition the input
        Working = Working.trimmingCharacters(in: .whitespacesAndNewlines)
        if let Actual = Double(Working)
        {
            switch WorkingUnits
            {
                case .Kilometers:
                    if Actual > PhysicalConstants.EarthCircumference.rawValue
                    {
                        return .failure(.InputValueTooBig)
                    }
                    
                case .Miles:
                    if Actual > PhysicalConstants.EarthCircumferenceMiles.rawValue
                    {
                        return .failure(.InputValueTooBig)
                    }
            }
            return .success((Value: Actual, Units: WorkingUnits))
        }
        return .failure(.CannotParse)
    }
}

/// Input validation result types.
enum ValidationResult: String, CaseIterable, Error
{
    /// Input validation successed - eg, the value was valid.
    case Success = "Success"
    /// No input was found - the string to parse was empty.
    case MissingInput = "Nothing to parse"
    /// Input is not parsable for some reason. Used if no other failure mode can be determined.
    case CannotParse = "Input not parsable"
    /// The input value is too big. In general, input values for distances are not allowed to be greater
    /// than the circumference of the Earth.
    case InputValueTooBig = "Value too big: Max is circumference of Earth"
    /// An unknown unit was specified.
    case UnknownUnit = "Unknown unit"
    /// Too many units were specified.
    case TooManyUnits = "Too many units"
    /// Unknown hemisphere found.
    case UnknownHemisphere = "Unknown hemisphere - must be E, W, N, or S."
    /// Too many hemispheres specified.
    case TooManyHemispheres = "Too many hemispheres specified."
    /// Invalid latitude.
    case LatitudeOutOfRange = "Latitude must be in range of -90.0 to 90.0"
    /// Invalid longitude.
    case LongitudeOutOfRange = "Longitude must be in range of -180.0 to 180.0"
    /// Invalid hemisphere, eg, N for longitude.
    case WrongHemisphere = "Invalid hemisphere for coorindate"
    /// Value is not normalized - between 0.0 and 1.0.
    case NotNormalized = "Not a normalized value"
    /// Value is not a number.
    case NotANumber = "Input is not a number"
    /// Channel value is out of range high or low.
    case ChannelValueOutOfRange = "Channel value is too big or too small"
    /// Unable to interpret hex value.
    case MalFormedHexValue = "Hex value is mal-formed"
    /// Mal-formed double value.
    case CannotParseDouble = "Error parsing double value"
}

enum NumericValueTypes: String, CaseIterable
{
    case Integer = "Integer"
    case HexPound = "HexPound"
    case Hex0X = "Hex0X"
    case Normal = "Normal"
    case Double = "Double"
}
