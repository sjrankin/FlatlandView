//
//  RoundTextIndicator.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Implements a round text view.
/// - Note: The view is really a flat 3D view.
@IBDesignable class RoundTextIndicator: SCNView
{
    /// Initializer.
    /// - Parameter frame: The frame to use for the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        InitializeView()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeView()
    }
    
    /// Initializer.
    /// - Parameter frame: The frame to use for the view.
    /// - Parameter options: Options for the view.
    override init(frame: CGRect, options: [String: Any]?)
    {
        super.init(frame: frame, options: options)
        InitializeView()
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Frame: The frame to use for the view.
    ///   - Text: The text to display.
    ///   - Radius: The radius of the circular path. Defaults to `5.0`.
    ///   - Offset: The rotational offset for each character. Defaults to `0.33`.
    ///   - Animate: If true, the text will be animated (eg, moving along the circumference of the circle
    ///              defined by `Radius`). Defaults to `true`.
    ///   - Duration: The number of seconds to move one radian. Defaults to `0.02`.
    convenience init(Frame: CGRect, Text: String, Radius: Double = 5.0, Offset: Double = 0.33,
                     Animate: Bool = true, Duration: Double = 0.02)
    {
        self.init(frame: Frame)
        _RotationalOffset = Offset
        _AnimationRadialDuration = Duration
        _DoAnimateText = Animate
        _RadiusValue = Radius
        InitializeView()
        ShowText(Text)
    }
    
    /// Initialize the view.
    func InitializeView()
    {
        self.scene = SCNScene()
        self.backgroundColor = NSColor.clear
        self.scene?.background.contents = NSColor.clear
        self.antialiasingMode = .multisampling2X
        self.autoenablesDefaultLighting = true
        self.allowsCameraControl = false
        let Camera = SCNCamera()
        Camera.fieldOfView = 100.0
        Camera.zFar = 10000.0
        Camera.zNear = 0.1
        let CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, _CameraZ)
        self.scene?.rootNode.addChildNode(CameraNode)
        self.showsStatistics = false
    }
    
    /// The last text displayed.
    var LastText: String = ""
    
    /// Get or set the text to display. If value retrieved before setting any other attribute, an empty
    /// string will be returned.
    @IBInspectable var DisplayText: String
    {
        get
        {
            return LastText
        }
        set
        {
            ShowText(newValue)
        }
    }
    
    /// Set the text to display.
    /// - Parameter Text: The text to display.
    public func ShowText(_ Text: String)
    {
        LastText = Text
        for ChildNode in PlaneNode.childNodes
        {
            ChildNode.removeAllActions()
            ChildNode.removeAllAnimations()
            ChildNode.removeFromParentNode()
            ChildNode.geometry = nil
        }
        Plane = SCNPlane(width: self.frame.width, height: self.frame.height)
        Plane.firstMaterial?.diffuse.contents = NSColor.clear
        PlaneNode = SCNNode(geometry: Plane)
        PlaneNode.position = SCNVector3(0.0, 0.0, 0.0)
        PlaneNode.eulerAngles = SCNVector3(0.0.Radians, 0.0.Radians, 0.0.Radians)
        var FontForText: NSFont = NSFont()
        if let TheFont = TextFont
        {
            FontForText = TheFont
        }
        else
        {
            FontForText = NSFont.boldSystemFont(ofSize: 40.0)
        }
        Letters = Utility.MakeFloatingWord2D(Radius: _RadiusValue,
                                             Word: Text,
                                             SpacingConstant: _Spacing,
                                             Latitude: 0.0,
                                             Longitude: _StartAt,
                                             Extrusion: CGFloat(_Extrusion),
                                             TextFont: FontForText,
                                             TextColor: _TextColor,
                                             TextSpecular: _SpecularColor,
                                             RotationalOffset: _RotationalOffset)
        self.scene?.rootNode.addChildNode(PlaneNode)
        Letters.eulerAngles = SCNVector3(-90.0.Radians, 00.0.Radians, 0.0.Radians)
        let XRotation = _BaseToCenter ? 90.0 : 270.0
        for Letter in Letters.childNodes
        {
            if let LetterNode = Letter as? SCNNode2
            {
                let AdjustedAngle = LetterNode.SourceAngle
                LetterNode.eulerAngles = SCNVector3(XRotation.Radians, AdjustedAngle.Radians, 0.0.Radians)
            }
        }
        PlaneNode.addChildNode(Letters)
        if _DoAnimateText
        {
            let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat(1.0.Radians * _RotationDirection),
                                            duration: _AnimationRadialDuration)
            let RotateForever = SCNAction.repeatForever(Rotate)
            PlaneNode.runAction(RotateForever)
        }
    }
    
    /// Holds the nodes for each letter displayed.
    var Letters = SCNNode2()
    
    /// Camera Z position.
    var _CameraZ: Double = 10.0
    
    /// Get or set the camera Z coordinate.
    @IBInspectable public var CameraZ: Double
    {
        get
        {
            return _CameraZ
        }
        set
        {
            _CameraZ = newValue
            ShowText(LastText)
        }
    }
    
    /// Set the background color.
    /// - Parameter To: The color to use for the background of the view.
    func SetBackground(To Color: NSColor)
    {
        self.scene?.background.contents = Color
    }
    
    /// Get or set the color of the text.
    @IBInspectable public var TextColor: NSColor
    {
        get
        {
            return _TextColor
        }
        set
        {
            SetTextColor(To: newValue)
        }
    }
    
    /// Set the color of the text.
    /// - Parameter To: The text color.
    func SetTextColor(To Color: NSColor)
    {
        _TextColor = Color
        for Node in Letters.childNodes
        {
            Node.geometry?.firstMaterial?.diffuse.contents = Color
        }
    }
    
    /// The color to use to draw the text.
    var _TextColor: NSColor = NSColor.black
    
    @IBInspectable public var SpecularColor: NSColor
    {
        get
        {
            return _SpecularColor
        }
        set
        {
            SetSpecularColor(To: newValue)
        }
    }
    
    func SetSpecularColor(To NewSpecular: NSColor)
    {
        _SpecularColor = NewSpecular
        ShowText(LastText)
    }
    
    private var _SpecularColor: NSColor = .white
    
    /// The plane shape where letters are added.
    var Plane = SCNPlane()
    
    /// The node for the plane.
    var PlaneNode = SCNNode()
    
    private var _Extrusion: Double = 3.5
    
    @IBInspectable public var Extrusion: Double
    {
        get
        {
            return _Extrusion
        }
        set
        {
            SetExtrusion(To: newValue)
        }
    }
    
    public func SetExtrusion(To Extrude: Double)
    {
        _Extrusion = Extrude
        ShowText(LastText)
    }
    
    /// Get or set the rotational offset for individual characters.
    @IBInspectable public var RotationOffset: Double
    {
        get
        {
            return _RotationalOffset
        }
        set
        {
            SetRotationalOffset(To: newValue)
        }
    }
    
    /// Set the rotational offset for individual characters. Different radii will require different
    /// offsets.
    /// - Parameter To: The rotational offset.
    public func SetRotationalOffset(To Offset: Double)
    {
        _RotationalOffset = Offset
        ShowText(LastText)
    }
    
    /// Holds the rotational offset.
    var _RotationalOffset: Double = 0.33
    
    /// Get or set the radius value of the circle where the text is drawn.
    @IBInspectable public var TextRadius: Double
    {
        get
        {
            return _RadiusValue
        }
        set
        {
            SetRadius(To: newValue)
        }
    }
    
    /// Sets the radius for the circle upon which the text is drawn.
    /// - Parameter To: The radial value.
    public func SetRadius(To RadialValue: Double)
    {
        _RadiusValue = RadialValue
        ShowText(LastText)
    }
    
    /// Holds the radius value.
    var _RadiusValue: Double = 5.0
    
    /// Get or set the animate text flag.
    @IBInspectable public var AnimateText: Bool
    {
        get
        {
            return _DoAnimateText
        }
        set
        {
            AnimateTextOnCircle(newValue)
        }
    }
    
    /// Set the animate text flag.
    public func AnimateTextOnCircle(_ DoAnimate: Bool)
    {
        _DoAnimateText = DoAnimate
        ShowText(LastText)
    }
    
    /// Holds the animate text flag.
    var _DoAnimateText: Bool = true
    
    /// Holds the animation duration (seconds/radian).
    var _AnimationRadialDuration: Double = 0.02
    
    /// Get or set the animation duration.
    @IBInspectable public var AnimationDuration: Double
    {
        get
        {
            return _AnimationRadialDuration
        }
        set
        {
            SetRadialDuration(To: newValue)
        }
    }
    
    /// Sets the duration (in seconds) for the animation of the text.
    /// - Parameter To: Seconds per radian for animation. Defaults to `0.02`.
    public func SetRadialDuration(To Duration: Double = 0.02)
    {
        _AnimationRadialDuration = Duration
        ShowText(LastText)
    }
    
    /// Holds the previously set font.
    var TextFont: NSFont? = nil
    
    /// Set the font to use to draw the text.
    /// - Parameter To: The font to use to draw the text. If nil, the system font will be used.
    public func SetFont(To Font: NSFont?)
    {
        TextFont = Font
        ShowText(LastText)
    }
    
    /// Determines the direction of rotation.
    var _RotationDirection: Double = 1.0
    
    /// Get or set the rotation direction. -1.0 is clockwise, 1.0 is counterclockwise.
    @IBInspectable public var RotateClockwise: Bool
    {
        get
        {
            return _RotationDirection == -1.0
        }
        set
        {
            SetRotationDirection(Clockwise: newValue)
        }
    }
    
    /// Set the rotation direction.
    /// - Parameter Clockwise: If true, the text rotates clockwise. Otherwise, counterclockwise.
    public func SetRotationDirection(Clockwise: Bool)
    {
        _RotationDirection = Clockwise ? -1.0 : 1.0
        ShowText(LastText)
    }
    
    var _BaseToCenter: Bool = true
    
    @IBInspectable public var BaseToCenter: Bool
    {
        get
        {
            return _BaseToCenter
        }
        set
        {
            BaseToCenter(newValue)
        }
    }
    
    public func BaseToCenter(_ BottomToCenter: Bool)
    {
        _BaseToCenter = BottomToCenter
        ShowText(LastText)
    }
    
    /// Holds the starting angle of the text.
    private var _StartAt: Double = 0.0
    
    /// Get or set the starting angle of the text.
    @IBInspectable public var StartAt: Double
    {
        get
        {
            return _StartAt
        }
        set
        {
            SetStart(To: newValue)
        }
    }
    
    /// Set the starting angle of the text.
    /// - Parameter To: The new starting angle.
    public func SetStart(To StartingAngle: Double)
    {
        _StartAt = StartingAngle
        ShowText(LastText)
    }
    
    /// The spacing value offset.
    private var _Spacing: Double = 20.0
    
    /// Get or set the character spacing value offset.
    @IBInspectable public var Spacing: Double
    {
        get
        {
            return _Spacing
        }
        set
        {
            SetStart(To: newValue)
        }
    }
    
    /// Set the spacing offset value to the passed value.
    /// - Parameter To: The new spacing offset value.
    public func SetSpacing(To SpacerValue: Double)
    {
        _Spacing = SpacerValue
        ShowText(LastText)
    }
    
    /// Show or hide 3D statistics view.
    public func ShowStatistics(_ Show: Bool)
    {
        self.showsStatistics = Show
    }
    
    /// Enable or disable camera control.
    public func AllowsCameraControl(_ Allow: Bool)
    {
        self.allowsCameraControl = Allow
    }
    
    /// Holds the showing flag.
    private var _IsShowing = true
    
    /// Get the showing flag.
    public var IsShowing: Bool
    {
        get
        {
            return _IsShowing
        }
    }
    
    /// Synchronization object for hiding and showing the control.
    var AppearanceSync: NSObject = NSObject()
    
    /// Hides the control over a period of 0.5 seconds.
    /// - Note: Once called, this function may not be called again until the control is fully hidden.
    /// - Note: Once called, `Show` will stall until this function exits.
    public func Hide()
    {
        objc_sync_enter(AppearanceSync)
        defer{objc_sync_exit(AppearanceSync)}
        if !IsShowing
        {
            return
        }
        let FadeAction = SCNAction.fadeOut(duration: 0.5)
        self.scene?.rootNode.runAction(FadeAction)
        {
            self.PlaneNode.removeAllActions()
            self.PlaneNode.removeAllAnimations()
            self.stop(self)
            self._IsShowing = false
        }
    }
    
    /// Shows the control over a period of 0.2 seconds.
    /// - Note: Once called, this function may not be called again until the control is fully shown.
    /// - Note: Once called, `Hide` will stall until this function exits.
    public func Show()
    {
        objc_sync_enter(AppearanceSync)
        defer{objc_sync_exit(AppearanceSync)}
        _IsShowing = true
        let FadeAction = SCNAction.fadeIn(duration: 0.2)
        ShowText(LastText)
        self.scene?.rootNode.runAction(FadeAction)
    }
}
