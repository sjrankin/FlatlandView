//
//  +Clear.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ClearCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Clear"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Clear"
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
        return nil
    }
    
    func CommandHelp() -> [String]
    {
        var Help = [String]()
        Help.append("Clear command summary:")
        Help.append("Program status: Clears the text from the status bar.")
        Help.append("Program inject|injected quakes|earthquakes|cities: Cleared injected objects from the scene.")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Clears objects."
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
            case "status":
                Main?.ClearStatusText()
                return .success(["Cleared"])
                
            case "inject", "injected":
                if CTokens.count < 2
                {
                    return .failure(.TooFewParameters)
                }
                switch CTokens[1].lowercased()
                {
                    case "quakes", "earthquakes":
                        if let Quakes = Main?.GetEarthquakeController()
                        {
                            Quakes.ClearInjectedEarthquakes()
                            return .success(["Earthquakes cleared"])
                        }
                        else
                        {
                            return .failure(.NoQuakeController)
                        }
                        
                    case "city", "cities":
                        return .failure(.NotImplemented)
                        
                    default:
                        return .failure(.UnknownCommandParameter)
                }
                
            default:
                return .failure(.TooFewParameters)
        }
    }
}
