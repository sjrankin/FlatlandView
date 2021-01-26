//
//  PanelSetupProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol PanelSetupProtocol: class
{
    func InitialColor(_ Color: NSColor, InputType: InputTypes, Receiver: NewColorProtocol)
    func UpdateInputType(_ NewInputType: InputTypes)
    func SetColor(_ Color: NSColor)
}

