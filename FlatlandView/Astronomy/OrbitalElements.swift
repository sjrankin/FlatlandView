//
//  OrbitalElements.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class OrbitalElements
{
}

class OrbitalElement
{
    init(_ Name: String, _ a: Double, _ e: Double, _ I: Double, _ L: Double, _ w: Double,
         _ node: Double, _ aCy: Double, _ eCy: Double, _ ICy: Double, _ LCy: Double,
         _ wCy: Double, _ NodeCy: Double)
    {
        self.Name = Name
        self.a = a
        self.e = e
        self.I = I
        self.L = L
        self.w = w
        self.node = node
        self.aCy = aCy
        self.eCy = eCy
        self.ICy = ICy
        self.LCy = LCy
        self.wCy = wCy
        self.NodeCy = NodeCy
    }
    
    var Name: String = ""
    var a: Double = 0.0
    var e: Double = 0.0
    var I: Double = 0.0
    var L: Double = 0.0
    var w: Double = 0.0
    var node: Double = 0.0
    var aCy: Double = 0.0
    var eCy: Double = 0.0
    var ICy: Double = 0.0
    var LCy: Double = 0.0
    var wCy: Double = 0.0
    var NodeCy: Double = 0.0
}
