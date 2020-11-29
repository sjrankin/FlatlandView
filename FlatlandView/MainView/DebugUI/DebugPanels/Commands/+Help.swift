//
//  +Help.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class HelpCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Help"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Help"
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
        Help.append("Help command summary:")
        Help.append("Help: The command summary for help.")
        Help.append("Help help: This message.")
        Help.append("Help command: Help for the specified command.")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Shows help for the command line and commands."
    }
    
    var OtherCommands = [CommandProtocol]()
    
    func SetOtherCommands(_ Others: [CommandProtocol])
    {
        OtherCommands = Others
    }
    
    func GetOtherCommand(With CommandName: String) -> CommandProtocol?
    {
        for SomeOtherCommand in OtherCommands
        {
            if SomeOtherCommand.IsValidCommand(CommandName)
            {
                return SomeOtherCommand
            }
        }
        return nil
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
        
        if Tokens.count == 1
        {
            return .success([CommandSummary()])
        }
        
        var CTokens = Tokens
        CTokens.removeFirst()
        
        switch CTokens[0].lowercased()
        {
            case "help":
                return .success([CommandHelp()])
                
            default:
                if let OtherCommand = GetOtherCommand(With: CTokens[0])
                {
                    return .success(OtherCommand.CommandHelp())
                }
                else
                {
                    return .failure(.CannotFindCommand)
                }
        }
    }
}
