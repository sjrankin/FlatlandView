//
//  MapManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// High-level map image manager for the maps displayed by Flatland.
class MapManager
{
    /// Returns an image for the specified map type and view type.
    /// - Note: Map images are cached upon use.
    /// - Note: `.Rectangular` view type maps return the same image as `.Globe3D` view type maps. It is up
    ///         to the caller to use them differently.
    /// - Parameter MapType: The type (style) of map image to return. See `MapTypes` for available map types.
    /// - Parameter ViewType: The general view type (flat or global) of the program.
    /// - Parameter ImageCenter: For `.FlatMap` `ViewType`s only. Determines which pole is in the
    ///                          center of the map.
    /// - Returns: Map image for the specified map type. Nil if not found.
    public static func ImageFor(MapType: MapTypes, ViewType: ViewTypes, ImageCenter: ImageCenters = .NorthPole) -> NSImage?
    {
        let MapCategory = CategoryFor(Map: MapType)!
        if let SomeMap = MapList.Map(For: MapType)
        {
            switch ViewType
            {
                case .FlatNorthCenter:
                    return SomeMap.GetMapImage(For: .North)
                
                case .FlatSouthCenter:
                    return SomeMap.GetMapImage(For: .South)
                
                case .Globe3D:
                    if MapCategory == .Satellite
                    {
                        
                    }
                    else
                    {
                    return SomeMap.GetMapImage(For: .Global)
                    }
                    
                case .Rectangular:
                    return SomeMap.GetMapImage(For: .Global)
                
                default:
                    return nil
            }
        }
        return nil
    }
    
    /// Returns the light intensity multiplier for the specified map type.
    /// - Parameter MapType: The map type whose light intensity multiplier is returned. If `MapType`
    ///                      is not found, `1.0` is returned.
    /// - Returns: The map's light intensity multiplier value.
    public static func GetLightMulitplier(MapType: MapTypes) -> Double
    {
        if let Map = MapList.Map(For: MapType)
        {
            return Map.LightMultiplier2D
        }
        return 1.0
    }
    
    /// Returns an image of the side of a cubic world.
    /// - Parameter CubicImage: Determines which side to return.
    /// - Returns: Image for the specified side. Nil if not found.
    public static func CubicImageSide(_ CubicImage: CubicMapTypes) -> NSImage?
    {
        return NSImage(named: CubicImage.rawValue)
    }
    
    /// Returns a material for the side of a cubic world.
    /// - Parameter CubicImage: Determines which side to return.
    /// - Parameter Rotated: Value (in degrees) to rotate the image before returning it as a material.
    ///                      Defaults to 0.0° (no rotation).
    /// - Returns: `SCNMaterial` with the diffuse contents populated with the specified image on
    ///            success, nil on error.
    public static func CubicImageMaterial(_ CubicImage: CubicMapTypes, Rotated: CGFloat = 0.0) -> SCNMaterial?
    {
        if let Image = CubicImageSide(CubicImage)
        {
            var FinalImage = Image
            if Rotated != 0.0
            {
                FinalImage = Image.Rotate(Degrees: Rotated) 
            }
            let Material = SCNMaterial()
            Material.diffuse.contents = FinalImage
            return Material
        }
        else
        {
            return nil
        }
    }
    
    /// Returns a list of map category names
    /// - Returns: List of map category names.
    public static func GetMapCategoryNames() -> [String]
    {
        var Results = [String]()
        for Category in MapCategories.allCases
        {
            Results.append(Category.rawValue)
        }
        return Results
    }
    
    /// Returns a list of map categories.
    /// - Returns: List of map categories.
    public static func GetMapCategories() -> [MapCategories]
    {
        var Results = [MapCategories]()
        for Category in MapCategories.allCases
        {
            Results.append(Category)
        }
        return Results
    }
    
    /// Returns the set of maps associated with the passed map category.
    /// - Parameter Category: The category whose list of maps is returned.
    /// - Returns: List of maps for the passed category.
    public static func GetMapsInCategory(_ Category: MapCategories) -> [MapTypes]
    {
        switch Category
        {
            case .Standard:
                return [.Standard, .Simple, .SimpleBorders1, .SimpleBorders2, .Continents,
                        .StandardSea]
            
            case .Physical:
                return [.BlueMarble, .MODIS, .DarkBlueMarble, .USGS,
                        .Topographical1, .Topographical2, .SurrealTopographic, .EarthquakeMap,
                        .OnlyTectonic, .TectonicOverlay, .StaticAerosol, .Normalized]
            
            case .Satellite:
                return [.GIBS_MODIS_Terra_CorrectedReflectance_TrueColor,
                        .GIBS_MODIS_Terra_CorrectedReflectance_721,
                        .GIBS_MODIS_Terra_CorrectedReflectance_367,
                        .GIBS_MODIS_Aqua_CorrectedReflectance_TrueColor,
                        .GIBS_MODIS_Aqua_CorrectedReflectance_721,
                        .GIBS_SNPP_VIIRS_CorrectedReflectance_TrueColor,
                        .GIBS_SNPP_VIIRS_CorrectedReflectance_M11I2I1,
                        .GIBS_NOAA20_VIIRS_CorrectedReflectance_TrueColor,
                        .GIBS_NOAA20_VIIRS_CorrectedReflectance_M3I3I11]
                
            case .TimeZone:
                return [.TimeZoneMap1, .ColorfulTimeZones, .TimeZone4, .HatchedTimeZones, .PaperTimeZones,
                        .SurrealTimeZone]
            
            case .Political:
                return [.SimplePoliticalMap1, .TransparentOcean, .CitiesAtNight]
            
            case .Astronomical:
                return [.MarsViking, .MarsMariner9, .MOLAVerticalRoughness, .LROMap, .LunarGeoMap,
                        .Jupiter, .GaiaSky, .TychoSky, .TychoConstellations, .NASAStarsInverted]
            
            case .Artistic:
                return [.OilPainting1, .WaterColor1, .WaterColor2, .Cartoon, .SwirlyLines, .RoundSplotches,
                        .ColorInk, .Warhol, .Ukiyoe1, .ASCIIArt1]
            
            case .Colorful:
                return [.Pink, .Bronze, .Blueprint, .BlackWhite, .BlackWhiteShiny, .WhiteBlack,
                        .SpotColor, .LevelWorld]
            
            case .Abstract:
                return [.Dots, .Crosshatched, .Textured, .PaperWorld, .SquareWorld, .Abstract1,
                        .Abstract2, .Abstract3, .Surreal1, .Skeleton, .GlowingCoasts, .Voronoi,
                        .Polygons, .Extruded, .BubbleWorld, .StainedGlass]
            
            case .Dithered:
                return [.HalftoneLine, .HalftoneVerticalLine, .HalftoneDot, .Dithered]
            
            case .Silly:
                return [.House, .Tigger]
            
            case .Stylized:
                return [.StylizedSea1]
            
                #if DEBUG
            case .Debug:
                return [.Debug1, .Debug3, .Debug2, .Debug4, .Debug5, .Debug6, .Debug7]
                #endif
        }
    }
    
    /// Returns the map category for the specified map type.
    /// - Parameter Map: The map type for which the related map category is returned.
    /// - Returns: The map category for the passed map type. Nil if not found.
    public static func CategoryFor(Map: MapTypes) -> MapCategories?
    {
        for MapCategory in MapCategories.allCases
        {
            if GetMapsInCategory(MapCategory).contains(Map)
            {
                return MapCategory
            }
        }
        return nil
    }
}

/// Map categories.
enum MapCategories: String, CaseIterable
{
    /// Standard maps.
    case Standard = "Standard"
    /// Physically-based maps.
    case Physical = "Physical"
    /// Maps made of satellite images.
    case Satellite = "Satellite"
    /// Maps with time zones marked on them.
    case TimeZone = "Time Zone"
    /// Political maps (other than what are in `.Standard` maps).
    case Political = "Political"
    /// Extraterrestrial maps.
    case Astronomical = "Astronomical"
    /// Artistic maps.
    case Artistic = "Artistic"
    /// Colorful (or black and white) maps.
    case Colorful = "Colorful"
    /// Abstract (but marginally useful) maps.
    case Abstract = "Abstract"
    /// Dithered maps.
    case Dithered = "Dithered"
    /// Silly maps.
    case Silly = "Silly"
    /// Stylized maps.
    case Stylized = "Stylized"
    #if DEBUG
    /// Debug maps.
    case Debug = "Debug"
    #endif
}

/// Determines whether the north pole or the south pole is at the center of the world image.
enum ImageCenters: String, CaseIterable
{
    /// North pole is in the center.
    case NorthPole = "NorthPole"
    /// South pole is in the center.
    case SouthPole = "SouthPole"
}

/// Specifies the sides of a cubic map.
enum CubicMapTypes: String, CaseIterable
{
    case nx = "nx"
    case ny = "ny"
    case nz = "nz"
    case px = "px"
    case py = "py"
    case pz = "pz"
    case ny270 = "ny270"
    case ny90 = "ny90"
    case py90 = "py90"
    case pym90 = "py-90"
}
