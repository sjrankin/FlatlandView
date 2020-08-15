//
//  StatusContainerController.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StatusContainerController: NSView
{
    /// Send the new bounds value to child views.
    override var bounds: NSRect
    {
        didSet
        {
            for Child in subviews
            {
                Child.bounds = bounds
            }
        }
    }
    
    /// Update each child's frame.
    override var frame: NSRect
    {
        didSet
        {
            for Child in subviews
            {
                let NewFrame = NSRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                Child.frame = NewFrame
            }
        }
    }
}
