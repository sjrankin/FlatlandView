//
//  CGFloat.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/30/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

// MARK: - CGFloat extensions.

extension CGFloat
{
    /// Returns a rounded value of the instance CGFloat.
    /// - Note:
    ///     - This "rounding" is nothing more than truncation.
    /// - Parameter Count: Number of places to round to.
    /// - Returns: Rounded value.
    func RoundedTo(_ Count: Int) -> CGFloat
    {
        let Multiplier = pow(10.0, Count)
        let Value = Int(self * CGFloat(Double(truncating: Multiplier as NSNumber)))
        return CGFloat(Value) / CGFloat(Double(truncating: Multiplier as NSNumber))
    }
    
    /// Converts the instance value from (an assumed) degrees to radians.
    /// - Returns: Value converted to radians.
    func ToRadians() -> CGFloat
    {
        return self * CGFloat.pi / 180.0
    }
    
    /// Converts the instance value from (an assumed) radians to degrees.
    /// - Returns: Value converted to degrees.
    func ToDegrees() -> CGFloat
    {
        return self * 180.0 / CGFloat.pi
    }
    
    /// Converts the instance value from assumed degrees to radians.
    /// - Returns: Value converted to radians.
    var Radians: CGFloat
    {
        get
        {
            return ToRadians()
        }
    }
    
    /// Converts the instance value from assumed radians to degrees.
    /// - Returns: Value converted to degrees.
    var Degrees: CGFloat
    {
        get
        {
            return ToDegrees()
        }
    }
}
