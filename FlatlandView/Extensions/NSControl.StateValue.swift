//
//  NSControl.StateValue.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/27/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension NSControl.StateValue
{
    /// Converts the instance state to a `Bool` value.
    /// - Notes: Conversions are:
    ///   - `.off` returns `false`
    ///   - `.on` returns `true`
    ///   - `.mixed` returns `nil`
    /// - Returns: See notes.
    public func Boolean() -> Bool?
    {
        switch self
        {
            case .mixed:
                return nil
                
            case .on:
                return true
                
            case .off:
                return false
                
            default:
                return nil
        }
    }
    
    /// Converts the instance state to a `Bool` value.
    /// - Returns: If the instance is `.on`, `true` is returned. `false` is returned in all other cases.
    public func AsBoolean() -> Bool
    {
        if self == .on
        {
            return true
        }
        return false
    }
}
