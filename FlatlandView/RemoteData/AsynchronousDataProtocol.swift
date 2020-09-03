//
//  AsynchronousDataProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for the communication of the availability of remote/asynchronous data.
protocol AsynchronousDataProtocol: class
{
    /// Called when remote/asynchronous data is available.
    /// - Parameter CategoryType: The type of available data.
    /// - Parameter Actual: The data that was received. May be nil.
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?)
}

