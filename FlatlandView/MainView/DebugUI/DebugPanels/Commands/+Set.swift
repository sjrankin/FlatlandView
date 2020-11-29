//
//  +Set.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SetCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Set"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Set"
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
        Help.append("Set command summary:")
        Help.append("Set setting value: Sets the setting key to the specified value.")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Sets the value of an object."
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
        
        if CTokens.count < 2
        {
            return .failure(.TooFewParameters)
        }
        let What = CTokens[0].lowercased()
        for Setting in SettingKeys.allCases
        {
            if Setting.rawValue.lowercased() == What
            {
                let SetOK = Settings.TryToSet(Setting, WithValue: CTokens[1])
                if !SetOK
                {
                    return .failure(.SetError)
                }
                return .success([])
            }
        }
        
        return .failure(.SettingNotFound)
    }
}
