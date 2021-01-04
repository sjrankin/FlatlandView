//
//  EnumColors.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/2/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation

/// Standard colors for 3D scenes.
enum Colors3D: Int, CaseIterable 
{
    /// Required to keep the compiler happy.
    typealias RawValue = Int
    
    /// Color of the floating hours.
    case HourColor = 0xff7518
    
    /// Color of glowing hours.
    case GlowingHourColor = 0xa00000
    
    /// Specular color for floating hours.
    case HourSpecular = 0xffffff
    
    /// Color for specular surface contents in general.
    case GeneralSpecular = 0xfffffe
}
