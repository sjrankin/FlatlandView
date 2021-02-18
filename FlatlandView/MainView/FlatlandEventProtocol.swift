//
//  FlatlandEventProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol FlatlandEventProtocol: AnyObject
{
    func NewWorldClockTime(WorldDate: Date)
    func MouseClickedAt(Point: CGPoint)
}
