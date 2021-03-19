//
//  String.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/30/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

// MARK: - String extensions.

extension String
{
    /// Create a random string out of alphanumeric characters.
    /// - Note: See [Generate random alphanumeric string](https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift)
    /// - Parameter Count: Number of characters to return.
    /// - Returns: A string of `Count` characters consisting of randomly generated alphanumeric characters. If
    ///            `Count` is 0 or less, an empty string is returned.
    public static func Random(_ Count: Int) -> String
    {
        if Count <= 0
        {
            return ""
        }
        var Working = ""
        let Source = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        for _ in 0 ..< Count
        {
            let RandomIndex = Int.random(in: 0 ..< Source.count)
            let RandomIntoSource = Source.index(Source.startIndex, offsetBy: RandomIndex)
            Working.append(Source[RandomIntoSource])
        }
        return Working
    }
    
    /// Converts the passed Double value to a string and ensures it has
    /// a suffix of ".0".
    /// - Parameter Raw: The double value to convert.
    /// - Returns: The string equivalent of `Raw` with a trailing ".0" if the
    ///            conversion results in no trailing decimal.
    public static func WithTrailingZero(_ Raw: Double) -> String
    {
        let Converted = "\(Raw)"
        if Converted.hasSuffix(".0")
        {
            return Converted
        }
        if Raw == Double(Int(Raw))
        {
            return Converted + ".0"
        }
        return Converted
    }
    
    /// Returns a list of words in the instance.
    /// - Note: See [Three ways to enumerate the words in a string using swift](https://medium.com/@sorenlind/three-ways-to-enumerate-the-words-in-a-string-using-swift-7da5504f0062)
    /// - Returns: Array of words detected by `enumerateSubStrings`.
    func Words() -> [String]
    {
        let FullRange = self.startIndex ..< self.endIndex
        var WordList = [String]()
        self.enumerateSubstrings(in: FullRange, options: .byWords)
        {
            (substring, _, _, _) -> () in
            WordList.append(String(substring!))
        }
        
        return WordList
    }
    
    /// Used with regular expressions.
    /// - Note: [How to use regular expressions in Swift.](https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift)
    /// - Parameter lhs: Left hand side operand.
    /// - Parameter rhs: Right hand side.
    /// - Returns: True if `lhs` is in `rhs`. False otherwise.
    static func ~= (lhs: String, rhs: String) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: rhs) else
        {
            return false
        }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
    /// Determines if the instance strings contains only a given character.
    /// - Parameter SomeCharacter: The character to test. Defaults to a space character.
    /// - Returns: True if the instance string only contains `SomeCharacter`, false otherwise.
    func ContainsOnly(_ SomeCharacter: String = " ") -> Bool
    {
        for Char in self
        {
            if String(Char) != SomeCharacter
            {
                return false
            }
        }
        return true
    }
    
    /// Tokenize the instance string into words. Words are defined as substrings that are separated by
    /// characters in `Separators`. If `Quotations` has contents, they are used to determine quotations.
    /// - Parameter Separators: Array of separators that determines word boundaries. Ignored when inside
    ///                         a quotation. If this array is empty, the original string is returned
    ///                         unaltered.
    /// - Parameter Quotation: Determines if a substring is in a quoration. If
    ///                         empty, quotations are parses as if they are not quoted.
    /// - Returns: Array of words from the instance string. All empty strings are removed.
    func Tokenize(Separators: [String] = [" "], Quotation: String = "\"") -> [String]
    {
        if Separators.count < 1
        {
            return [self]
        }
        
        var Tokens = [String]()
        var InQuote = false
        var Word: String = ""
        for Character in self
        {
            if InQuote
            {
                if String(Character) == Quotation
                {
                    InQuote = false
                    if !Word.ContainsOnly(" ")
                    {
                        Tokens.append(Word)
                    }
                    Word = ""
                    continue
                }
                else
                {
                    Word.append(String(Character))
                    continue
                }
            }
            if String(Character) == Quotation
            {
                InQuote = true
                continue
            }
            if Separators.contains(String(Character))
            {
                if !Word.ContainsOnly(" ")
                {
                    Tokens.append(Word)
                }
                Word = ""
                continue
            }
            Word.append(String(Character))
        }
        Tokens.append(Word)
        
        Tokens.removeAll(where: {$0.count < 1})
        
        return Tokens
    }
    
    /// Tokenize the instance string into words or phrases.
    /// - Note: Quotations around phrases result in the phrase being treated as a word. Embedded quotations
    ///         are not supported.
    /// - Note: Words are defined by substrings surrounded by spaces. If two words look like this: word1"word2,
    ///         this function will treat them as a single word.
    /// - Returns: The contents of the instance string tokenized into words.
    func Tokenize2() -> [String]
    {
        let Raw = self
        let Parts = Raw.split(separator: " ", omittingEmptySubsequences: true)
        var Tokens = [String]()
        var InQuote = false
        var Phrase = ""
        for Part in Parts
        {
            let Word = String(Part)
            if InQuote
            {
                if Word.reversed().starts(with: "\"")
                {
                    Phrase.append(" \(Word)")
                    Tokens.append(Phrase)
                    Phrase = ""
                    InQuote = false
                }
                else
                {
                    Phrase.append(" \(Word)")
                }
            }
            else
            {
                if Word.starts(with: "\"")
                {
                    Phrase.append(Word)
                    InQuote = true
                }
                else
                {
                    Tokens.append(Word)
                }
            }
        }
        if !Phrase.isEmpty
        {
            Tokens.append(Phrase)
        }
        var working = [String]()
        for Token in Tokens
        {
            working.append(Token.replacingOccurrences(of: "\"", with: ""))
        }
        return working
    }
    
    /// Returns a sub-string of the passed string.
    /// - Parameter Raw: Original string.
    /// - Parameter Start: Starting index (0-based) of the sub-string.
    /// - Parameter End: Ending index (0-based) of the sub-string.
    /// - Returns: Sub-string from `Raw` in the specified range (inclusive).
    public static func SubString(_ Raw: String, Start: Int, End: Int) -> String
    {
        let AStart = Start - 1
        let AEnd = End - 1
        if AStart < 0 || AEnd < AStart
        {
            Debug.Print("AStart less than 0.")
            return ""
        }
        if AEnd > Raw.count - 1 || AStart > AEnd
        {
            Debug.Print("AEnd > count - 1.")
            return ""
        }
        let StartIndex = Raw.index(Raw.startIndex, offsetBy: AStart)
        let EndIndex = Raw.index(Raw.startIndex, offsetBy: AEnd)
        let Range = StartIndex ... EndIndex
        var Final = String(Raw[Range])
        Final = Final.trimmingCharacters(in: .whitespacesAndNewlines)
        return Final
    }
    
    /// Splits the string on a variety of separators. The first time a separator splits the string into
    /// more than one part is the separator that is used.
    /// - Parameter Separators: Array of strings that the function will use to split the string.
    /// - Parameter omittingEmptySubsequences: Passed to `String.split`.
    /// - Returns: Array of substrings based on the split string. Original string if no splitting occurs.
    public func Split(Separators: [String], omittingEmptySubsequences: Bool = false) -> [String.SubSequence]
    {
        for Separator in Separators
        {
            let Parts = self.split(separator: String.Element(Separator),
                                   omittingEmptySubsequences: omittingEmptySubsequences)
            if Parts.count > 1
            {
                return Parts
            }
        }
        return [String.SubSequence(self)]
    }
}
