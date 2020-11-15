//
//  NSRegularExpression.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

//https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension NSRegularExpression
{
    convenience init?(_ Pattern: String)
    {
        do
        {
            try self.init(pattern: Pattern)
        }
        catch
        {
            return nil
        }
    }
    
    func Matches(_ Test: String) -> Bool
    {
        let range = NSRange(location: 0, length: Test.utf16.count)
        return firstMatch(in: Test, options: [], range: range) != nil
    }
}
