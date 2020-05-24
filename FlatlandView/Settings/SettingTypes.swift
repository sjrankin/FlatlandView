//
//  SettingTypes.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

enum SettingTypes: String, CaseIterable
{
    //Infrastructure/initialization-related settings.
    case InitializationFlag = "InitializationFlag"
    
    //Map-related settings.
    case MapType = "MapType"
    
    //City-related settings.
    case AfricanCityColor = "AfricanCityColor"
    case AsianCityColor = "AsianCityColor"
    case EuropeanCityColor = "EuropeanCityColor"
    case NorthAmericanCityColor = "NorthAmericanCityColor"
    case SouthAmericanCityColor = "SouthAmericanCityColor"
    case CapitalCityColor = "CapitalCityColors"
    case WorldCityColor = "WorldCityColors"
}
