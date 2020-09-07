//
//  ImageBlendParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import simd


struct ImageBlendParameters
{
    let XOffset: simd_uint1
    let YOffset: simd_uint1
    let FinalAlphaPixelIs1: simd_bool
    let HorizontalWrap: simd_bool
    let VerticalWrap: simd_bool
}

