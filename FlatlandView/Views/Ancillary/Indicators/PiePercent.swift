//
//  PiePercent.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Creates a pie chart-like indicator for percent indications.
/// - Note: See [Making a pie chart using Core Graphics](https://stackoverflow.com/questions/35752762/making-a-pie-chart-using-core-graphics)
class PiePercent: NSView
{
    /// Default initializer.
    /// - Parameter frame: The frame of the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.layer?.isOpaque = false
        EmptySegment = PieChartSegment(NSColor.clear, 1.0)
        FullSegment = PieChartSegment(NSColor.systemYellow, 0.0)
    }
    
    /// Default initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.layer?.isOpaque = false
        EmptySegment = PieChartSegment(NSColor.clear, 1.0)
        FullSegment = PieChartSegment(NSColor.systemYellow, 0.0)
    }
    
    /// Contains the empty segment - this is the part that indicates something yet to be done.
    var EmptySegment: PieChartSegment? = nil
    
    /// Contain the full segment - this is the part that indicates something that has been completed.
    var FullSegment: PieChartSegment? = nil
    
    /// Refresh the display.
    func Refresh()
    {
        setNeedsDisplay(self.bounds)
    }
    
    /// Holds the color of the completed part of the indicator.
    private var _Color: NSColor = NSColor.black
    {
        didSet
        {
            FullSegment?.Color = _Color
            Refresh()
        }
    }
    /// Get or set the color of the completed part of the indicator.
    @IBInspectable public var Color: NSColor
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
    
    /// Holds the color of the incompleted part of the indicator.
    private var _IncompleteColor: NSColor = NSColor.black
    {
        didSet
        {
            EmptySegment?.Color = _IncompleteColor
            Refresh()
        }
    }
    /// Get or set the color of the incompleted part of the indicator.
    @IBInspectable public var IncompleteColor: NSColor
    {
        get
        {
            return _IncompleteColor
        }
        set
        {
            _IncompleteColor = newValue
        }
    }
    
    /// Holds the current percent value for the indicator.
    /// - Note: Out of range values are ignored. When encountered, no action is taken.
    private var _CurrentPercent: CGFloat = 0.5
    {
        didSet
        {
            if _CurrentPercent < 0.0 || _CurrentPercent > 1.0
            {
                return
            }
            FullSegment!.Value = _CurrentPercent
            EmptySegment!.Value = 1.0 - _CurrentPercent
            Refresh()
        }
    }
    /// Get or set the current percent value for the indicator.
    /// - Note: Out of range values are ignored.
    @IBInspectable public var CurrentPercent: CGFloat
    {
        get
        {
            return _CurrentPercent
        }
        set
        {
            _CurrentPercent = newValue
        }
    }
    
    /// Draw the indicator.
    /// - Parameter rect: The rectangle in which the indicator should be drawn.
    override func draw(_ rect: CGRect)
    {
        #if false
        let Radius = min(frame.size.width, frame.size.height) * 0.5
        let Center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let Path = UIBezierPath()
        let Circle = UIBezierPath(ovalIn: CGRect(origin: Center, size: CGSize(width: Radius * 2.0, height: Radius * 2.0)))
        NSColor.clear.setFill()
        NSColor.black.setStroke()
        Circle.lineWidth = 4.0
        Circle.stroke()
        Circle.fill()
        Path.append(Circle)
        let Segments = [EmptySegment!, FullSegment!]
        let Count = Segments.reduce(0, {$0 + $1.Value})
        var StartAngle = -CGFloat.pi / 2.0
        let ClockwiseRotation = -1.0 * 2.0 * CGFloat.pi
        for Segment in Segments
        {
            let EndAngle = StartAngle + ClockwiseRotation * (Segment.Value / Count)
            let Arc = UIBezierPath(arcCenter: Center, radius: Radius, startAngle: StartAngle, endAngle: EndAngle, clockwise: true)
            Segment.Color.setFill()
            NSColor.black.setStroke()
            Arc.lineWidth = 2.0
            Arc.stroke()
            Arc.fill()
            Path.append(Arc)
            StartAngle = EndAngle
        }
        #else
        let Context = NSGraphicsContext.current?.cgContext
        let Radius = min(frame.size.width, frame.size.height) * 0.5
        let Center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let Segments = [EmptySegment!, FullSegment!]
        let Count = Segments.reduce(0, {$0 + $1.Value})
        var StartAngle = -CGFloat.pi / 2.0
        let ClockwiseRotation = -1.0 * 2.0 * CGFloat.pi
        for Segment in Segments
        {
            let EndAngle = StartAngle + ClockwiseRotation * (Segment.Value / Count)
            Context?.setFillColor(Segment.Color.cgColor)
            Context?.move(to: Center)
            Context?.addArc(center: Center, radius: Radius, startAngle: StartAngle,
                            endAngle: EndAngle, clockwise: true)
            Context?.fillPath()
            StartAngle = EndAngle
        }
        Context?.setStrokeColor(NSColor.black.cgColor)
        Context?.strokePath()
        #endif
    }
}

/// Encapsulates one pie chart segment.
class PieChartSegment
{
    /// Initializer.
    /// - Parameter Color: The color of the segment.
    /// - Parameter Value: the value of the segment, ranging between 0.0 and 1.0.
    init(_ Color: NSColor, _ Value: CGFloat)
    {
        self.Color = Color
        self.Value = Value
    }
    
    /// The color of the segment.
    var Color: NSColor = NSColor.white
    /// The border color of the segment.
    var BorderColor: NSColor = NSColor.black
    /// The value of the segment.
    var Value: CGFloat = 0.0
}
