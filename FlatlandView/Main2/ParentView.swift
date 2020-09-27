//
//  ParentView.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ParentView: NSView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        CommonInitialization()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    func CommonInitialization()
    {
        self.postsFrameChangedNotifications = true
    }
}
