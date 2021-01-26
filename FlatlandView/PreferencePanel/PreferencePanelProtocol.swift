//
//  PreferencePanelProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol PreferencePanelProtocol: class
{
    var Parent: PreferencePanelControllerProtocol? {get set}
    var MainDelegate: MainProtocol? {get set}
    func SetDarkMode(To: Bool)
    func SetHelpVisibility(To: Bool)
}
