//
//  +Inject.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class InjectCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Inject"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Inject"
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
        return "Insert"
    }
    
    func CommandHelp() -> [String]
    {
        var Help = [String]()
        Help.append("Inject command summary:")
        Help.append("Inject quake|earthquake latitude longitude magnitude: Injects an earthquake into the scene.")
        Help.append("Inject city latitude longitude name population: Injects a city into the scene.")
        Help.append("Alternative command name: Insert")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Injects objects into the scene."
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
            case "quake", "earthquake":
                if Tokens.count != 5
                {
                    return .failure(.TooFewParameters)
                }
                let RawLat = Tokens[2]
                let RawLon = Tokens[3]
                let RawMag = Tokens[4]
                guard let ActualLat = Double(RawLat) else
                {
                    return .failure(.BadCoordinates)
                }
                guard let ActualLon = Double(RawLon) else
                {
                    return .failure(.BadCoordinates)
                }
                guard let ActualMag = Double(RawMag) else
                {
                    return .failure(.ParseFailure)
                }
                let DebugQuake = Earthquake(Latitude: ActualLat, Longitude: ActualLon, Magnitude: ActualMag,
                                            IsDebug: true)
                DebugQuake.QuakeID = UUID()
                DebugQuake.Sequence = Int.random(in: 100000 ... 500000)
                DebugQuake.Code = String.Random(10)
                if let Quakes = Main?.GetEarthquakeController()
                {
                    Quakes.InjectEarthquake(DebugQuake)
                    return .success(["Injected M\(ActualMag) quake at \(ActualLat), \(ActualLon)"])
                }
                else
                {
                    return .failure(.NoQuakeController)
                }
                
            case "city":
                if CTokens.count < 2
                {
                    return .failure(.TooFewParameters)
                }
                
            default:
                return .failure(.TooFewParameters)
        }
        
        return .failure(.TooFewParameters)
    }
}
