//
//  SettingChangedProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol SettingChangedProtocol: class
{
    /// The ID of the subscriber. This value should not change during the run-time
    /// of the program.
    /// - Returns: The ID of the subscriber.
    func SubscriberID() -> UUID
    
    /// Handle changed settings. Settings may be changed from anywhere at any time.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before the change.
    /// - Parameter NewValue: The new value of the setting.
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
}
