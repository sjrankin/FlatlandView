//
//  SolidColorParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd

struct SolidColorParameters
{
    let DrawBorder: simd_bool
    let BorderThickness: simd_uint1
    let BorderColor: simd_float4
    let Fill: simd_float4
}
