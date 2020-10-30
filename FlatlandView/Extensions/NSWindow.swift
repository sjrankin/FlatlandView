//
//  NSWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension NSWindow
{
    var TitleBarHeight: CGFloat
    {
        get
        {
            let Height = contentRect(forFrameRect: frame).height
            return frame.height - Height
        }
    }
}
