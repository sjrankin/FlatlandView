//
//  EditorProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol EditorProtocol
{
    var Delegate: RawSettingsProtocol? {get set}
    func AssignDelegate(_ DelegateProtocol: RawSettingsProtocol?)
    func LoadValue(_ Value: Any?, _ Type: String)
}
