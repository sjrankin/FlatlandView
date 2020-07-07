//
//  KMDataPoint.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// K-Means clustering protocol. Algorithm adapted from _Classic Computer Science Problems in Swift_.
protocol KMDataPoint: CustomStringConvertible, Equatable
{
    static var NumDimensions: UInt { get }
    var Dimensions: [Double] { get set}
    init(Values: [Double])
}

extension KMDataPoint
{
    public func Distance<Point: KMDataPoint>(To: Point) -> Double
    {
        return sqrt(zip(Dimensions, To.Dimensions).map({pow(($0.1 - $0.0), 2)}).Sum)
    }
}
