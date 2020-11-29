//
//  +Find.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class FindCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Find"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Find"
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
        return "Search"
    }
    
    func CommandHelp() -> [String]
    {
        var Help = [String]()
        Help.append("Find command summary:")
        Help.append("Find name|location|place placename: Find and print information on the placename.")
        Help.append("Find city placename: Only searches for cities. Use quotation marks for cities with spaces in the name.")
        Help.append("Find enum case: Find and print information on the enum case.")
        Help.append("Alternative command name: Search")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Find a location or value."
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
        
        switch CTokens[0].lowercased()
        {
            case "name", "location", "place":
                if CTokens.count < 2
                {
                    return .failure(.NoPlacename)
                }
                return SearchForPlaces(CTokens[1])
                
            case "city":
                print("Looking for \(CTokens[1])")
                if CTokens.count < 2
                {
                    return .failure(.NoPlacename)
                }
                return SearchForPlaces(CTokens[1], CityOnly: true)
                
            case "enum":
                if CTokens.count < 2
                {
                    return .failure(.NoEnumCase)
                }
                
            default:
                return .failure(.NothingToFind)
        }
        
        return .failure(.NotImplemented)
    }
    
    func SearchForPlaces(_ Placename: String, CityOnly: Bool = false) -> Result<Any, CommandLineResults>
    {
        if Placename.isEmpty
        {
            return .failure(.NoPlacename)
        }
        let LocationFinder = Locations()
        LocationFinder.Main = Main
        if let Record = LocationFinder.SearchFor(Placename, Compressed: false, CaseSensitive: false)
        {
            let Coordinates = Utility.PrettyCoordinates(Record.Latitude, Record.Longitude)
            switch Record.LocationType
            {
                case .City:
                    return .success(["Found city \(Record.Name) at \(Coordinates), population \(Record.Population)"])
                    
                case .Home:
                    if !CityOnly
                    {
                    let HomeName = Record.Name.isEmpty ? "" : "\(Record.Name) "
                    return .success(["Found home \(HomeName)at \(Coordinates)"])
                    }
                    
                case .UNESCO:
                    if !CityOnly
                    {
                    return .success(["Found World Heritage Site \(Record.Name) at \(Coordinates)"])
                    }
                    
                case .UserPOI:
                    if !CityOnly
                    {
                    return .success(["Found user POI \(Record.Name) at \(Coordinates)"])
                    }
            }
        }
        return .failure(.PlacenameNotFound)
    }
}
