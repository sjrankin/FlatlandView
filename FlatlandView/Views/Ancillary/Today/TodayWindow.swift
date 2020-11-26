//
//  TodayWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class TodayWindow: NSWindowController
{
    func SetLocationSegment(_ To: Int)
    {
        if To < 0 || To > 1
        {
            return
        }
        LocationSegment.selectedSegment = To
    }
    
    @IBOutlet weak var LocationSegment: NSSegmentedControl!
}
