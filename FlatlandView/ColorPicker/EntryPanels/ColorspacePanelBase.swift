//
//  ColorspacePanelBase.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ColorspacePanelBase
{
    /// Initializer.
    /// - Parameter: The controller for the colorspace panel.
    init(_ Controller: NSViewController?)
    {
        self.Controller = Controller
    }
    
    /// The controller for the given colorspace panel.
    public var Controller: NSViewController? = nil
    
    private var _ColorDelegate: NewColorProtocol? = nil
    var ColorDelegate: NewColorProtocol?
    {
        get
        {
            return _ColorDelegate
        }
        set
        {
            _ColorDelegate = newValue
        }
    }
}
