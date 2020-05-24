//
//  ColorList.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Manages color lists.
class ColorList
{
    /// Basic color list.
    public static var Colors: [MetaColor] =
        [
            MetaColor("Red", NSColor.red),
            MetaColor("Green", NSColor.green),
            MetaColor("Blue", NSColor.blue),
            MetaColor("Cyan", NSColor.cyan),
            MetaColor("Magenta", NSColor.magenta),
            MetaColor("Yellow", NSColor.yellow),
            MetaColor("Orange", NSColor.orange),
            MetaColor("Brown", NSColor.brown),
            MetaColor("Black", NSColor.black),
            MetaColor("White", NSColor.white),
            MetaColor("Gray", NSColor.gray),
            MetaColor("Gold", NSColor(HexString: "#ffd700")!),
            MetaColor("Maroon", NSColor(HexString: "#800000")!),
            MetaColor("Light Sky Blue", NSColor(HexString: "#87cefa")!),
            MetaColor("Prussian Blue", NSColor(HexString: "#003171")!),
            MetaColor("Pistachio", NSColor(HexString: "#93c572")!),
            MetaColor("Lime", NSColor(HexString: "#bfff00")!),
            MetaColor("Midori", NSColor(HexString: "#2a603b")!),
            MetaColor("Bōtan", NSColor(HexString: "#a4345d")!),
            MetaColor("Shironeri", NSColor(HexString: "ffddca")!),
            MetaColor("Ajiiro", NSColor(HexString: "#ebf6f7")!),
    ]
    
    public static func SimpleColorList() -> [(Name: String, Color: NSColor)]
    {
        var Results = [(Name: String, Color: NSColor)]()
        for SomeColor in Colors
        {
            Results.append((SomeColor.Name, SomeColor.Color))
        }
        return Results
    }
    
    public static func MetaColorFrom(_ Raw: String) -> MetaColor?
    {
        guard let RawColor = NSColor(HexString: Raw) else
        {
            return nil
        }
        return MetaColorFrom(RawColor)
    }
    
    public static func MetaColorFrom(_ Color: NSColor) -> MetaColor?
    {
        for SomeColor in Colors
        {
            if SomeColor.Color == Color
            {
                return SomeColor
            }
        }
        return nil
    }
}

/// Contains a single color.
class MetaColor
{
    /// Initializer.
    /// - Note: Alpha is set to `1.0`.
    /// - Parameter Name: The name of the color.
    /// - Parameter R: The red channel value - **must be normalized**.
    /// - Parameter G: The green channel value - **must be normalized**.
    /// - Parameter B: The blue channel value - **must be normalized**.
    init(_ Name: String, _ R: Double, _ G: Double, _ B: Double)
    {
        self.Name = Name
        Color = NSColor(red: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: 1.0)
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter R: The red channel value - **must be normalized**.
    /// - Parameter G: The green channel value - **must be normalized**.
    /// - Parameter B: The blue channel value - **must be normalized**.
    /// - Parameter A: The alpha channel value - **must be normalized**.
    init(_ Name: String, _ R: Double, _ G: Double, _ B: Double, _ A: Double)
    {
        self.Name = Name
        Color = NSColor(red: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: CGFloat(A))
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter Value: The NSColor from which to create a color.
    init(_ Name: String, _ Value: NSColor)
    {
        self.Name = Name
        Color = Value
    }
    
    /// Initializer.
    /// - Parameter Name: The name of the color.
    /// - Parameter Value: Hex string used to create a color. Invalid strings will cause
    ///                    fatal errors.
    init(_ Name: String, _ Value: String)
    {
        self.Name = Name
        Color = NSColor(HexString: Value)!
    }
    
    /// The color.
    var Color: NSColor = NSColor.clear
    
    /// The name of the color.
    var Name: String = ""
}
