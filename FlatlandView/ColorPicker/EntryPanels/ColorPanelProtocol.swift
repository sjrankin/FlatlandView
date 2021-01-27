//
//  ColorPanelProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/26/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ColorPanelProtocol: class
{
    var Parent: ColorPanelParentProtocol? {get set}
    func SetColor(_ Color: NSColor, From: ColorPanelTypes)
}
