//
//  ColorPanelParentProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/26/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ColorPanelParentProtocol: AnyObject
{
    func NewColorFromPanel(_ Color: NSColor, From: ColorPanelTypes)
}
