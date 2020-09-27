//
//  RawSettingsProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol RawSettingsProtocol: class
{
    func GetSettingName() -> String
    func GetSettingType() -> String
    func GetEnumCases() -> [String]
    func SetEnumValue(_ SettingKey: SettingKeys, _ AsString: String)
    func GetSettingValue() -> (Any?, String)?
    func SetDirty(_ Key: SettingKeys)
    func ClearDirty(_ Key: SettingKeys)
}
