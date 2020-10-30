//
//  Dictionary.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Dictionary extension methods.
extension Dictionary where Value: Equatable
{
    /// Return all keys whose value is `Value`.
    /// - Parameter Value: The value used to search the instance dictionary.
    /// - Returns: Array of keys that have the passed value. May be empty if no values are found.
    func KeyFor(Value SearchValue: Value) -> [Key]
    {
        return self.filter{$1 == SearchValue}.map{$0.0}
    }
}
