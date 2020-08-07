//
//  LineDrawParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import simd

struct LineDrawParameters
{
    let IsHorizontal: simd_bool
    let HorizontalAt: simd_uint1
    let VerticalAt: simd_uint1
    let Thickness: simd_uint1
    let LineColor: simd_float4
}
