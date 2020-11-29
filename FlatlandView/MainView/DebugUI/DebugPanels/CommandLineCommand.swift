//
//  CommandLineCommand.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CommandLineCommand
{
    var RawCommandLine: String = ""
    var Command: String = ""
    var Syntax = [SyntaxTokens]()
    var Options = [String]()
    var Help = ""
    
    func CommandHelp() -> String
    {
        return ""
    }
    
    func CommandSummary() -> String
    {
        return ""
    }
    
    func IsValid(Tokenized: [String]) -> Bool
    {
        if Tokenized.count > 0
        {
            if Tokenized[0].caseInsensitiveCompare(Command) == .orderedSame
            {
                return true
            }
        }
        return false
    }
    
    func Execute(CommandLine: String) -> Result<Any, CommandLineResults>
    {
        if Command.isEmpty
        {
            return .failure(.EmptyCommand)
        }
        let Words = CommandLine.Words()
        if !IsValid(Tokenized: Words)
        {
            return .failure(.ParseFailure)
        }
        var Results = [String]()
        
        return .success(Results as Any)
    }
}

enum SyntaxTokens: String, CaseIterable
{
    case Command = "Command"
    case Option = "Option"
    case Operand = "Operand"
    case SetOperator = "SetOperator"
}
