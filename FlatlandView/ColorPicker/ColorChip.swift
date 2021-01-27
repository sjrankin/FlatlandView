//
//  ColorChip.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Creates a code-only color chip that supports transparent colors.
class ColorChip: NSView, ColorPickerDelegate
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        InitializeUI()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeUI()
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        CheckLayer.frame = bounds
        ColorLayer.frame = bounds
    }
    
    func InitializeUI()
    {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.cornerRadius = 5.0
        layer?.borderWidth = 4.0
        layer?.borderColor = IsStatic ? NSColor.systemGray.cgColor : NSColor.black.cgColor
        CheckLayer = CATiledLayer()
        CheckLayer.frame = bounds
        CheckLayer.contents = NSImage(named: "SquareCheckerboard")
        CheckLayer.contentsGravity = .resizeAspectFill
        CheckLayer.magnificationFilter = .linear
        CheckLayer.zPosition = 0
        layer?.addSublayer(CheckLayer)
        ColorLayer = CALayer()
        ColorLayer.frame = bounds
        ColorLayer.backgroundColor = NSColor.white.cgColor
        ColorLayer.zPosition = 100
        layer?.addSublayer(ColorLayer)
    }
    
    var CheckLayer = CATiledLayer()
    var ColorLayer = CALayer()
    
    /// Holds the color to display as well as updating the control when new colors are set.
    private var _Color: NSColor = NSColor.white
    {
        didSet
        {
            UpdateColor(_Color)
        }
    }
    /// Get or set the color to display.
    public var Color: NSColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
        }
    }
    
    /// Holds the static flag.
    private var _IsStatic: Bool = true
    /// Determines whether the user can change the color by clicking on this control. If `true`, when the user
    /// clicks the control, the `ColorPicker` is instantiated to let the user change the color. If `false`,
    /// this control ignores mouse clicks.
    public var IsStatic: Bool
    {
        get
        {
            return _IsStatic
        }
        set
        {
             _IsStatic = newValue
        }
    }
    
    /// Updates the color of the display.
    private func UpdateColor(_ NewColor: NSColor)
    {
        ColorLayer.backgroundColor = NewColor.cgColor
    }
    
    /// Handle mouse down events.
    /// - Note: If `IsStatic` is false and the user clicks with the left mouse, the color picker will be run.
    override func mouseDown(with event: NSEvent)
    {
        if !IsStatic
        {
            let Storyboard = NSStoryboard(name: "ColorPicker", bundle: nil)
            if let WindowController = Storyboard.instantiateController(withIdentifier: "ColorPickerWindow") as? ColorPickerWindow
            {
                let Window = WindowController.window
                let Controller = Window?.contentViewController as? ColorPicker
                Controller?.Delegate = self
                WindowController.showWindow(nil)
                Controller?.SetSourceColor(_Color)
            }
        }
    }
    
    func NewColor(_ Color: NSColor?)
    {
    }
}
