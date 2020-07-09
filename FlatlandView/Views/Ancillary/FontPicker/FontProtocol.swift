//
//  FontProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Protocol for using the font picker.
protocol FontProtocol: class
{
    /// Return the current font to display.
    func CurrentFont() -> StoredFont?
    
    /// Returns a flag that indicates the caller wants continuous updates.
    func WantsContinuousUpdates() -> Bool
    
    /// Called when the user makes changes if `WantsContinuousUpdates` is true.
    func NewFont(_ NewFont: StoredFont)
    
    /// Called when the user closes the font picker. If `OK` is true,
    /// `SelectedFont` contains the font as updated by the user.
    func Closed(_ OK: Bool, _ SelectedFont: StoredFont?)
}
