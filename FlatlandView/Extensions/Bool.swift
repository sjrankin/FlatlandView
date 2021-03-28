//
//  Bool.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/27/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Bool
{
    /// Converts the current value into an `NSControl.StateValue`. Mixed states are not returned.
    /// - Returns: `.on` if the instance is `true`, `.off` if the instance is `false`.
    public func State() -> NSControl.StateValue
    {
        return self ? .on : .off
    }
}
