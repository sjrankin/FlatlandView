//
//  +LocationDelegate.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings: LocationEditingProtocol
{
    func AddNewLocation() -> Bool
    {
        return AddNewUserLocation
    }
    
    func GetLocationToEdit() -> (Name: String, Latitude: Double, Longitude: Double, Color: NSColor)
    {
        if CurrentUserLocationIndex < 0
        {
            return ("", 0.0, 0.0, NSColor.black)
        }
        return (UserLocations[CurrentUserLocationIndex].Name,
                UserLocations[CurrentUserLocationIndex].Coordinates.Latitude,
                UserLocations[CurrentUserLocationIndex].Coordinates.Longitude,
                UserLocations[CurrentUserLocationIndex].Color)
    }
    
    func SetEditedLocation(Name: String, Latitude: Double, Longitude: Double, Color: NSColor, IsValid: Bool)
    {
        if IsValid
        {
            if AddNewUserLocation
            {
                UserLocations.append((UUID(), GeoPoint2(Latitude, Longitude), Name, Color))
            }
            else
            {
                if CurrentUserLocationIndex >= 0
                {
                    UserLocations[CurrentUserLocationIndex].Name = Name
                    UserLocations[CurrentUserLocationIndex].Coordinates.Latitude = Latitude
                    UserLocations[CurrentUserLocationIndex].Coordinates.Longitude = Longitude
                    UserLocations[CurrentUserLocationIndex].Color = Color
                }
            }
            Settings.SetLocations(UserLocations)
            MainDelegate?.Refresh("MainSettings.SetEditedLocation")
        }
    }
    
    func CancelEditing()
    {
    }
    
}
