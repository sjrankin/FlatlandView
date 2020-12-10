//
//  PreferencePanelProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol PreferencePanelControllerProtocol: class
{
    func ShowHelp(For: PreferenceHelp, Where: NSRect)
}
