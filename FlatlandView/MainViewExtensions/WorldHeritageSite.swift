//
//  WorldHeritageSite.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Encapsulates a single world heritage site.
class WorldHeritageSite
{
    /// Initializer.
    init(_ UID: Int, _ ID: Int, _ Name: String, _ Year: Int, _ Latitude: Double,
         _ Longitude: Double, _ Hectares: Double, _ Category: String,
         _ ShortCategory: String, _ Countries: String)
    {
        self.UID = UID
        self.ID = ID
        self.Name = Name
        self.DateInscribed = Year
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Hectares = Hectares
        self.Category = Category
        self.ShortCategory = ShortCategory
        self.Countries = Countries
    }
    
    var UID: Int = 0
    var ID: Int = 0
    var Name: String = ""
    var DateInscribed: Int = 0
    var Longitude: Double = 0.0
    var Latitude: Double = 0.0
    var Hectares: Double? = nil
    var Category: String = ""
    var ShortCategory: String = ""
    var Countries: String = ""
    var InternalID: UUID = UUID()
}
