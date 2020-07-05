//
//  KMDataPoint.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol KMDataPoint: CustomStringConvertible, Equatable
{
    static var NumDimensions: UInt { get }
    var Dimensions: [Double] { get set}
    init(Values: [Double])
}

extension KMDataPoint
{
    func Distance<Point: KMDataPoint>(To: Point) -> Double
    {
        return sqrt(zip(Dimensions, To.Dimensions).map({pow(($0.1 - $0.0), 2)}).Sum)
    }
}
