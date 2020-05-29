//
//  ActualMap.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains information about an actual map on the file system.
class ActualMap
{
    /// Get the dirty flag - if this property is true, someone set a property that needs to be saved.
    private(set) public var IsDirty = false
    
    /// Initialize a map.
    /// - Parameters:
    ///   - Title: Title of the map (for users).
    ///   - ID: ID of the map.
    ///   - Global: Directory path for the global (3D) map.
    ///   - North: Directory path for the north-centered 2D map.
    ///   - South: Directory path for the south-centered 2D map.
    init(_ Title: String, _ ID: UUID, _ Global: String, _ North: String, _ South: String)
    {
        self.Title = Title
        self.ID = ID
        self.GlobalPath = Global
        self.NorthPath = North
        self.SouthPath = South
        IsDirty = false
    }
    
    /// Get or set the title (for users) of the map.
    public var Title: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Get or set the ID of the map (not intended for user consumption).
    public var ID: UUID = UUID()
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Get or set the file path for the 3D map.
    public var GlobalPath: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Get or set the file path for the north-centered 2D map.
    public var NorthPath: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Get or set the file path for the south-centered 2D map.
    public var SouthPath: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
}
