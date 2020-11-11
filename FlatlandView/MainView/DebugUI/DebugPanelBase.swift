//
//  DebugPanelBase.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Debug panel table entry.
class DebugPanelBase
{
    /// Initializer.
    /// - Parameter: The controller for the debug panel.
    init(_ Controller: NSViewController?)
    {
        self.Controller = Controller
    }
    
    /// The controller for the given debug panel.
    public var Controller: NSViewController? = nil
}
