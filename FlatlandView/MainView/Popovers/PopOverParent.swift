//
//  PopOverParent.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol PopOverParent: AnyObject
{
    func EditHome()
    func EditUserPOI(_ ID: UUID)
}
