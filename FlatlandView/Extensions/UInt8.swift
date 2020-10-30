//
//  UInt8.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension UInt8
{
    /// Returns the layout size of a `UInt8` for an instance value.
    /// - Returns: Layout size of a `UInt8`.
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    /// Returns the layout size of a `UInt8` when used against the `UInt8` type.
    /// - Returns: Layout size of a `UInt8`.
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: UInt8(0))
    }
}
