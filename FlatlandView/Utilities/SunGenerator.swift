//
//  SunGenerator.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Class that creates an image of the sun.
class SunGenerator
{
    /// Creates an animated variable sun image and places it in the passed `UIImageView` control.
    /// - Note:
    ///   - The variable part of the sun is the strength of the striations.
    ///   - The animation will continue indefinitely until `StopVariableSun` is called.
    /// - Parameter Using: The `UIImageView` where the image will be places. For best results, the
    ///                    background should be black or clear and the content alignment set to
    ///                    aspect fit (or center if clipping is turned off).
    /// - Parameter Interval: How often to adjust the striation strength, in seconds.
    /// - Parameter Radius: The visual radius of the sun.
    func VariableSunImage(Using View: NSImageView, Interval: Double = 0.1, Radius: Float = 40.0)
    {
        #if false
        VariableView = View
        VariableSunRadius = Radius
        VariableSunTimer = Timer.scheduledTimer(timeInterval: Interval,
                                                target: self,
                                                selector: #selector(UpdateVariableSun),
                                                userInfo: nil, repeats: true)
        #endif
    }
    
    /// Holds the radius of the sun when viewing via `VariableSunImage`.
    private var VariableSunRadius: Float = 50.0
    /// Holds the timer for animating the variable sun.
    private var VariableSunTimer: Timer? = nil
    
    /// Stops the updating of the variable sun when initialized with `VariableSunImage`. To reanimate
    /// the sun, you must call `VariableSunImage` again.
    func StopVariableSun()
    {
        VariableSunTimer?.invalidate()
        VariableSunTimer = nil
        VariableView?.isHidden = true
    }
    
    /// Holds the `UIImageView` where to animate the variable sun.
    var VariableView: NSImageView? = nil
    
    /// Timer handler for the variable sun view.
    /// - Note: If the view is currently hidden, no output is done.
    @objc func UpdateVariableSun()
    {
        OperationQueue.main.addOperation
            {
                if let View = self.VariableView
                {
                    if View.isHidden
                    {
                        return
                    }
                    View.image = self.SunImage(LinearStrength: true,
                                               WithRadius: self.VariableSunRadius)
                }
        }
    }
    
    var CachedSuns: [Float: NSImage] = [Float: NSImage]()
    
    /// Returns a sun image with the specified strenth.
    /// - Parameter WithStrength: The striation strength.
    /// - Returns: Image of a sun.
    func SunImage(WithStrength: Float) -> NSImage
    {
        return SunImage(WithStrength: WithStrength, LinearStrength: false, UseColor: nil, WithRadius: nil)
    }
    
    /// Returns a sun image with the specified strenth.
    /// - Parameter WithStrength: The striation strength.
    /// - Parameter UseColor: The color to use for the sun's image.
    /// - Returns: Image of a sun.
    func SunImage(WithStrength: Float, UseColor: NSColor) -> NSImage
    {
        return SunImage(WithStrength: WithStrength, LinearStrength: false, UseColor: UseColor, WithRadius: nil)
    }
    
    /// Returns a sun image with the specified strenth.
    /// - Parameter WithStrength: The striation strength.
    /// - Parameter WithRadius: The radius of the sun.
    /// - Returns: Image of a sun.
    func SunImage(WithStrength: Float, WithRadius: Float) -> NSImage
    {
        return SunImage(WithStrength: WithStrength, LinearStrength: false, UseColor: nil, WithRadius: WithRadius)
    }
    
    /// Returns a sun image with the specified strenth.
    /// - Parameter WithStrength: The striation strength.
    /// - Parameter UseColor: The color to use for the sun's image.
    /// - Parameter WithRadius: The radius of the sun.
    /// - Returns: Image of a sun.
    func SunImage(WithStrength: Float, UseColor: NSColor, WithRadius: Float) -> NSImage
    {
        return SunImage(WithStrength: WithStrength, LinearStrength: false, UseColor: UseColor, WithRadius: WithRadius)
    }
    
    /// Returns a sun image with the specified strenth.
    /// - Parameter WithRadius: The radius of the sun.
    /// - Returns: Image of a sun.
    func SunImage(WithRadius: Float) -> NSImage
    {
        return SunImage(WithStrength: nil, LinearStrength: nil, UseColor: nil, WithRadius: WithRadius)
    }
    
    /// Returns a sun image with the specified strenth.
    /// - Parameter WithStrength: The striation strength. If nil, a random value (between `0.0` and `1.0`)
    ///                           is used. If `LinearStrength` is true, this parameter is ignored.
    /// - Parameter LinearStrength: If true, the strength is defined as a value that is incremented with
    ///                             each call to this function and ranges between `MinimumLinearValue`
    ///                             and `MaximumLinearValue`.
    /// - Parameter UseColor: The color to use to render the sun image. If nil, `UIColor.yellow` is used.
    /// - Parameter WithRadius: If not nil, the radius of the sun image. If nil, a default value (`50`) is used.
    /// - Returns: Image of a sun.
    func SunImage(WithStrength: Float? = nil, LinearStrength: Bool? = nil, UseColor: NSColor? = nil,
                  WithRadius: Float? = nil) -> NSImage
    {
        #if targetEnvironment(simulator)
        //This is needed due to a simulator bug that crashes when retrieving the results from
        //the sunbeamsGenerator filter.
        var SunImage = UIImage(named: "SunPlaceHolder")
        SunImage = Utility.ResizeImage(Image: SunImage!, Longest: 100)
        return SunImage!
        #else
        let Sunbeams = CIFilter.sunbeamsGenerator()
        Sunbeams.setDefaults()
        Sunbeams.center = CGPoint(x: 100, y: 100)
        if let PassedColor = UseColor
        {
            let ciColor = CIColor(color: PassedColor)
            Sunbeams.color = ciColor!
        }
        else
        {
            Sunbeams.color = CIColor.yellow
        }
        if let UseRadius = WithRadius
        {
            Sunbeams.sunRadius = UseRadius
        }
        else
        {
            Sunbeams.sunRadius = 50
        }
        var FinalStrength: Float = 0.0
        if let _ = LinearStrength
        {
            FinalStrength = CurrentStrength
            CurrentStrength = CurrentStrength + StrengthIncrementValue
            if CurrentStrength > MaximumLinearValue
            {
                FinalStrength = MaximumLinearValue
                CurrentStrength = MaximumLinearValue
                StrengthIncrementValue = StrengthIncrementValue * -1.0
            }
            if CurrentStrength < MinimumLinearValue
            {
                FinalStrength = MinimumLinearValue
                CurrentStrength = MinimumLinearValue
                StrengthIncrementValue = StrengthIncrementValue * -1.0
            }
            
        }
        else
        {
            if let Strength = WithStrength
            {
                FinalStrength = Strength
            }
            else
            {
                FinalStrength = Float.random(in: 0.0 ... 1.0)
            }
        }
        FinalStrength = Float(Int(FinalStrength * 1000.0)) / 1000.0
        FinalStriation = FinalStrength
        Sunbeams.striationStrength = FinalStrength
        Sunbeams.time = 1.0
        if let SunImage = CachedSuns[FinalStriation]
        {
            return SunImage
        }
        if let FilterOutput = Sunbeams.outputImage
        {
            let Context = CIContext(options: nil)
            if let CGImg = Context.createCGImage(FilterOutput, from: FilterOutput.extent)
            {
                let Final = NSImage(cgImage: CGImg, size: NSSize(width: 100, height: 100))
                CachedSuns[FinalStriation] = Final
                return Final
            }
        }
        fatalError("Error creating sunbeams.")
        #endif
    }
    
    /// Holds the final striation value when `LinearStrength` is used. Provided for debug purposes.
    var FinalStriation: Float = 0.0
    /// Holds the minimum linear value when `LinearStrength` is used.
    var MinimumLinearValue: Float = 0.0
    /// Holds the maximum linear value when `LinearStrength` is used.
    var MaximumLinearValue: Float = 0.35
    /// Holds the current strength between calls to `SunImage`.
    private var CurrentStrength: Float = 0.0
    /// The `LinearStrength` increment value.
    var StrengthIncrementValue: Float = 0.01
}
