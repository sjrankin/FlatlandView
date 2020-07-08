//
//  FontProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol FontProtocol: class
{
    func CurrentFont() -> StoredFont
    func WantsContinuousUpdates() -> Bool
    func NewFont(_ NewFont: StoredFont)
    func Closed(_ OK: Bool, _ SelectedFont: StoredFont?)
}
