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
}
