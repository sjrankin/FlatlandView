//
//  ImageMergeParameters.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import simd

struct ImageMergeParameters
{
    let ImageCount: simd_uint1
    let XOffset: simd_uint1
    let YOffset: simd_uint1
    let TileWidth: simd_uint1
    let TileHeight: simd_uint1
    let BackgroundWidth: simd_uint1
    let BackgroundHeight: simd_uint1
}
