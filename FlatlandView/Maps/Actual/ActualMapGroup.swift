//
//  ActualMapGroup.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains information about a logical group of maps.
class ActualMapGroup
{
    /// Create a logical group of maps.
    /// - Parameters:
    ///   - Title: Title of the map group (for the user).
    ///   - ListOfMaps: List of map information.
    ///   - ID: ID of the group.
    init(_ Title: String, _ ListOfMaps: [ActualMap]? = nil, _ ID: UUID)
    {
        self.MapGroup = Title
        self.ID = ID
        if let MapList = ListOfMaps
        {
            self.Maps = MapList
        }
        else
        {
            self.Maps = [ActualMap]()
        }
        _IsDirty = false
    }
    
    /// Holds the dirty flag.
    private var _IsDirty = false
    /// Get the dirty flag.
    public var IsDirty: Bool = false
    {
        get
        {
            if _IsDirty
            {
                return true
            }
            for Actual in Maps
            {
                if Actual.IsDirty
                {
                    return true
                }
            }
            return false
        }
    }
    
    /// Get or set the ID of the map group.
    public var ID: UUID = UUID()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Get or set the list of actual map locations and information.
    public var Maps: [ActualMap] = [ActualMap]()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Get or set the name (visible to the user) fo the map group.
    public var MapGroup: String = ""
    {
        didSet
        {
            _IsDirty = true
        }
    }
}
