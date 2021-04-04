//
//  +Show.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ShowCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Show"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Show"
        self.Main = Main
        self.Parent = Parent
    }
    
    func SetMainDelegate(_ Main: MainProtocol?)
    {
        self.Main = Main
    }
    
    var _CommandName: String = ""
    func CommandName() -> String
    {
        return _CommandName
    }
    
    func AlternativeName() -> String?
    {
        return "Print"
    }
    
    func CommandHelp() -> [String]
    {
        var Help = [String]()
        Help.append("Show command summary:")
        Help.append("Show setting settingname: Shows information about the specified setting key.")
        Help.append("Show settings: Shows all settings and associated current values.")
        Help.append("Show enum name: Shows the contents of the named enum.")
        Help.append("Show enum list: Shows all enums.")
        Help.append("Show ver build|date|copyright|all: Shows the version of Flatland with options.")
        Help.append("Show applications|programs: Shows a list of all running, named processes (may be slow).")
        Help.append("Show quake|quakes|earthquake|earthquakes: Shows all known current earthquakes.")
        Help.append("Alternative command name: Print")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Shows information."
    }
    
    var OtherCommands = [CommandProtocol]()
    
    func SetOtherCommands(_ Others: [CommandProtocol])
    {
    }
    
    func IsValidCommand(_ Token: String) -> Bool
    {
        if let AltName = AlternativeName()
        {
            if AltName.lowercased() == Token.lowercased()
            {
                return true
            }
        }
        return Token.lowercased() == CommandName().lowercased()
    }
    
    func ExecuteIfCommand(_ Tokens: [String]) -> Result<Any, CommandLineResults>
    {
        if Tokens.count < 1
        {
            return .failure(.EmptyCommand)
        }
        if IsValidCommand(Tokens[0])
        {
            return Execute(Tokens)
        }
        else
        {
            return .failure(.WrongCommand)
        }
    }
    
    func Execute(_ Tokens: [String]) -> Result<Any, CommandLineResults>
    {
        if Tokens.count < 1
        {
            return .failure(.EmptyCommand)
        }
        
        var CTokens = Tokens
        CTokens.removeFirst()
        
        if CTokens.count == 1
        {
            if CTokens[0].lowercased() == "help"
            {
                return .success(CommandHelp())
            }
        }
        
        var Results = [String]()
        switch CTokens[0].lowercased()
        {
            case "ver":
                if CTokens.count < 2
                {
                    return .success(["Flatland", Versioning.VerySimpleVersionString()])
                }
                let VerOption = CTokens[1].lowercased()
                switch VerOption
                {
                    case "build":
                        return .success(["Flatland", "Build: \(Versioning.Build) (\(Versioning.BuildAsHex()))",
                                         "Build ID: \(Versioning.BuildID)"])
                        
                    case "date":
                        return .success(["Flatland", "Build date: \(Versioning.BuildDate) \(Versioning.BuildTime)"])
                        
                    case "copyright", "legal":
                        return .success(["Flatland", Versioning.CopyrightText()])
                        
                    case "all":
                        return .success([Versioning.MakeVersionBlock()])
                        
                    default:
                        return .failure(.UnknownCommandParameter)
                }
                
            case "settings":
                for Setting in SettingKeys.allCases
                {
                    if let (SettingName, SettingValue, SettingType) = Settings.Query(Setting)
                    {
                        Results.append("\(SettingName): \(SettingType) = \(SettingValue)")
                    }
                }
                Results.sort()
                return .success(Results)
                
            case "setting":
                if CTokens.count < 2
                {
                    return.failure(.MissingOperand)
                }
                for Setting in SettingKeys.allCases
                {
                    if Setting.rawValue.lowercased() == CTokens[0].lowercased()
                    {
                        if let (SettingName, SettingValue, SettingType) = Settings.Query(Setting)
                        {
                            Results.append("\(SettingName): \(SettingType) = \(SettingValue)")
                            return .success(Results)
                        }
                        else
                        {
                            return .failure(.ErrorGettingSettingInformation)
                        }
                    }
                }
                
            case "enum":
                if CTokens.count < 2
                {
                    return.failure(.MissingOperand)
                }
                return ShowEnum(CTokens[1])
                
            case "quake", "quakes", "earthquake", "earthquakes":
                if let Quakes = Main?.GetEarthquakeController()
                {
                    var Ages: AgeConstraints? = nil
                    var Magnitudes: SizeConstraints? = nil
                    if Tokens.count > 2
                    {
                        let SubTokens = Array(CTokens[1 ..< Tokens.count])
                        let (SomeAge, SomeSize) = QuakeOptions(From: SubTokens)
                        Ages = SomeAge
                        Magnitudes = SomeSize
                    }
                    for Quake in Quakes.EarthquakeList
                    {
                        if ValidQuake(Quake, ForAge: Ages, ForMagnitude: Magnitudes)
                        {
                            var qd = ""
                            if Quake.DebugQuake
                            {
                                qd = "* "
                            }
                            qd.append("M\(Quake.Magnitude), ")
                            let Lat = Quake.Latitude.RoundedTo(3)
                            let SLat = Lat < 0.0 ? "\(abs(Lat))S" : "\(Lat)N"
                            qd.append("\(SLat), ")
                            let Lon = Quake.Longitude.RoundedTo(3)
                            let SLon = Lon < 0.0 ? "\(abs(Lon))W" : "\(Lon)E"
                            qd.append("\(SLon), ")
                            qd.append("\(Quake.Time.PrettyDateTime(Separator: .Space)), ")
                            qd.append("\"\(Quake.Title)\"")
                            Results.append(qd)
                        }
                    }
                    return .success(Results)
                }
                else
                {
                    return .failure(.NoQuakeController)
                }
                
            default:
                return .failure(.UnknownCommandParameter)
        }
        
        return .failure(.UnknownCommandParameter)
    }
    
    func ShowEnum(_ EnumName: String) -> Result<Any, CommandLineResults>
    {
        var Results = [String]()
        if EnumName.lowercased() == "list"
        {
            var EnumNames = [String]()
            EnumNames = EnumList.Enums.keys.map{"\($0)"}
            EnumNames.sort()
            for EnumName in EnumNames
            {
                Results.append(EnumName)
            }
            return .success(Results)
        }
        if let EnumCases = EnumList.Enums[EnumName]
        {
            Results.append(EnumName)
            for SomeCase in EnumCases
            {
                Results.append(SomeCase)
            }
            return .success(Results)
        }
        return .failure(.EnumNotFound)
    }
    
    func QuakeOptions(From: [String]) -> (AgeConstraints?, SizeConstraints?)
    {
        if From.count < 1
        {
            return (nil, nil)
        }
        let ForAge = AgeConstraints()
        ForAge.ConstraintType = .None
        let ForMagnitude = SizeConstraints()
        ForMagnitude.ConstraintType = .None
        for Option in From
        {
            let NormalizedOption = Option.lowercased()
            switch NormalizedOption
            {
                case "m4":
                    ForMagnitude.ConstrainTo = 4.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m5":
                    ForMagnitude.ConstrainTo = 5.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m6":
                    ForMagnitude.ConstrainTo = 6.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m7":
                    ForMagnitude.ConstrainTo = 7.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m8":
                    ForMagnitude.ConstrainTo = 8.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m9":
                    ForMagnitude.ConstrainTo = 9.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "a0":
                    ForAge.ConstrainTo = 0
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a1":
                    ForAge.ConstrainTo = 1
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a2":
                    ForAge.ConstrainTo = 2
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a3":
                    ForAge.ConstrainTo = 3
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a4":
                    ForAge.ConstrainTo = 4
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a5":
                    ForAge.ConstrainTo = 5
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a6":
                    ForAge.ConstrainTo = 6
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a7":
                    ForAge.ConstrainTo = 7
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a8":
                    ForAge.ConstrainTo = 8
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a9":
                    ForAge.ConstrainTo = 9
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a10":
                    ForAge.ConstrainTo = 10
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a11":
                    ForAge.ConstrainTo = 11
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a12":
                    ForAge.ConstrainTo = 12
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a13":
                    ForAge.ConstrainTo = 13
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a14":
                    ForAge.ConstrainTo = 14
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a15":
                    ForAge.ConstrainTo = 15
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a16":
                    ForAge.ConstrainTo = 16
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a17":
                    ForAge.ConstrainTo = 17
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a18":
                    ForAge.ConstrainTo = 18
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a19":
                    ForAge.ConstrainTo = 19
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a20":
                    ForAge.ConstrainTo = 20
                    ForAge.ConstraintType = .LessOrEqual
                    
                default:
                    continue
            }
        }
        return (ForAge, ForMagnitude)
    }
    
    func ValidQuake(_ Quake: Earthquake, ForAge: AgeConstraints?, ForMagnitude: SizeConstraints?) -> Bool
    {
        if ForAge == nil && ForMagnitude == nil
        {
            return true
        }
        var ValidAge = true
        var ValidMagnitude = true
        if let CheckAge = ForAge
        {
            var QuakeDays = Int(Quake.GetAge())
            QuakeDays = QuakeDays / (24 * 60 * 60)
            switch CheckAge.ConstraintType
            {
                case .None:
                    break
                    
                case .Equality:
                    ValidAge = Double(QuakeDays) == CheckAge.ConstrainTo
                    
                case .GreaterOrEqual:
                    ValidAge = Double(QuakeDays) >= CheckAge.ConstrainTo
                    
                case .LessOrEqual:
                    ValidAge = Double(QuakeDays) <= CheckAge.ConstrainTo
            }
        }
        if let CheckMag = ForMagnitude
        {
            switch CheckMag.ConstraintType
            {
                case .None:
                    break
                    
                case .Equality:
                    ValidMagnitude = Quake.Magnitude == CheckMag.ConstrainTo
                    
                case .GreaterOrEqual:
                    ValidMagnitude = Quake.Magnitude >= CheckMag.ConstrainTo
                    
                case .LessOrEqual:
                    ValidMagnitude = Quake.Magnitude <= CheckMag.ConstrainTo
            }
        }
        return ValidAge && ValidMagnitude
    }
}

class AgeConstraints
{
    public var ConstraintType: ConstraintTypes = .None
    public var ConstrainTo: Double = 0.0
}

enum ConstraintTypes
{
    case None
    case Equality
    case GreaterOrEqual
    case LessOrEqual
}

class SizeConstraints
{
    public var ConstraintType: ConstraintTypes = .None
    public var ConstrainTo: Double = 0.0
}
