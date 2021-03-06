//
//  AsynchronousDataProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for the communication of the availability of remote/asynchronous data.
protocol AsynchronousDataProtocol: AnyObject
{
    /// Called when remote/asynchronous data is available.
    /// - Parameter CategoryType: The type of available data.
    /// - Parameter Actual: The data that was received. May be nil.
    /// - Parameter StartTime: The time the asynchronous process started.
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?, StartTime: Double)
}

