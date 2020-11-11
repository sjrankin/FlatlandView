//
//  MouseInfoProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol MouseInfoProtocol: class
{
    func SetLocation(Latitude: String, Longitude: String, _ X: Double?, _ Y: Double?)
}
