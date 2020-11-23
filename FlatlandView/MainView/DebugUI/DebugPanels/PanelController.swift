//
//  PanelController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Base class for debugger panels.
class PanelController: NSViewController
{
    /// Delegate to the main class.
    public weak var Main: MainProtocol? = nil
}
