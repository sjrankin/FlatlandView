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
}
