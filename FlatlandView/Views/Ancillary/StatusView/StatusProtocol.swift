//
//  StatusProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol StatusProtocol: class
{
    func ResetUI()
    func SetUIBackground(To Color: NSColor)
    func ResetTextUI()
    func SetTextBackground(To Color: NSColor)
    func ShowText(_ TextString: String)
    func SetTextFont(_ Font: NSFont)
    func ShowSubText(_ SubText: String)
    func SetSubTextFont(_ Font: NSFont)
    func ResetSubTextUI()
    func DisplayIndicator(_ Indicator: Indicators)
    func HideIndicator()
    func ShowIndicator()
    func SetIndicatorPercent(_ Percent: Double)
}
