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
@IBDesignable class ColorChip: NSView, ColorPickerDelegate
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
        CornerRadius = _CornerRadius
        BorderWidth = _BorderWidth
    }
    
    func InitializeUI()
    {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.borderColor = IsStatic ? NSColor.systemGray.cgColor : NSColor.black.cgColor
        CheckLayer = CATiledLayer()
        CheckLayer.frame = bounds
        if let BGImage = GetBackgroundPattern()
        {
            CheckLayer.contents = BGImage
        }
        else
        {
            CheckLayer.contents = NSImage(named: "SquareCheckerboard")
        }
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
    
    /// Holds the corner radius of the color chip.
    private var _CornerRadius: CGFloat = 5.0
    {
        didSet
        {
            layer?.cornerRadius = _CornerRadius
        }
    }
    /// Get or set the corner radius of the color chip.
    @IBInspectable var CornerRadius: CGFloat
    {
        get
        {
            return _CornerRadius
        }
        set
        {
            _CornerRadius = newValue
        }
    }
    
    /// Holds the border width or the color chip.
    private var _BorderWidth: CGFloat = 4.0
    {
        didSet
        {
            layer?.borderWidth = _BorderWidth
        }
    }
    /// Get or set the border width of the color chip.
    @IBInspectable var BorderWidth: CGFloat
    {
        get
        {
            return _BorderWidth
        }
        set
        {
            _BorderWidth = newValue
        }
    }
    
    /// Get the image to use for the background of the color chip.
    /// - Returns: Image to use for the background. If nil, the image could not be found/loaded.
    func GetBackgroundPattern() -> NSImage?
    {
        let ImageName = AlternateBackgroundImageName ?? "SquareCheckerboard"
        return NSImage(named: ImageName)
    }
    
    /// Holds the alternative background image name. If nil, the standard image will be used.
    private var _AlternateBackgroundImageName: String? = nil
    {
        didSet
        {
            if let BGImage = _AlternateBackgroundImageName
            {
                CheckLayer.contents = BGImage
            }
            else
            {
                CheckLayer.contents = NSImage(named: "SquareCheckerboard")
            }
        }
    }
    /// Get or set the name of the image to use for the background of the color chip. This will be visible
    /// when the color has a alpha level of less than 1.0.
    @IBInspectable var AlternateBackgroundImageName: String?
    {
        get
        {
            return _AlternateBackgroundImageName
        }
        set
        {
            _AlternateBackgroundImageName = newValue
        }
    }
    
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
    
    private var _CallerTitle: String? = nil
    public var CallerTitle: String?
    {
        get
        {
            return _CallerTitle
        }
        set
        {
            _CallerTitle = newValue
        }
    }
    
    /// Holds the static flag.
    private var _IsStatic: Bool = true
    /// Determines whether the user can change the color by clicking on this control. If `true`, when the user
    /// clicks the control, the `ColorPicker` is instantiated to let the user change the color. If `false`,
    /// this control ignores mouse clicks.
    @IBInspectable public var IsStatic: Bool
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
                if let CallerTitleValue = CallerTitle
                {
                    Controller?.CallerTitle = CallerTitleValue
                }
            }
        }
    }
    
    func NewColor(_ Color: NSColor?)
    {
    }
}
