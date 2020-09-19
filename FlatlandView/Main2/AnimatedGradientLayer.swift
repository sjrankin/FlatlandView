//
//  AnimatedGradientLayer.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Class that implements an animated color gradient in a `CAGradientLayer`.
class AnimatedGradientLayer: CAGradientLayer
{
    /// Initializer.
    override init()
    {
        super.init()
        self.type = .axial
    }
    
    /// Initializer.
    /// - Parameter layer: Other `CALayer` whose parameters are copied.
    override init(layer: Any)
    {
        super.init(layer: layer)
        self.type = .axial
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.type = .axial
    }
    
    /// Initializer.
    /// - Parameter LayerSize: The size of the layer.
    /// - Parameter IsHorizontal: Determines the orientation of the layer.
    /// - Parameter Stops: Array of color stops.
    init(LayerSize: CGSize, IsHorizontal: Bool, Stops: [ColorStopProtocol])
    {
        super.init()
        InternalInitialization(Size: LayerSize, Horizontal: IsHorizontal, Stops: Stops)
    }
    
    /// Set internal state from the passed parameters.
    /// - Parameter Size: The size of the layer.
    /// - Parameter Horizontal: Determines the orientation of the layer.
    /// - parameter Stops: Array of color stops.
    private func InternalInitialization(Size: CGSize, Horizontal: Bool, Stops: [ColorStopProtocol])
    {
        self.drawsAsynchronously = true
        self.type = .axial
        CurrentSize = Size
        if Horizontal
        {
            self.startPoint = CGPoint(x: 0, y: 0.5)
            self.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        else
        {
            self.startPoint = CGPoint(x: 0.5, y: 0)
            self.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        SetColorStops(Stops)
    }
    
    /// Setups up the gradient to be visible. If dynamic color stops are available, they are started here.
    func StartGradient()
    {
        self.frame = CGRect(origin: CGPoint.zero, size: CurrentSize)
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateGradient),
                                     userInfo: nil, repeats: true)
    }
    
    /// Set the layer size.
    /// - Note: No action is taken until `StartGradient` is called.
    /// - Parameter LayerSize: The size of the layer.
    func SetSize(_ LayerSize: CGSize)
    {
        CurrentSize = LayerSize
    }

    /// Holds the previous hue value for animated colors to prevent flickering.
    var PreviousHue: CGFloat = -1.0
    
    /// Update the gradient in an animated fashion.
    @objc func UpdateGradient()
    {
        var FirstColor = NSColor(cgColor: OriginalGradientColors.last!)!.InRGB
        var FinalHue: CGFloat = 0.0
        FirstColor = FirstColor.Move(To: Date(), Period: .Minutes, Forward: true, FinalHue: &FinalHue)
        if FinalHue == PreviousHue
        {
            return
        }
        PreviousHue = FinalHue

        var NewColors = [CGColor]()
        NewColors = PreviousColors
        NewColors.removeLast()
        NewColors.append(FirstColor.cgColor)
        
        let BGAnimation = CABasicAnimation(keyPath: "colors")
        BGAnimation.duration = 1
        BGAnimation.fillMode = CAMediaTimingFillMode.forwards
        BGAnimation.isRemovedOnCompletion = false
        BGAnimation.fromValue = PreviousColors
        BGAnimation.toValue = NewColors
        self.add(BGAnimation, forKey: "colorChange")
        PreviousColors = NewColors
    }
    
    /// Holds the current size of the layer.
    var CurrentSize: CGSize = CGSize.zero
    
    /// Set the orientation of the gradient.
    /// - Note: No action is taken until `StartGradient` is called.
    /// - Parameter IsHorizontal: If true, the gradient is horizontal. Otherwise, it is vertical.
    func SetOrientation(IsHorizontal: Bool)
    {
        if IsHorizontal
        {
            self.startPoint = CGPoint(x: 0, y: 0.5)
            self.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        else
        {
            self.startPoint = CGPoint(x: 0.5, y: 0)
            self.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
    }
    
    /// Assign color stops.
    /// - Note: No action is taken until `StartGradient` is called.
    /// - Parameter Stops: The array of color stops used to define the gradient.
    func SetColorStops(_ Stops: [ColorStopProtocol])
    {
        var ColorArray = [Any]()
        var LocationArray = [NSNumber]()
        for Stop in Stops
        {
            OriginalGradientColors.append(Stop.InitialColor)
            ColorArray.append(Stop.InitialColor)
            LocationArray.append(Stop.InitialLocation)
        }
        self.colors = ColorArray
        self.locations = LocationArray
        PreviousColors = OriginalGradientColors
    }
    
    /// Original gradient colors.
    var OriginalGradientColors = [CGColor]()
    
    /// Previous gradient colors (used during animation).
    var PreviousColors = [CGColor]()
    
    /// Determines if any of the gradient stops in `Stops` is dynamic.
    /// - Parameter Stops: The array of gradient stops to test for dynamicism.
    /// - Returns: True if any one (or more) gradient stop is dynamic. False otherwise.
    func HasDynamicStops(_ Stops: [ColorStopProtocol]) -> Bool
    {
        for Stop in Stops
        {
            if Stop.StopType == .Dynamic
            {
                return true
            }
        }
        return false
    }
    
    /// Helper function to create an array of gradient color stops from raw data.
    /// - Parameter Colors: Array of colors.
    /// - Parameter Locations: Array of locations (all normalized).
    /// - Returns: Array of gradient color stops on success, an empty array on error.
    static func CreateColorStops(Colors: [NSColor], Locations: [Double]) -> [ColorStopProtocol]
    {
        var List = [ColorStopProtocol]()
        if Colors.count != Locations.count
        {
            return List
        }
        for Index in 0 ..< Colors.count
        {
            let NewStop = StaticColorStop(Color: Colors[Index], Location: Locations[Index])
            List.append(NewStop)
        }
        return List
    }
}

/// Color stop class for colors that do not change.
class StaticColorStop: ColorStopProtocol
{
    /// Initializer.
    /// - Parameter Color: The color of the gradient stop.
    /// - Parameter Location: The location (normalized) of the gradient stop.
    init(Color: NSColor, Location: Double)
    {
        self.Color = Color.cgColor
        self.Location = NSNumber(value: Location)
    }
    
    /// Returns the gradient stop color.
    var InitialColor: CGColor
    {
        get
        {
            return Color
        }
        set
        {
            Color = newValue
        }
    }
    
    /// Returns the gradient stop location.
    var InitialLocation: NSNumber
    {
        get
        {
            return Location
        }
        set
        {
            Location = newValue
        }
    }
    
    /// Gradient stop color.
    var Color: CGColor = NSColor.white.cgColor
    
    /// Gradient stop location (normalized).
    var Location: NSNumber = 0.0
    
    /// Gradient stop type.
    var StopType = ColorStopTypes.Static
}

/// Color stop class for colors that change.
class DynamicColorStop: ColorStopProtocol
{
    /// Get or set the initial color (eg, `StartColor`).
    var InitialColor: CGColor
    {
        get
        {
            return StartColor
        }
        set
        {
            StartColor = newValue
        }
    }
    
    /// Get or set the initial location (eg `StartLocation`).
    var InitialLocation: NSNumber
    {
        get
        {
            return StartLocation
        }
        set
        {
            StartLocation = newValue
        }
    }
    
    /// The starting color.
    var StartColor: CGColor = NSColor.white.cgColor
    
    /// The ending color.
    var EndColor: CGColor = NSColor.black.cgColor
    
    /// The duration (in seconds) of the color change from `StartColor` to `EndColor`. If this is zero,
    /// no color animation will take place.
    var ColorDuration: Double = 10.0
    
    /// The staring location (normalized).
    var StartLocation: NSNumber = 0.0
    
    /// The ending location (normalized).
    var EndLocation: NSNumber = 1.0
    
    /// The duration (in seconds) of the location change from `StartLocation` to `EndLocation`. If this is
    /// zero, no location animation will take place.
    var LocationDuration: Double = 10.0
    
    /// Gradient stop type.
    var StopType = ColorStopTypes.Dynamic
}

/// Gradient stop protocol.
protocol ColorStopProtocol
{
    /// Get or set the initial gradient color.
    var InitialColor: CGColor {get set}
    
    /// Get or set the initial color location.
    var InitialLocation: NSNumber {get set}
    
    /// Get the color stop type.
    var StopType: ColorStopTypes {get}
}

/// Defines the color stop types.
enum ColorStopTypes
{
    /// Gradient color stop is static and will not change.
    case Static
    
    /// Gradient color stop is dynamic and will change.
    case Dynamic
}
