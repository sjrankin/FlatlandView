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
    
    //https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
    static func ~= (lhs: String, rhs: String) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: rhs) else
        {
            return false
        }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}
