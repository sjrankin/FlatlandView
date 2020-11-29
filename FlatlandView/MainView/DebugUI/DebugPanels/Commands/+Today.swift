//
//  +Today.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class TodayCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
     init()
    {
        _CommandName = "Today"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Today"
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
        return "Now"
    }
    
     func CommandHelp() -> [String]
    {
        var Help = [String]()
        Help.append("Today command summary:")
        Help.append("Today: Shows solar times for today for current home location.")
        Help.append("Today latitude longitude: Shows solar times for today at the specified location.")
        Help.append("Today location: Shows solar times for today at the named location.")
        Help.append("You can add \"Date=dd-mmm-yyyy\" to change the date of the calculations.")
        Help.append("Alternative command name: Now")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Shows solar times for the day and optionally location."
    }
    
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
    
    /// Execute the command.
    /// - Parameter Tokens: Tokenized command line. The first token is assumed to be the
    ///                     command itself and is ignored.
    /// - Returns: Result code. On success, an array of output strings to display is returned.
    func Execute(_ Tokens: [String]) -> Result<Any, CommandLineResults>
    {
        if Tokens.count < 1
        {
            return .failure(.EmptyCommand)
        }
        var CTokens = Tokens
        CTokens.removeFirst()
        
        var ForDate: Date? = nil
        var DateToken = ""
        var Index = 0
        var DateIndex = -1
        for SomeToken in CTokens
        {
            if SomeToken.lowercased().hasPrefix("date=")
            {
                DateIndex = Index
                DateToken = SomeToken
                break
            }
            Index = Index + 1
        }
        if DateIndex > -1
        {
            CTokens.remove(at: DateIndex)
            let Parts = DateToken.split(separator: "=", omittingEmptySubsequences: true)
            if Parts.count != 2
            {
                return .failure(.BadDate)
            }
            if let OtherDate = ParseDate(String(Parts[1]))
            {
                ForDate = OtherDate
            }
            else
            {
                return .failure(.BadDate)
            }
        }

        if CTokens.count == 1
        {
            if CTokens[0].lowercased() == "help"
            {
                return .success(CommandHelp())
            }
        }
        
        let DataForDate = ForDate ?? Date()
        switch CTokens.count
        {
            case 0:
                if Settings.HaveLocalLocation()
                {
                    let Latitude = Settings.GetDoubleNil(.LocalLatitude, 0.0)!
                    let Longitude = Settings.GetDoubleNil(.LocalLatitude, 0.0)!
                    Sun = SolarToday(For: DataForDate, Latitude: Latitude, Longitude: Longitude,
                                     ResultsAvailable(_:))
                    return .failure(.LateResults)
                }
                else
                {
                    return .failure(.HomeLocationNotSet)
                }
                
            case 1:
                let LocationFinder = Locations()
                LocationFinder.Main = Main
                if let Record = LocationFinder.SearchFor(Tokens[1], Compressed: true, CaseSensitive: false)
                {
                    Sun = SolarToday(For: DataForDate, Latitude: Record.Latitude, Longitude: Record.Longitude,
                                     ResultsAvailable(_:))
                    return .failure(.LateResults)
                }
                else
                {
                    return .failure(.PlacenameNotFound)
                }
                
            case 2:
                if let (Latitude, Longitude) = Utility.PrettyCoordinateToActual("\(Tokens[1]) \(Tokens[2])")
                {
                    Sun = SolarToday(For: DataForDate, Latitude: Latitude, Longitude: Longitude,
                                     ResultsAvailable(_:))
                    return .failure(.LateResults)
                }
                else
                {
                    return .failure(.ParseFailure)
                }
                
            default:
                return .failure(.TooManyParameters)
        }
    }
    
    func ResultsAvailable(_ Success: Bool)
    {
        self.Results.removeAll()
        let HourOffset = self.Sun!.TimezoneSeconds! / (60 * 60)
        let LocalOffset = self.Sun!.CurrentTimezoneSeconds / (60 * 60)
        let OffsetDelta = LocalOffset - HourOffset
        let AdjustBy = Double(OffsetDelta * 60 * 60 * -1)
        var RiseString = "No sunrise"
        var SetString = "No sunset"
        if let Rise = self.Sun!.Sunrise
        {
            RiseString = Date.PrettyTime(From: Rise.addingTimeInterval(AdjustBy))
        }
        if let Set = self.Sun!.Sunset
        {
            SetString = Date.PrettyTime(From: Set.addingTimeInterval(AdjustBy))
        }
        self.Results.append("Sunrise: \(RiseString)")
        self.Results.append("Sunset: \(SetString)")
        Parent?.LateResults(self.Results)
    }
    
    var Results = [String]()
    var Sun: SolarToday? = nil
    
    func ParseDate(_ Raw: String) -> Date?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.split(separator: "-", omittingEmptySubsequences: true)
        var Day: Int = 0
        var Year: Int = 0
        var Month: String = ""
        if Parts.count == 3
        {
            if let DayP = Int(String(Parts[0]))
            {
                Day = DayP
            }
            else
            {
                return nil
            }
            Month = String(Parts[1])
            if let YearP = Int(String(Parts[2]))
            {
                Year = YearP
            }
            else
            {
                return nil
            }
        }
        else
        {
            if Raw.count != 9
            {
                return nil
            }
            let DayS = String.SubString(Raw, Start: 0, End: 1)
            if let DaySP = Int(DayS)
            {
                Day = DaySP
            }
            else
            {
                return nil
            }
             Month = String.SubString(Raw, Start: 2, End: 4)
            let YearS = String.SubString(Raw, Start: 5, End: 8)
            if let YearSP = Int(YearS)
            {
                Year = YearSP
            }
            else
            {
                return nil
            }
        }
        var FinalMonth = 0
        if let MonthV = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"].firstIndex(of: Month.lowercased())
        {
            FinalMonth = MonthV + 1
        }
        else
        {
            return nil
        }
        var Components = DateComponents()
        Components.year = Year
        Components.month = FinalMonth
        Components.day = Day
        return Calendar.current.date(from: Components)
    }
}
