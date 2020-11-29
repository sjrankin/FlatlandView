//
//  +Program.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ProgramCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Program"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Program"
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
        Help.append("Program command summary:")
        Help.append("Program quit|exit|stop: Force a fast exit of Flatland.")
        Help.append("Program settings reset|default: Resets settings to default values.")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Executes Flatland-wide actions."
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
            case "quit", "exit", "stop":
                Main?.ExitProgram()
                
            case "settings":
                if CTokens.count < 2
                {
                    return .failure(.TooFewParameters)
                }
                if ["reset", "default"].contains(CTokens[1].lowercased())
                {
                    Results.append("Will reset eventually...")
                }
                
            default:
                return .failure(.TooFewParameters)
        }
        
        return .success(Results)
    }
}
