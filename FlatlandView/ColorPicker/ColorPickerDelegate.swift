//
//  ColorPickerDelegate.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ColorPickerDelegate: class
{
    func NewColor(_ Color: NSColor?)
}
