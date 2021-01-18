//
//  CaptiveDialogPanelProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/18/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol CaptiveDialogPanelProtocol: class
{
    var ParentDelegate: CaptiveDialogManagementProtocol? {get set}
    var MainDelegate: MainProtocol? {get set}
    func WillClose(FromCaptive: Bool)
}
