//
//  PreferencePanelBase.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Preference panel table entry.
class PreferencePanelBase
{
    /// Initializer.
    /// - Parameter: The controller for the preference panel.
    init(_ Controller: NSViewController?)
    {
        self.Controller = Controller
    }
    
    /// The controller for the given preference panel.
    public var Controller: NSViewController? = nil
}
