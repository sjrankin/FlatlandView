//
//  CommandLinePanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CommandLinePanel: NSViewController, NSTextFieldDelegate, NSTextViewDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextBox.isRichText = true
        TextBox.backgroundColor = NSColor.black
        TextBox.textColor = NSColor.yellow
        TextBox.font = NSFont.monospacedDigitSystemFont(ofSize: 16.0, weight: .medium)
        TextBox.insertionPointColor = NSColor.green
        TextBox.string.append("Flatland Command Prompt\n>")
        BlockedText = TextBox.string.count
        StartIndex = BlockedText
        TextBox.becomeFirstResponder()
    }
    
    var StartIndex: Int = 0
    var BlockedText: Int = 0
    
    func textViewDidChangeSelection(_ notification: Notification)
    {
        guard let TextView = notification.object as? NSTextView else
        {
            return
        }
        if let Index = TextView.selectedRanges.first?.rangeValue.location
        {
            CurrentCursorIndex = Index
        }
    }
    
    //https://stackoverflow.com/questions/33078314/how-to-prevent-user-not-to-remove-particular-character-in-uitextfield
    func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue],
                  replacementStrings: [String]?) -> Bool
    {
        if affectedRanges.count != 1
        {
            return false
        }
        if let Range = affectedRanges[0] as? NSRange
        {
            if Range.location == 0 && (Range.length == 0 || Range.length == 1)
            {
                return false
            }
            if Range.location < BlockedText && (Range.length == 0 || Range.length == 1)
            {
                return false
            }
        }
        return true
    }
    
    var CurrentCursorIndex: Int = -1
    
    func textDidChange(_ notification: Notification)
    {
        guard let TextControl = notification.object as? NSTextView else
        {
            return
        }
        let New = TextControl.string
        if let Last = TextControl.string.last
        {
            if Last == "\n"
            {
                if TextControl.string.count == BlockedText + 1
                {
                    TextControl.string.append(">")
                    BlockedText = TextControl.string.count
                    StartIndex = BlockedText
                    return
                }
            }
        }
        let (Added, Removed) = GetDelta(Previous: Previous, New: New)
        Previous = New
        if Added == "\n"
        {
            GetCommandLine()
            TextControl.string.append(">")
            BlockedText = TextControl.string.count
            StartIndex = BlockedText
        }
    }
    
    var Previous = ""
    
    func GetCommandLine()
    {
        let Raw = TextBox.string
        let RawStart = Raw.index(Raw.startIndex, offsetBy: StartIndex)
        let RawEnd = Raw.index(RawStart, offsetBy: Raw.count - StartIndex)
        StartIndex = Raw.count
        let Line = String(Raw[RawStart ..< RawEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        let Words = Line.Words()
        HandleCommand(Words)
    }
    
    func HandleCommand(_ Tokens: [String])
    {
        if Tokens.count < 1
        {
            return
        }
        let Command = Tokens[0].lowercased()
        switch Command
        {
            case "ver":
                Print(Versioning.MakeSimpleVersionString())
                
            case "show":
                if Tokens.count < 2
                {
                    Print("Show what? Need operand.")
                    return
                }
                RunShow(Tokens)
                
            case "find":
                if Tokens.count < 2
                {
                    Print("Find what? Need operand.")
                    return
                }
                RunFind(Tokens)
                
            case "set":
                if Tokens.count < 3
                {
                    Print("Set command is in the form: set setting value")
                    return
                }
                RunSet(Tokens)
                
            case "help":
                if Tokens.count < 2
                {
                    Print("Type \"help command\" to see help on a given command.")
                    Print("Commands:")
                    Print("show: Show the value of the object.")
                    Print("ver: Show the version and build.")
                    Print("set: Set the value of a setting.")
                    Print("find: Find an enum or setting.")
                    return
                }
                RunShowHelp(Tokens)
                
            default:
                Print("Unrecognized command: \"\(Tokens[0])\"")
        }
    }
    
    func RunShowHelp(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let HelpFor = Tokens[1].lowercased()
        switch HelpFor
        {
            case "show":
                Print("Show the value of an object. Form is: show class object where class is enum and object is the name. You can also use show setting name to get the name, value and type of a setting.")
                
            case "ver":
                Print("Shows the version and build of Flatland.")
                
            case "set":
                Print("Sets the value of a setting. Form is: set setting name setting value")
                
            case "find":
                Print("Finds information and prints it. Form is: find something where something is what you want to find.")
                
            default:
                Print("No help for \"\(Tokens[1])\"")
        }
    }
    
    func RunFind(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let SearchFor = Tokens[1]
        
    }
    
    func RunSet(_ Tokens: [String])
    {
        if Tokens.count < 3
        {
            return
        }
        let What = Tokens[1].lowercased()
            for Setting in SettingKeys.allCases
            {
                if Setting.rawValue.lowercased() == What
                {
                    let SetOK = Settings.TryToSet(Setting, WithValue: Tokens[2])
                    if !SetOK
                    {
                        Print("Error setting \(Setting.rawValue) to \(Tokens[2])")
                    }
                }
            }
    }
    
    func RunShow(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let What = Tokens[1].lowercased()
        if What == "enum"
        {
            if Tokens.count < 3
            {
                Print("Please specify an enum name. Use \"show enum list\" to list all enums.")
                return
            }
            ShowEnum(Tokens[2])
            return
        }
        for Setting in SettingKeys.allCases
        {
            if Setting.rawValue.lowercased() == What
            {
                if let (SettingName, SettingValue, SettingType) = Settings.Query(Setting)
                {
                    let Result = "\(SettingName): \(SettingType) = \(SettingValue)"
                    Print(Result)
                }
                else
                {
                    Print("Error retrieving setting information.")
                }
            }
        }
    }
    
    func ShowEnum(_ EnumName: String)
    {
        if EnumName.lowercased() == "list"
        {
            var EnumNames = [String]()
            EnumNames = EnumList.Enums.keys.map{"\($0)"}
            EnumNames.sort()
            var AllEnums = ""
            for EnumName in EnumNames
            {
                AllEnums.append(EnumName)
                if EnumName != EnumNames.last
                {
                    AllEnums.append("\n")
                }
            }
            Print(AllEnums)
            return
        }
        if let EnumCases = EnumList.Enums[EnumName]
        {
            var Cases = "\(EnumName):\n"
            for SomeCase in EnumCases
            {
                Cases.append(" \(SomeCase)")
                if SomeCase != EnumCases.last
                {
                    Cases.append("\n")
                }
            }
            Print(Cases)
            return
        }
        Print("Unknown enum name \"\(EnumName)\". Enum names are case sensitive. Use \"show enum list\" to see all enums.")
    }
    
    func GetDelta(Previous: String, New: String) -> (Added: String, Removed: String)
    {
        let PrevArray = Array(Previous)
        let NewArray = Array(New)
        let Deltas = NewArray.difference(from: PrevArray)
        var Accumulated = ""
        var Stripped = ""
        for SomeChange in Deltas.insertions
        {
            switch SomeChange
            {
                case .insert(_, let Element, _):
                    Accumulated.append(String(Element))
                    
                default:
                    continue
            }
        }
        for SomeChange in Deltas.removals
        {
            switch SomeChange
            {
                case .remove(_, let Element, _):
                    Stripped.append(String(Element))
                    
                default:
                    continue
            }
        }
        return (Accumulated, Stripped)
    }
    
    func Print(_ Text: String)
    {
        TextBox.string.append("\(Text)\n")
        BlockedText = TextBox.string.count
        StartIndex = BlockedText
    }
    
    @IBOutlet var TextBox: NSTextView!
}
