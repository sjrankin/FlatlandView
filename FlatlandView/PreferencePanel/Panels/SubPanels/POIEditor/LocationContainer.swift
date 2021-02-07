//
//  LocationContainer.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/7/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LocationContainer
{
    init(With City: City2)
    {
        IsCity = true
        self.City = City
        LocationName = City.Name
    }
    
    init(With POI: POI2)
    {
        IsCity = false
        self.POI = POI
        LocationName = POI.Name
    }
    
    var LocationName: String = ""
    var IsCity: Bool = true
    var City: City2? = nil
    var POI: POI2? = nil
    var Deleted: Bool = false
    var IsDirty: Bool = false
}
