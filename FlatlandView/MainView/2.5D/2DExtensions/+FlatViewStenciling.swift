//
//  +FlatViewStenciling.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension FlatView
{    
    /// Create an image with a radial grid for the flat view of the Earth.
    /// - Note: The image created and returned is much larger than the final 3D surface where it will be
    ///         displayed. This is intentional to decrease blurriness when rendered in 3D.
    /// - Returns: Mostly transparent image with grid lines drawn on it.
    func StencilGrid() -> NSImage
    {
        let Surface = NSImage.init(Color: NSColor.clear,
                                   Size: NSSize(width: FlatConstants.StencilRadius.rawValue * 2.0,
                                                height: FlatConstants.StencilRadius.rawValue * 2.0))
        Surface.lockFocus()
        if Settings.GetBool(.ShowWallClockSeparators)
        {
            let DashPattern: [CGFloat] =
                [
                    CGFloat(FlatConstants.LineDash0.rawValue),
                    CGFloat(FlatConstants.LineDash1.rawValue)
                ]
            let LineColor = Settings.GetColor(.WallClockGridLineColor, NSColor.Maroon)
            for Angle in stride(from: 0.0, to: 359.9, by: 15.0)
            {
                let FinalAngle = Angle + 7.5
                let X = FlatConstants.StencilRadius.rawValue * cos(FinalAngle.Radians)
                let Y = FlatConstants.StencilRadius.rawValue * sin(FinalAngle.Radians)
                let Line = NSBezierPath()
                LineColor.set()
                LineColor.setStroke()
                Line.lineWidth = CGFloat(FlatConstants.WallClockLineWidth.rawValue)
                Line.lineCapStyle = .round
                Line.setLineDash(DashPattern, count: DashPattern.count, phase: 0.0)
                Line.lineCapStyle = .round
                Line.move(to: NSPoint(x: FlatConstants.StencilRadius.rawValue,
                                      y: FlatConstants.StencilRadius.rawValue))
                Line.line(to: NSPoint(x: X + FlatConstants.StencilRadius.rawValue,
                                      y: Y + FlatConstants.StencilRadius.rawValue))
                Line.stroke()
                Line.fill()
            }
        }

        let LineColor = Settings.GetColor(.PrimaryGridLineColor, NSColor.black)
        for Angle in stride(from: 0.0, to: 359.9, by: 90.0)
        {
            let X = FlatConstants.StencilRadius.rawValue * cos(Angle.Radians)
            let Y = FlatConstants.StencilRadius.rawValue * sin(Angle.Radians)
            let Line = NSBezierPath()
            LineColor.set()
            LineColor.setStroke()
            Line.lineWidth = CGFloat(FlatConstants.GridLineWidth.rawValue)
            Line.lineCapStyle = .round
            Line.move(to: NSPoint(x: FlatConstants.StencilRadius.rawValue,
                                  y: FlatConstants.StencilRadius.rawValue))
            Line.line(to: NSPoint(x: X + FlatConstants.StencilRadius.rawValue,
                                  y: Y + FlatConstants.StencilRadius.rawValue))
            Line.stroke()
            Line.fill()
        }
        for Latitude in Latitudes.allCases
        {
            let Side = FlatConstants.StencilRadius.rawValue * 2.0 * Latitude.rawValue
            LineColor.set()
            LineColor.setStroke()
            let Container = NSRect(x: FlatConstants.StencilRadius.rawValue - Side / 2.0,
                                   y: FlatConstants.StencilRadius.rawValue - Side / 2.0,
                                   width: Side,
                                   height: Side)
            let Circle = NSBezierPath(ovalIn: Container)
            Circle.lineWidth = CGFloat(FlatConstants.GridLineWidth.rawValue)
            Circle.stroke()
        }
 
        Surface.unlockFocus()
        return Surface
    }
}
