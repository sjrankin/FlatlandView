//
//  NSTextField2.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/18/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

@IBDesignable class NSTextField2: NSTextField
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    @IBInspectable var Rotation: CGFloat = 0.0
    {
        didSet
        {
            let Radians = Rotation.Radians
            layer?.transform = CATransform3DMakeRotation(Radians, 0.0, 0.0, 1.0)
        }
    }
}
