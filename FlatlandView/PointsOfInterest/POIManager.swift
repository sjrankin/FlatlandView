//
//  POIManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class POIManager
{
    public static func Initialize()
    {
        AllPOIs = MainController.GetAllPOIs()
    }
    
    public static var AllPOIs: [POI]? = nil
    
    public static func GetPOIs(By POIType: POITypes) -> [POI]
    {
        if AllPOIs == nil
        {
            return [POI]()
        }
        var Result = [POI]()
        for SomePOI in AllPOIs!
        {
            if SomePOI.POIType == POIType.rawValue
            {
                Result.append(SomePOI)
            }
        }
        return Result
    }
}
