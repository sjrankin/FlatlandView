//
//  Timer.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/1/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Timer
{
    /// Start a timer that executes every `withTimerInterval` seconds.
    /// - Note: This timer always repeats.
    /// - Parameter withTimerInterval: Number of seconds between execution of the passed closure.
    /// - Parameter RunFirst: If true, `block` is executed before the timer is started. If false,
    ///                       `block` is not executed until the appropriate amount of time has passed.
    /// - Parameter block: Closure to execute.
    /// - Returns: The timer running the scheduled execution.
    public static func StartRepeating(withTimerInterval interval: Double, RunFirst: Bool,
               block: @escaping (Timer?) -> Void) -> Timer
    {
        if RunFirst
        {
            block(nil)
        }
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: block)
    }
}
