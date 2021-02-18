//
//  LocationEditingProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol LocationEditingProtocol: AnyObject
{
    func AddNewLocation() -> Bool
    func GetLocationToEdit() -> (Name: String, Latitude: Double, Longitude: Double, Color: NSColor)
    func SetEditedLocation(Name: String, Latitude: Double, Longitude: Double, Color: NSColor, IsValid: Bool)
    func CancelEditing()
}
