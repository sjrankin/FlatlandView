//
//  StatusTextLayer.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Class that is mostly a standard `CATextLayer` but vertically centers text.
class StatusTextLayer: CATextLayer
{
    /// Initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameter layer: Some layer.
    override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Draws the text centered in the current frame.
    /// - Parameter in: The context in which the text will be drawn.
    override open func draw(in ctx: CGContext)
    {
        var YDiff: CGFloat = 0.0
        var FontSize: CGFloat = 0.0
        let Height = self.bounds.height
        if let AttrString = self.string as? NSAttributedString
        {
            FontSize = AttrString.size().height
            YDiff = (Height - FontSize) / 2
        }
        else
        {
            FontSize = self.fontSize
            YDiff = ((Height - FontSize) / 2) - (FontSize / 10)
        }
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: -YDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
