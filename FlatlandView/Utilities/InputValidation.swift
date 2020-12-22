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
            if ActualValue < 0.0 || Multiplier == -1.0
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
            if ActualValue < 0.0 || Multiplier == -1.0
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
    
    /// Array of unit names.
    public static let UnitNames = ["km", "mi"]
    
    /// Validate a string the user entered for a distance.
    /// Notes:
    ///  - All distances are intended to be double values.
    ///  - Unless specified, the units are the same as the user setting value. If specified, that unit is used.
    ///  - Explicit units are shown in `UnitNames` and are specified immediately after the numeric value or
    ///    with a space between the numeric value and the unit. Capitalization is ignored.
    /// - Parameter Raw: The raw value entered by the user.
    /// - Returns: Result with success having the value and the units as determined by this function, of
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
}
