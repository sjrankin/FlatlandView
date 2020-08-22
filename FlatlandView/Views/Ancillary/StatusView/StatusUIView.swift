//
//  StatusUIView.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Small wrapper class around an `NSView` used to display status.
class StatusUIView: NSView
{
    /// Draw the background with a pretty gradient.
    /// - Parameter dirtyRect: Where to draw the gradient.
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        
        self.wantsLayer = true
        if let AllLayers = self.layer?.sublayers
        {
            for Layer in AllLayers
            {
                if Layer.name == "GradientBackground"
                {
                    Layer.removeFromSuperlayer()
                }
            }
        }
        let Layer = CAGradientLayer()
        Layer.name = "GradientBackground"
        Layer.frame = dirtyRect
        Layer.bounds = dirtyRect
        Layer.colors =
        [
            NSColor(calibratedRed: 35 / 255, green: 20 / 255, blue: 120 / 255, alpha: 1.0).cgColor,
            NSColor.black.cgColor
        ]
        Layer.locations =
        [
            NSNumber(value: 0.2),
            NSNumber(value: 1.0)
        ]
        self.layer?.addSublayer(Layer)
    }
}
