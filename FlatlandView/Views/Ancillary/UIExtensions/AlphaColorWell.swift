//
//  AlphaColorWell.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

//https://stackoverflow.com/questions/15189074/add-opacity-slider-to-the-color-panel-for-one-color-well-but-not-others
class AlphaColorWell: NSColorWell
{
    override func activate(_ exclusive: Bool)
    {
        NSColorPanel.shared.showsAlpha = true
        super.activate(exclusive)
    }
    
    override func deactivate()
    {
        NSColorPanel.shared.showsAlpha = false
        super.deactivate()
    }
}
