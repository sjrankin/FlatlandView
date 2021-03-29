//
//  +NodeState.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/1/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Visual state description for `SCNNode2` states.
struct NodeState
{
    /// Node state.
    let State: NodeStates
    
    /// Diffuse color.
    let Color: NSColor
    
    /// Diffuse surface image. If nil, no image supplied.
    let Diffuse: NSImage?
    
    /// Emission color. If nil, `NSColor.clear` is applied to the emission contents.
    let Emission: NSColor?
    
    /// Specular color.
    let Specular: NSColor?
    
    /// Lighting model.
    let LightModel: SCNMaterial.LightingModel
    
    /// Metalness value. If nil, not used.
    let Metalness: Double?
    
    /// Roughness value. If nil, not used.
    let Roughness: Double?
    
    /// Casts shadow value. If nil, not used.
    let CastsShadow: Bool?
}

/// States for `SCNNode2` instances.
enum NodeStates: String
{
    /// Node is in the daylight.
    case Day = "Day"
    
    // Node is in the dark.
    case Night = "Night"
}
