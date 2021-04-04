//
//  CommandProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol CommandProtocol: AnyObject
{
    func SetMainDelegate(_ Main: MainProtocol?)
    func IsValidCommand(_ Token: String) -> Bool
    func CommandName() -> String
    func AlternativeName() -> String?
    func CommandHelp() -> [String]
    func CommandSummary() -> String
    func Execute(_ Tokens: [String]) -> Result<Any, CommandLineResults>
    func ExecuteIfCommand(_ Tokens: [String]) -> Result<Any, CommandLineResults>
    func SetOtherCommands(_ Others: [CommandProtocol])
}

/// Command line results.
enum CommandLineResults: String, CaseIterable, Error
{
    /// Command line executed successfully.
    case Success = "Success"
    /// Command line failed.
    case Error = "Error"
    /// Parse error for command line.
    case ParseFailure = "Parse failure"
    /// Command line was unexpectedly empty.
    case EmptyCommand = "Empty command"
    /// Wrong command sent to command line processor.
    case WrongCommand = "Wrong command"
    /// Bad date specified.
    case BadDate = "Bad date"
    /// Not enough parameters for a command.
    case TooFewParameters = "Not enough parameters"
    /// Too many parameters.
    case TooManyParameters = "Too many parameters"
    /// Cannot find the requested command.
    case CannotFindCommand = "Cannot find command"
    /// No placename specified in Find command.
    case NoPlacename = "No placename specified"
    /// No enum case specified specified.
    case NoEnumCase = "No enum case specified"
    /// Nothing to find.
    case NothingToFind = "Nothing to find"
    /// Could not find placename.
    case PlacenameNotFound = "Placename not found"
    /// Command not implemented.
    case NotImplemented = "Command not implemented"
    /// Coordinates not formed correctly.
    case BadCoordinates = "Bad geographical coordinates"
    /// Unable to retrieve earthquake controller.
    case NoQuakeController = "Cannot get earthquake controller"
    /// Unrecognized command parameter.
    case UnknownCommandParameter = "Unrecognized command parameter"
    /// Error when attempting to set a setting.
    case SetError = "Error assigning value to setting"
    /// Cannot find specified setting.
    case SettingNotFound = "Setting not found"
    /// Command requires operand not specified by user.
    case MissingOperand = "Missing operand for command"
    /// Unknown enum specified.
    case EnumNotFound = "Enum name not found"
    /// The user has not set the home location.
    case HomeLocationNotSet = "Home location not set"
    /// Used to indicate to the command line that results will be
    /// delayed.
    case LateResults = "LateResults"
    /// Used when there is an error retrieving setting information.
    case ErrorGettingSettingInformation = "Error retrieving setting information."
}
