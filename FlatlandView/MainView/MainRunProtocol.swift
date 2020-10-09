//
//  MainRunProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol RunningEarth
{
    func SetEarthState(_ NewState: EarthStates)
    func CurrentEarthState() -> EarthStates
}

enum EarthStates: String, CaseIterable
{
    case Run = "Run"
    case Stop = "Stop"
}
