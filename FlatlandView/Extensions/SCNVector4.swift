//
//  SCNVector4.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension SCNVector4
{
    public func RoundedTo(_ Places: Int) -> String
    {
        let X = "\(self.x.RoundedTo(3))"
        let Y = "\(self.y.RoundedTo(3))"
        let Z = "\(self.z.RoundedTo(3))"
        let W = "\(self.w.RoundedTo(3))"
        return "(x: \(X), y: \(Y), z: \(Z), w: \(W))"
    }
}
