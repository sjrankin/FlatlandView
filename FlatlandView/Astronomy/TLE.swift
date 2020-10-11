//
//  TLE.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Represents a Two Line Element used to describe satellite orbits.
class TLE: CustomDebugStringConvertible
{
    /// Initializer. Call `Parse` to populate fields with a TLE record.
    init()
    {
    }
    
    /// Initializer.
    /// - Note: Parsing the TLE may result in fatal errors the if TLE contains bad data.
    /// - Parameter With: The source TLE used to populate the class.
    init(With Raw: String)
    {
        SourceTLE = Raw
        Parse(Raw)
    }
    
    /// Contains the source TLE from either the initializer or `Parse`, whichever was called last.
    var SourceTLE: String = ""
    
    /// Parse the TLE.
    /// - Note: Fatal errors are generated on bad data.
    /// - Parameter Raw: The TLE to parse.
    func Parse(_ Raw: String)
    {
        SourceTLE = Raw
        let Parts = Raw.split(separator: "\n", omittingEmptySubsequences: true)
        let NoTitle = Parts.count == 2
        if !NoTitle
        {
            Name = String(Parts[0])
            ParseLine1(Line: String(Parts[1]))
            ParseLine2(Line: String(Parts[2]))
        }
        else
        {
            ParseLine1(Line: String(Parts[0]))
            ParseLine2(Line: String(Parts[1]))
        }
    }
    
    /// Parse line 1 of the TLE.
    /// - Note: Fatal errors are generated on bad data.
    /// - Parameter Line: The first line of data.
    private func ParseLine1(Line: String)
    {
        let RawCatalog = SubString(Line, Start: 3, End: 7)
        if let CatalogNum = Int(RawCatalog)
        {
            CatalogNumber = CatalogNum
        }
        else
        {
            fatalError("Error parsing line 1, columns 3-7: Satellite Catalog Number: \"\(RawCatalog)\"")
        }
        let RawClassification = SubString(Line, Start: 8, End: 8)
        switch RawClassification
        {
            case SatelliteClassifications.Unclassified.rawValue:
                Classification = .Unclassified
                
            case SatelliteClassifications.Classified.rawValue:
                Classification = .Classified
                
            case SatelliteClassifications.Secret.rawValue:
                Classification = .Secret
                
            default:
                fatalError("Error parsing line 1, columns 8-8: Classification: \"\(RawClassification)\"")
        }
        let RawYear = SubString(Line, Start: 10, End: 11)
        if let Year = Int(RawYear)
        {
            LaunchYear = Year
        }
        else
        {
            fatalError("Error parsing line 1, columns 10-11: Launch Year: \"\(RawYear)\"")
        }
        let RawSequence = SubString(Line, Start: 12, End: 14)
        if let Seq = Int(RawSequence)
        {
            LaunchInYear = Seq
        }
        else
        {
            fatalError("Error parsing line 1, columns 12-14: Launch Sequence: \"\(RawSequence)\"")
        }
        PieceOfLaunch = SubString(Line, Start: 15, End: 17)
        let RawYearEpoch = SubString(Line, Start: 19, End: 20)
        if let YearEpoch = Int(RawYearEpoch)
        {
            EpochYear = YearEpoch
        }
        else
        {
            fatalError("Error parsing line 1, columns 19-20: Epoch Year: \"\(RawYearEpoch)\"")
        }
        let RawDayEpoch = SubString(Line, Start: 21, End: 32)
        if let DayEpoch = Double(RawDayEpoch)
        {
            EpochDay = DayEpoch
        }
        else
        {
            fatalError("Error parsing line 1, columns 21-32: Epoch Year: \"\(RawDayEpoch)\"")
        }
        let RawFirstDer = SubString(Line, Start: 34, End: 43)
        if let FirstDer = Double(RawFirstDer)
        {
            MeanMotionFirstDerivative = FirstDer
        }
        else
        {
            fatalError("Error parsing line 1, columns 34-43: Mean Motion First Derivative: \"\(RawFirstDer)\"")
        }
        let RawSecondDer = SubString(Line, Start: 45, End: 52)
        MeanMotionSecondDerivative = MakeDouble(From: RawSecondDer, "MeanMotionSecondDerivative")
        let RawBSTAR = SubString(Line, Start: 54, End: 61)
        BSTAR = MakeDouble(From: RawBSTAR, "BSTAR")
        let RawElement = SubString(Line, Start: 65, End: 68)
        if let ElementNum = Int(RawElement)
        {
            ElementSet = ElementNum
        }
        else
        {
            fatalError("Error parsing line 1, columns 65-68: Element Set Number: \"\(RawElement)\"")
        }
    }
    
    /// Parse line 2 of the TLE.
    /// - Note: Fatal errors are generated on bad data.
    /// - Parameter Line: The second line of data.
    private func ParseLine2(Line: String)
    {
        let RawInclination = SubString(Line, Start: 9, End: 16)
        if let Incl = Double(RawInclination)
        {
            Inclination = Incl
        }
        else
        {
            fatalError("Error parsing line 2, columns 9-16: Inclination: \"\(RawInclination)\"")
        }
        let RawRAAN = SubString(Line, Start: 18, End: 25)
        if let PRAAN = Double(RawRAAN)
        {
            RAAN = PRAAN
        }
        else
        {
            fatalError("Error parsing line 2, columns 18-25: Right Angle Ascending Node: \"\(RawRAAN)\"")
        }
        let RawEcc = SubString(Line, Start: 27, End: 33)
        Eccentricity = MakeDoubleNoExp(From: RawEcc, "Eccentricity")
        let RawPerigee = SubString(Line, Start: 35, End: 42)
        if let ThePerigee = Double(RawPerigee)
        {
            ArgumentOfPerigee = ThePerigee
        }
        else
        {
            fatalError("Error parsing line 2, columns 35-42: Argument of Perigee: \"\(RawPerigee)\"")
        }
        let RawAnomaly = SubString(Line, Start: 44, End: 51)
        if let TheAnomaly = Double(RawAnomaly)
        {
            MeanAnomaly = TheAnomaly
        }
        else
        {
            fatalError("Error parsing line 2, columns 44-51: Mean Anomaly: \"\(RawAnomaly)\"")
        }
        let RawRevolutions = SubString(Line, Start: 53, End: 63)
        if let TheRevolutions = Double(RawRevolutions)
        {
            MeanMotion = TheRevolutions
        }
        else
        {
            fatalError("Error parsing line 2, columns 53-63: Mean Motion: \"\(RawRevolutions)\"")
        }
        let RawRevCount = SubString(Line, Start: 64, End: 68)
        if let RevCount = Int(RawRevCount)
        {
            RevolutionCount = RevCount
        }
        else
        {
            fatalError("Error parsing line 2, columns 64-68: Revolution Number: \"\(RawRevCount)\"")
        }
    }
    
    /// Create a double from the passed string, which is assumed to be a decimal-less decimal value
    /// according to the TLE format.
    /// - Note: Fatal errors are generated on parsing errors.
    /// - Parameter From: The source string.
    /// - Parameter FieldName: Name of the field for the data. Used for debug purposes.
    /// - Returns: Double value based on the contents of `From`.
    private func MakeDoubleNoExp(From: String, _ FieldName: String) -> Double
    {
        guard let IVal = Int(From) else
        {
            fatalError("Conversion error: \(From) in field \(FieldName)")
        }
        var DVal = Double(IVal)
        for _ in 1 ... 6
        {
            DVal = DVal * 0.1
        }
        return DVal
    }
    
    /// Create a double from the passed string, which is assumed to be a decimal-less decimal value according
    /// to the TLE format.
    /// - Note: Fatal errors are generated on bad data.
    /// - Parameter From: The source string.
    /// - Parameter FieldName: Name of the field for the data. Used for debug purposes.
    /// - Returns: Double value based on the contents of `From`.
    private func MakeDouble(From: String, _ FieldName: String) -> Double
    {
        var Sign: Double = 1.0
        var Working = From
        if Working.first == "-"
        {
            Working.removeFirst()
            Sign = -1.0
        }
        let Parts = Working.split(separator: "-")
        if Parts.count != 2
        {
            fatalError("Unexpected format of assumed decimal number: \(From) in field \(FieldName)")
        }
        guard var Leading: Double = Double(String(Parts[0])) else
        {
            fatalError("Error converting value to double: \"\(String(Parts[0]))\" in field \(FieldName)")
        }
        Leading = Leading * Sign
        guard let Exp: Int = Int(String(Parts[1])) else
        {
            fatalError("Error converting exponent to double: \"\(String(Parts[1]))\" in field \(FieldName)")
        }
        var Final = Leading * 0.00001
        for _ in 0 ..< Exp
        {
            Final = Final * 0.1
        }
        return Final
    }
    
    private func SubString(_ Raw: String, Start: Int, End: Int) -> String
    {
        let AStart = Start - 1
        let AEnd = End - 1
        if AStart < 0 || AEnd < AStart
        {
            print("AStart less than 0.")
            return ""
        }
        if AEnd > Raw.count - 1 || AStart > AEnd
        {
            print("AEnd > count - 1.")
            return ""
        }
        let StartIndex = Raw.index(Raw.startIndex, offsetBy: AStart)
        let EndIndex = Raw.index(Raw.startIndex, offsetBy: AEnd)
        let Range = StartIndex ... EndIndex
        var Final = String(Raw[Range])
        Final = Final.trimmingCharacters(in: .whitespacesAndNewlines)
        return Final
    }
    
    // MARK: - TLE Parsed Properties
    
    var Name: String = ""
    
    var CatalogNumber: Int = 0
    
    var Classification: SatelliteClassifications = .Unclassified
    
    var LaunchYear: Int = 0
    
    var LaunchInYear: Int = 0
    
    var PieceOfLaunch: String = "A"
    
    var EpochYear: Int = 0
    
    var EpochDay: Double = 0.0
    
    /// AKA Ballistic Coefficient
    var MeanMotionFirstDerivative: Double = 0.0
    
    var MeanMotionSecondDerivative: Double = 0.0
    
    var BSTAR: Double = 0.0
    
    var Ephemeris: Int = 0
    
    var ElementSet: Int = 0
    
    var Inclination: Double = 0.0
    
    var RAAN: Double = 0.0
    
    var Eccentricity: Double = 0.0
    
    var ArgumentOfPerigee: Double = 0.0
    
    var MeanAnomaly: Double = 0.0
    
    var MeanMotion: Double = 0.0
    
    var RevolutionCount: Int = 0
    
    // MARK: - Debugging properties and functions.
    
    var debugDescription: String
    {
        get
        {
            var Result = ""
            if !Name.isEmpty
            {
                Result.append(Name)
                Result.append("\n")
            }
            
            var Line1 = ""
            Line1.append("1 ")
            Line1.append("\(CatalogNumber) ")
            Line1.append("\(Classification.rawValue) ")
            Line1.append("\(LaunchYear) ")
            Line1.append("\(LaunchInYear) ")
            Line1.append("\(PieceOfLaunch) ")
            Line1.append("\(EpochYear) ")
            Line1.append("\(EpochDay) ")
            Line1.append("\(MeanMotionFirstDerivative) ")
            Line1.append("\(MeanMotionSecondDerivative) ")
            Line1.append("\(BSTAR) ")
            Line1.append("0 ")
            Line1.append("\(ElementSet)\n")
            Result.append(Line1)
            
            var Line2 = ""
            Line2.append("2 ")
            Line2.append("\(CatalogNumber) ")
            Line2.append("\(Inclination) ")
            Line2.append("\(RAAN) ")
            Line2.append("\(Eccentricity) ")
            Line2.append("\(ArgumentOfPerigee) ")
            Line2.append("\(MeanAnomaly) ")
            Line2.append("\(MeanMotion) ")
            Line2.append("\(RevolutionCount) ")
            Result.append(Line2)
            
            return Result
        }
    }
}

enum SatelliteClassifications: String, CaseIterable
{
    case Unclassified = "U"
    case Classified = "C"
    case Secret = "S"
}
