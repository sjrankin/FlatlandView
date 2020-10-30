//
//  NSBezierPath.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/30/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

// MARK: - NSBezierPath extensions.

extension NSBezierPath
{
    //https://www.smashingmagazine.com/2017/10/from-ios-to-macos-development/
    public var cgPath: CGPath
    {
        let Path = CGMutablePath()
        var Points = [CGPoint](repeating: .zero, count: 3)
        for Index in 0 ..< self.elementCount
        {
            let SomeType = self.element(at: Index, associatedPoints: &Points)
            switch SomeType
            {
                case .moveTo:
                    Path.move(to: Points[0])
                    
                case .lineTo:
                    Path.addLine(to: Points[0])
                    
                case .curveTo:
                    Path.addCurve(to: Points[2], control1: Points[0], control2: Points[1])
                    
                case .closePath:
                    Path.closeSubpath()
                    
                @unknown default:
                    fatalError("Sneaky extra case value enountered: \(SomeType)")
            }
        }
        return Path
    }
}

