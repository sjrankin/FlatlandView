//
//  MapItem.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains one map definition.
class MapItem
{
    /// Map initializer.
    /// - Parameters:
    ///   - MapType: The type of map.
    ///   - External: Flag that determines where the map image lives.
    ///   - UserMap: Flag that determines if the map is a user map.
    ///   - Global: Name of the global map. External files should specify the full name including
    ///             the file's extension.
    ///   - North: Name of the north-centered flat map. External files should specify the full name including
    ///            the file's extension.
    ///   - South: Name of the south-centered flat map. External files should specify the full name including
    ///            the file's extension.
    ///   - Preload: If true, the map is loaded at instantiation time.
    ///   - LightMultiplier: Value to multiply the intensity of the main light in 2D mode. Defaults
    ///                      to `1.0`.
    init(_ MapType: MapTypes, _ External: Bool, UserMap: Bool = false, _ Global: String, _ North: String,
         _ South: String, Preload: Bool = false, LightMultiplier: Double = 1.0)
    {
        self.MapType = MapType
        self.UserMap = UserMap
        IsExternal = External
        GlobalMapName = Global
        NorthCenterMapName = North
        SouthCenterMapName = South
        if Preload
        {
            let _ = GetMapImage(For: .Global)
            let _ = GetMapImage(For: .North)
            let _ = GetMapImage(For: .South)
        }
        LightMultiplier2D = LightMultiplier
    }
    
    /// Returns the map image for the specified map function.
    /// - Parameter For: The function of the map (eg, 3D, 2D).
    /// - Returns: The image of the map on success, nil if not found.
    func GetMapImage(For Function: MapFunctions) -> NSImage?
    {
        switch Function
        {
            case .Global:
                if let Image = GlobalMap
                {
                    return Image
                }
                if IsExternal
                {
                    if let Image = FileIO.ImageFromFile(WithName: GlobalMapName)
                    {
                        GlobalMap = Image
                        return Image
                    }
                    else
                    {
                        print("Error loading external image \(GlobalMapName)")
                        return nil
                    }
                }
                else
                {
                    if let Image = NSImage(named: GlobalMapName)
                    {
                        GlobalMap = Image
                        return Image
                    }
                    else
                    {
                        print("Error finding internal image \(GlobalMapName)")
                        return nil
                    }
            }
            
            case .North:
                if let Image = NorthCenterMap
                {
                    return Image
                }
                if IsExternal
                {
                    if let Image = FileIO.ImageFromFile(WithName: NorthCenterMapName)
                    {
                        NorthCenterMap = Image
                        return Image
                    }
                    else
                    {
                        print("Error loading external image \(NorthCenterMapName)")
                        return nil
                    }
                }
                else
                {
                    if let Image = NSImage(named: NorthCenterMapName)
                    {
                        NorthCenterMap = Image
                        return Image
                    }
                    else
                    {
                        print("Error finding internal image \(NorthCenterMapName)")
                        return nil
                    }
            }
            
            case .South:
                if let Image = SouthCenterMap
                {
                    return Image
                }
                if IsExternal
                {
                    if let Image = FileIO.ImageFromFile(WithName: SouthCenterMapName)
                    {
                        SouthCenterMap = Image
                        return Image
                    }
                    else
                    {
                        print("Error loading external image \(SouthCenterMapName)")
                        return nil
                    }
                }
                else
                {
                    if let Image = NSImage(named: SouthCenterMapName)
                    {
                        SouthCenterMap = Image
                        return Image
                    }
                    else
                    {
                        print("Error finding internal image \(SouthCenterMapName)")
                        return nil
                    }
            }
        }
    }
    
    public var IsExternal: Bool = true
    public var GlobalMapName: String = ""
    public var NorthCenterMapName: String = ""
    public var SouthCenterMapName: String = ""
    public var GlobalMap: NSImage? = nil
    public var NorthCenterMap: NSImage? = nil
    public var SouthCenterMap: NSImage? = nil
    public var MapType: MapTypes = .Standard
    public var UserMap: Bool = false
    public var LightMultiplier2D: Double = 1.0
}

/// The functional purpose of a map image.
enum MapFunctions
{
    /// Map image will be used as a global (eg, 3D) map.
    case Global
    /// Map image will be used as a flat (eg, 2D) map with north at the center.
    case North
    /// Map image will be used as a flat (eg, 2D) map with south at the center.
    case South
}
