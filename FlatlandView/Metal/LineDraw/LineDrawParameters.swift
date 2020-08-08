//
//  LineDrawParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd

struct LineDrawParameters
{
    let IsHorizontal: simd_bool
    let HorizontalAt: simd_uint1
    let VerticalAt: simd_uint1
    let Thickness: simd_uint1
    let LineColor: simd_float4
}

struct LineArray
{
    let Count: simd_uint1
    let Lines: [LineDrawParameters]
}
