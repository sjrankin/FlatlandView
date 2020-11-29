//
//  +Status.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StatusCommand: CommandProtocol
{
    var Main: MainProtocol? = nil
    var Parent: CommandLineProtocol? = nil
    
    init()
    {
        _CommandName = "Status"
    }
    
    init(_ Main: MainProtocol?, _ Parent: CommandLineProtocol?)
    {
        _CommandName = "Status"
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
        Help.append("Status command summary:")
        Help.append("Program text: Displays the text in the status region.")
        return Help
    }
    
    func CommandSummary() -> String
    {
        return "Displays text in the status region."
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
        if CTokens.count == 0
        {
            Main?.ClearStatusText()
            return .success([])
        }
        
        if CTokens.count == 1
        {
            if CTokens[0].lowercased() == "help"
            {
                return .success(CommandHelp())
            }
        }

        var TextToDisplay = ""
        for Index in 1 ..< Tokens.count
        {
            TextToDisplay.append(Tokens[Index])
            TextToDisplay.append(" ")
        }
        TextToDisplay = TextToDisplay.trimmingCharacters(in: .whitespaces)
        Main?.SetDisappearingStatusText(TextToDisplay, HideAfter: 25.0)
        
        return .success([])
    }
}
