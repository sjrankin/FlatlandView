//
//  ImageShiftParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd

struct ImageShiftParameters
{
    let XOffset: simd_int1
    let YOffset: simd_int1
    let ImageWidth: simd_uint1
    let ImageHeight: simd_uint1
}
