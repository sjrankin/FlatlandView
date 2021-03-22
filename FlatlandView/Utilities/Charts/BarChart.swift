//
//  BarChart.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/22/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Class to create simple bar charts. Intended for debugging purposes. The charts generated here are all
/// two-dimensional.
class BarChart
{
    /// Create the layer and background.
    /// - Parameter Size: The size of the layer.
    /// - Parameter Background: The color of the background of the layer.
    /// - Returns: A layer the specified size and color.
    private static func MakeBackground(_ Size: NSSize, Background Color: NSColor) -> CALayer
    {
        let ChartLayer = CALayer()
        ChartLayer.frame = NSRect(x: 0, y: 0, width: Size.width, height: Size.height)
        ChartLayer.backgroundColor = Color.cgColor
        return ChartLayer
    }
    
    /// Create a bar to add to the bar chart.
    /// - Note: A border can optionally be drawn on the bar by specifying a color in `BorderColor`. If a color
    ///         is passed, the value in `BorderPercent` determines the width of the border.
    /// - Parameter Rect: The rectangle that defines the bar.
    /// - Parameter Color: The color of the bar (interior color).
    /// - Parameter BorderColor: The color of the border of the bar. If nil, no border is drawn. Defaults
    ///                          to `nil`.
    /// - Parameter BorderPercent: The width of the border if `BorderColor` is not nil. This function assumes
    ///                            this value is a normal and will be used to mulitply by the width of the bar
    ///                            to get the width of the border. Defaults to `0.05`.
    /// - Returns: The bar as specified by the parameters.
    private static func MakeBar(_ Rect: NSRect, Color: NSColor, BorderColor: NSColor? = nil,
                                BorderPercent: CGFloat = 0.05) -> CAShapeLayer
    {
        let Shape = CAShapeLayer()
        Shape.frame = Rect
        Shape.backgroundColor = Color.cgColor
        if let Border = BorderColor
        {
            let Width = Rect.width * BorderPercent
            Shape.borderWidth = Width
            Shape.borderColor = Border.cgColor
        }
        Shape.zPosition = 1000
        return Shape
    }
    
    /// Create a bar chart. Bars will be white.
    /// - Parameter With: Array of `Double` values to be plotted horizontally.
    /// - Parameter Size: Size of the overall bar chart.
    /// - Parameter BackgroundColor: Background color of the chart. Defaults to `NSColor.black`.
    /// - Parameter BorderColor: The color to use for the border. If this value is `nil`, no border is drawn.
    ///                          Default is `nil`.
    /// - Parameter HorizontalBarPercent: Normal value that indicates how thick to draw each bar based on its
    ///                                   base width. Defaults to `1.0` which indicates no gap between bars.
    /// - Returns: A layer object with the chart drawn on it.
    public static func MakeChart(With Points: [Double], Size: NSSize, BackgroundColor: NSColor = NSColor.black,
                                 BorderColor: NSColor? = nil, HorizontalBarPercent: Double = 1.0) -> CALayer
    {
        let ChartLayer = MakeBackground(Size, Background: BackgroundColor)
        if Points.isEmpty
        {
            return ChartLayer
        }
        guard let Max = Points.max() else
        {
            return ChartLayer
        }
        var HGap = HorizontalBarPercent
        if HGap < 0.0
        {
            HGap = 0.0
        }
        if HGap > 1.0
        {
            HGap = 1.0
        }
        let BarWidth = Size.width / CGFloat(Points.count)
        let HeightRatio = Size.height / CGFloat(Max)
        for Index in 0 ..< Points.count
        {
            let Point = Points[Index]
            let FinalWidth = CGFloat(HGap) * BarWidth
            let Rect = NSRect(x: CGFloat(Index) * BarWidth,
                              y: 0.0,
                              width: FinalWidth,
                              height: CGFloat(Point) * HeightRatio)
            let Bar = MakeBar(Rect, Color: NSColor.white, BorderColor: BorderColor)
            ChartLayer.addSublayer(Bar)
        }
        return ChartLayer
    }
    
    /// Create a bar chart.
    /// - Parameter With: Array of (`Double`, `NSColor`) values to be plotted horizontally. Each point will
    ///                   use its corresponding color as the bar color.
    /// - Parameter Size: Size of the overall bar chart.
    /// - Parameter BackgroundColor: Background color of the chart. Defaults to `NSColor.black`.
    /// - Parameter BorderColor: The color to use for the border. If this value is `nil`, no border is drawn.
    ///                          Default is `nil`.
    /// - Parameter HorizontalBarPercent: Normal value that indicates how thick to draw each bar based on its
    ///                                   base width. Defaults to `1.0` which indicates no gap between bars.
    /// - Returns: A layer object with the chart drawn on it.
    public static func MakeChart(With Points: [(Double, NSColor)], Size: NSSize,
                                 BackgroundColor: NSColor = NSColor.black,
                                 BorderColor: NSColor? = nil,
                                 HorizontalBarPercent: Double = 1.0) -> CALayer
    {
        let ChartLayer = MakeBackground(Size, Background: BackgroundColor)
        if Points.isEmpty
        {
            return ChartLayer
        }
        let Values = Points.map({$0.0})
        guard let Max = Values.max() else
        {
            return ChartLayer
        }
        var HGap = HorizontalBarPercent
        if HGap < 0.0
        {
            HGap = 0.0
        }
        if HGap > 1.0
        {
            HGap = 1.0
        }
        let BarWidth = Size.width / CGFloat(Points.count)
        let HeightRatio = Size.height / CGFloat(Max)
        for Index in 0 ..< Points.count
        {
            let Value = Points[Index].0
            let Color = Points[Index].1
            let FinalWidth = CGFloat(HGap) * BarWidth
            let Rect = NSRect(x: CGFloat(Index) * BarWidth,
                              y: 0.0,
                              width: FinalWidth,
                              height: CGFloat(Value) * HeightRatio)
            let Bar = MakeBar(Rect, Color: Color, BorderColor: BorderColor)
            ChartLayer.addSublayer(Bar)
        }
        return ChartLayer
    }
    
    /// Create a delta bar chart with the origin running horizontally along the middle of the chart. Positive
    /// values are on top and negative on the bottom.
    /// - Parameter With: Array of (`Double`, `NSColor`) values to be plotted horizontally. Each point will
    ///                   use its corresponding color as the bar color.
    /// - Parameter Size: Size of the overall bar chart.
    /// - Parameter BackgroundColor: Background color of the chart. Defaults to `NSColor.black`.
    /// - Parameter BorderColor: The color to use for the border. If this value is `nil`, no border is drawn.
    ///                          Default is `nil`.
    /// - Parameter HorizontalBarPercent: Normal value that indicates how thick to draw each bar based on its
    ///                                   base width. Defaults to `1.0` which indicates no gap between bars.
    /// - Returns: A layer object with the chart drawn on it.
    public static func MakeDeltaChart(With Points: [(Double, NSColor)], Size: NSSize,
                                      BackgroundColor: NSColor = NSColor.black,
                                      BorderColor: NSColor? = nil,
                                      HorizontalGap: Double = 1.0) -> CALayer
    {
        let ChartLayer = MakeBackground(Size, Background: BackgroundColor)
        if Points.isEmpty
        {
            return ChartLayer
        }
        let Values = Points.map({$0.0})
        guard let Max = Values.max() else
        {
            return ChartLayer
        }
        var HGap = HorizontalGap
        if HGap < 0.0
        {
            HGap = 0.0
        }
        if HGap > 1.0
        {
            HGap = 1.0
        }
        let BarWidth = Size.width / CGFloat(Points.count)
        var HeightRatio: CGFloat = 0.0
        if Max != 0.0
        {
            HeightRatio = (Size.height * 0.5) / CGFloat(Max)
        }
        let FinalY = Size.height * 0.5
        
        for Index in 0 ..< Points.count
        {
            let Value = Points[Index].0
            let Color = Points[Index].1
            let FinalWidth = CGFloat(HGap) * BarWidth
            let Rect = NSRect(x: CGFloat(Index) * BarWidth,
                              y: FinalY,
                              width: FinalWidth,
                              height: CGFloat(Value) * HeightRatio)
            let Bar = MakeBar(Rect, Color: Color, BorderColor: BorderColor)
            ChartLayer.addSublayer(Bar)
        }
        
        return ChartLayer
    }
}
