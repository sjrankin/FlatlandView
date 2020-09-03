//
//  AsynchronousData.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class AsynchronousData
{
    var Category: AsynchronousDataCategories = .Earthquakes
    var DataType: AsynchronousDataTypes = .None
    
    var Raw: [Any]? = nil
}

enum AsynchronousDataTypes: String, CaseIterable
{
    case None = "None"
    case Point = "Point"
    case Area = "Area"
}
