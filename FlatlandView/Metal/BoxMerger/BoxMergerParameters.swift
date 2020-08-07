//
//  BoxMergerParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd

struct BoxMergeParameters
{
    let FillColor: simd_float4
    let X1: simd_uint1
    let Y1: simd_uint1
    let X2: simd_uint1
    let Y2: simd_uint1
}

struct ImageMergeParameters2
{
    let XOffset: simd_uint1
    let YOffset: simd_uint1
}
