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
    func SubscriberID() -> UUID
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
}
