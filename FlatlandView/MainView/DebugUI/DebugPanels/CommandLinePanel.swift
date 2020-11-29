//
//  CommandLinePanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CommandLinePanel: PanelController, CommandLineProtocol, NSTextFieldDelegate, NSTextViewDelegate
{
    /// Initialize the UI.
    /// - Note: [NSTextView with smart quotes disabled still replaces quotes](https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextBox.isRichText = false
        TextBox.isAutomaticLinkDetectionEnabled = false
        TextBox.isFieldEditor = false
        TextBox.isAutomaticDashSubstitutionEnabled = false
        TextBox.isAutomaticQuoteSubstitutionEnabled = false
        TextBox.backgroundColor = NSColor.black
        TextBox.textColor = NSColor.yellow
        TextBox.font = NSFont.monospacedDigitSystemFont(ofSize: 16.0, weight: .medium)
        TextBox.insertionPointColor = NSColor.green
        TextBox.string.append("Flatland Command Prompt\n>")
        BlockedText = TextBox.string.count
        StartIndex = BlockedText
        TextBox.becomeFirstResponder()
        CreateCommands()
    }
    
    func CreateCommands()
    {
        Commands.append(TodayCommand(Main, self))
        Commands.append(ProgramCommand(Main, self))
        Commands.append(FindCommand(Main, self))
        Commands.append(InjectCommand(Main, self))
        Commands.append(ClearCommand(Main, self))
        Commands.append(SetCommand(Main, self))
        Commands.append(ShowCommand(Main, self))
        Commands.append(StatusCommand(Main, self))
        //Should always be last.
        let Help = HelpCommand(Main, self)
        Commands.append(Help)
        Help.SetOtherCommands(Commands)
    }
    
    var Commands = [CommandProtocol]()
    
    func RunCommand(_ Raw: String)
    {
        let Parsed = Raw.Tokenize2()
        if Parsed.count < 1
        {
            return
        }
        for SomeCommand in Commands
        {
            if SomeCommand.IsValidCommand(Parsed[0])
            {
                let Results = SomeCommand.Execute(Parsed)
                switch Results
                {
                    case .success(let OutputLines):
                        let Output = OutputLines as! [String]
                        for Line in Output
                        {
                            Print(Line)
                        }
                        
                    case .failure(let Error):
                        if Error == .LateResults
                        {
                            return
                        }
                        Print("Command error: \(Error.rawValue)")
                }
                return
            }
        }
        Print("Command \"\(Parsed[0])\" not found.")
    }
    
    /// Handle late results.
    /// - Parameter Results: The results from a slow command.
    func LateResults(_ Results: [String])
    {
        for Line in Results
        {
            Print(Line)
        }
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
        let (Added, _) = GetDelta(Previous: Previous, New: New)
        Previous = New
        if Added == "\n"
        {
            let CommandText = GetRawCommandLine()
            RunCommand(CommandText)
            TextControl.string.append(">")
            BlockedText = TextControl.string.count
            StartIndex = BlockedText
        }
    }
    
    var Previous = ""
    
    func GetRawCommandLine() -> String
    {
        let Raw = TextBox.string
        let RawStart = Raw.index(Raw.startIndex, offsetBy: StartIndex)
        let RawEnd = Raw.index(RawStart, offsetBy: Raw.count - StartIndex)
        StartIndex = Raw.count
        let Line = String(Raw[RawStart ..< RawEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        return Line
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



