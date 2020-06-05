//
//  +GridLines.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension GlobeView
{
    /// Create a base image for the trid lines.
    /// - Parameter Width: The width of the image.
    /// - Parameter Height: The hieght of the image.
    /// - Parameter FillColor: The background color.
    /// - Returns: Image with the specified parameters.
    func MakeImageBase(Width: CGFloat, Height: CGFloat, FillColor: NSColor) -> NSImage
    {
        let ImageSize = CGSize(width: Width, height: Height)
        return NSImage(Color: FillColor, Size: ImageSize)
    }
    
    /// Draw an image with grid lines on it that can be used as a texture on top of a global image.
    /// - Note: This function draws the minor grid lines. It calls another function to draw the
    ///         major grid lines on top of the minor grid lines.
    /// - Parameter Width: Width of the image to return.
    /// - Parameter Height: Height of the image to return.
    /// - Parameter LineColor: The major grid line color.
    /// - Parameter MinorLineColor: The minor grid line color.
    /// - Returns: Image of the specified size with the grid lines drawn as per user settings.
    func MakeGridLines(Width: CGFloat, Height: CGFloat,
                       LineColor: NSColor = NSColor.red,
                       MinorLineColor: NSColor = NSColor.yellow) -> NSImage
    {
        let Base = NSImage(named: "TransparentBase")
        #if true
        let Line = NSBezierPath()
        if Settings.GetBool(.Show3DMinorGrid)
        {
                        Base?.lockFocus()
            let Gap = Settings.GetDouble(.MinorGrid3DGap, 15.0)
            for Longitude in stride(from: 0.0, to : 359.0, by: Gap)
            {
                let X = Width * CGFloat(Longitude / 360.0)
                Line.move(to: NSPoint(x: X, y: 0.0))
                Line.line(to: NSPoint(x: X, y: Height))
            }
            for Latitude in stride(from: 0.0, to: 359.0, by: Gap)
            {
                let Y = Height * CGFloat(Latitude / 360.0)
                Line.move(to: NSPoint(x: 0.0, y: Y))
                Line.line(to: NSPoint(x: Width, y: Y))
            }
            Line.lineWidth = 3.0
            MinorLineColor.withAlphaComponent(1.0).setStroke()
            Line.stroke()
            Base?.unlockFocus()
        }
        
        //Draw the major grid lines on top of the minor grid lines.
        let FinalWithMajorLines = DrawMajorGridLines(On: Base!, Width: Width, Height: Height,
                                                     LineColor: LineColor)
        let Final = FinalWithMajorLines
        return Final
        #else
        UIGraphicsBeginImageContext(Base.size)
        
        Base.draw(at: .zero)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(3.0)
        ctx?.setStrokeColor(MinorLineColor.withAlphaComponent(1.0).cgColor)
        
        if Settings.GetBool(.Show3DMinorGrid)
        {
            let Gap = Settings.GetDouble(.MinorGrid3DGap, 15.0)
            if Gap >= 5.0
            {
                for Longitude in stride(from: 0.0, to: 359.0, by: Gap)
                {
                    let X = Width * CGFloat(Longitude / 360.0)
                    ctx?.move(to: CGPoint(x: X, y: 0))
                    ctx?.addLine(to: CGPoint(x: X, y: Height))
                    ctx?.strokePath()
                }
                for Latitude in stride(from: 0.0, to: 359.0, by: Gap)
                {
                    let Y = Height * CGFloat(Latitude / 360.0)
                    ctx?.move(to: CGPoint(x: 0, y: Y))
                    ctx?.addLine(to: CGPoint(x: Width, y: Y))
                    ctx?.strokePath()
                }
            }
        }
        
        var Final = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Draw the major grid lines on top of the minor grid lines.
        let FinalWithMajorLines = DrawMajorGridLines(On: Final!, Width: Width, Height: Height,
                                                     LineColor: LineColor)
        Final = FinalWithMajorLines
        return Final!
        #endif
    }
    
    /// Draw the major grid lines.
    /// - Note: Major grid lines are the prime and anti-prime meridians, polar circles, tropical
    ///         circles, and equator.
    /// - Parameter On: The base image on which the grid lines will be drawn.
    /// - Parameter Width: The width of the image.
    /// - Parameter Height: The height of the image.
    /// - Parameter LineColor: The color of the line. Defaults to `UIColor.yellow`.
    /// - Returns: Image (based on `On`) with the grid lines drawn.
    func DrawMajorGridLines(On Image: NSImage, Width: CGFloat, Height: CGFloat,
                            LineColor: NSColor = NSColor.yellow) -> NSImage
    {
        #if true
        Image.lockFocus()
        
        let Line = NSBezierPath()
        
        for Longitude in Longitudes.allCases
        {
            let Y = Height * CGFloat(Longitude.rawValue)
            Line.move(to: CGPoint(x: 0, y: Y))
            Line.line(to: CGPoint(x: Width, y: Y))
        }
        
        for Latitude in Latitudes.allCases
        {
            let X = Width * CGFloat(Latitude.rawValue)
            Line.move(to: CGPoint(x: X, y: 0))
            Line.line(to: CGPoint(x: X, y: Height))
        }
        
        Line.lineWidth = 3.0
        LineColor.withAlphaComponent(1.0).setStroke()
        Line.stroke()
        
        Image.unlockFocus()
        return Image
        #else
        UIGraphicsBeginImageContext(Image.size)
        
        Image.draw(in: .zero)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(5.0)
        ctx?.setStrokeColor(LineColor.withAlphaComponent(1.0).cgColor)
        
        for Longitude in Longitudes.allCases
        {
            let Y = Height * CGFloat(Longitude.rawValue)
            ctx?.move(to: CGPoint(x: 0, y: Y))
            ctx?.addLine(to: CGPoint(x: Width, y: Y))
            ctx?.strokePath()
        }
        
        for Latitude in Latitudes.allCases
        {
            let X = Width * CGFloat(Latitude.rawValue)
            ctx?.move(to: CGPoint(x: X, y: 0))
            ctx?.addLine(to: CGPoint(x: X, y: Height))
            ctx?.strokePath()
        }
        
        let Final = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Final!
        #endif
    }
}
