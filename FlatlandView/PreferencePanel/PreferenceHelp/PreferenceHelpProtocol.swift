//
//  PreferenceHelpProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for communicating with the preference help display.
protocol PreferenceHelpProtocol: AnyObject
{
    /// Display the passed help text.
    func SetHelpText(_ Text: String)
}
