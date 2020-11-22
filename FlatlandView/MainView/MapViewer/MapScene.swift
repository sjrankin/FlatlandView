//
//  MapScene.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class MapScene: SCNScene
{
    override init()
    {
        super.init()
        Initialize()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    func Initialize()
    {
        
    }
}
