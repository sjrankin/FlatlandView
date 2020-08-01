//
//  SatelliteMap.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Contains information about one type of satellite map to retrieve from NASA.
class SatelliteMap
{
    /// Initializer.
    /// - Parameters:
    ///   - MapType: The map type to tie back to the static map system.
    ///   - Layer: Layer description - used to request the satellite and bandwidth.
    ///   - Service: Image service description.
    ///   - EPSG: EPSG format number.
    ///   - QueryType: Type of image query.
    ///   - ForDate: The date for the satellite imagery.
    ///   - MatrixSet: The tile matrix set.
    ///   - Zoom: The zoom level.
    ///   - MaxRow: Maximum number of rows in the set.
    ///   - MaxColumn: Maximum number of columns in the set.
    ///   - Format: Image format as a file extension. *Do not preceed the string with a period.*
    init(MapType: MapTypes, Layer: String, Service: String = "wmts", EPSG: String = "4326",
         QueryType: String = "best", ForDate: Date, MatrixSet: String = "250m",
         Zoom: Int = 4, MaxRow: Int = 10, MaxColumn: Int = 20, Format: String = "jpg")
    {
        self.SatelliteMapType = MapType
        self.Layer = Layer
        self.Service = Service
        self.EPSG = EPSG
        self.QueryType = QueryType
        self.ObservationDate = ForDate
        self.TileMatrixSet = MatrixSet
        self.ZoomLevel = Zoom
        self.HorizontalTileCount = MaxColumn
        self.VerticalTileCount = MaxRow
        self.FileType = Format
    }
    
    /// Return the query string for the date and location.
    /// - Note: This function assumes all properties have been set appropriately.
    /// - Parameter Imaged: The date for the image.
    /// - Parameter X: The column number.
    /// - Parameter Y: The row number.
    /// - Returns: RESTful query string to be used by the `URL` class to retrieve the specified image.
    public func GetQueryFor(_ Imaged: Date, X: Int, Y: Int) -> String
    {
        var TileURL = "https://gibs.earthdata.nasa.gov/"
        TileURL.append(Service)
        TileURL.append("/")
        TileURL.append("epsg")
        TileURL.append(EPSG)
        TileURL.append("/")
        TileURL.append(QueryType)
        TileURL.append("/")
        TileURL.append(Layer)
        TileURL.append("/default/")
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Imaged)
        let Month = Cal.component(.month, from: Imaged)
        var SMonth = "\(Month)"
        if Month < 10
        {
            SMonth = "0\(Month)"
        }
        let Day = Cal.component(.day, from: Imaged)
        var SDay = "\(Day)"
        if Day < 10
        {
            SDay = "0\(Day)"
        }
        let FinalDate = "\(Year)-\(SMonth)-\(SDay)"
        TileURL.append(FinalDate)
        TileURL.append("/")
        TileURL.append(TileMatrixSet)
        TileURL.append("/")
        TileURL.append("\(ZoomLevel)")
        TileURL.append("/")
        TileURL.append("\(Y)")
        TileURL.append("/")
        TileURL.append("\(X)")
        TileURL.append(".\(FileType)")
        return TileURL
    }
    
    /// The map type.
    public var SatelliteMapType: MapTypes = .GIBS_MODIS_Aqua_CorrectedReflectance_TrueColor
    
    /// The layer string. See GIBS documentation of the `NASATiles` test program.
    public var Layer = "MODIS_Terra_CorrectedReflectance_TrueColor"
    
    /// The service to use.
    public var Service = "wmts"
    
    /// EPSG format.
    public var EPSG = "4326"
    
    /// Image query type.
    public var QueryType = "best"
    
    /// Tile matrix set. (Essentially, the returned resolution.)
    public var TileMatrixSet = "250m"
    
    /// Zoom level within the `TileMatrixSet`.
    public var ZoomLevel: Int = 4
    
    /// Number of horiztonal tiles for one full image of the Earth.
    public var HorizontalTileCount = 20
    
    /// Number of vertical tiles for one full image of the Earth.
    public var VerticalTileCount = 10
    
    /// The type of file that is expected to be returned. *Do not specify a leading period.*
    public var FileType = "jpg"
    
    /// The date for the returned image.
    public var ObservationDate = Date()
    
    /// Holds a list of generated paths for each valid row/column combination.
    public var URLs = [(Path: String, Row: Int, Column: Int)]()
    
    /// Holds the cached map image. Setting this property also sets `CachedMapTimeStamp`.
    public var CachedMap: NSImage? = nil
    {
        didSet
        {
            CachedMapTimeStamp = Date()
        }
    }
    
    /// Holds the time stamp of the cached map. This is used to determine if it's time to reload the
    /// satellite image.
    public var CachedMapTimeStamp: Date? = nil
    
    /// Determines if the cached satellite map is valid. Validity is determined by how old the image is.
    /// - Returns: True if the image is valid, false if not.
    public func CachedMapIsValid() -> Bool
    {
        if let TimeStamp = CachedMapTimeStamp
        {
            let TimeStampSeconds = TimeStamp.timeIntervalSinceReferenceDate
            let NowSeconds = Date().timeIntervalSinceReferenceDate
            let Delta = NowSeconds - TimeStampSeconds
            if Delta < 0.0
            {
                CachedMapTimeStamp = nil
                return false
            }
            let DeltaHours = Delta / 60 * 60 * 24.0
            if DeltaHours < 36.0
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    /// Generate a list of URLs - one URL for each valid row/column combination.
    /// - Parameter From: The `SatelliteMap` class with appropriate data.
    /// - Parameter When: The date desired for the images.
    /// - Returns: Array of tuples with the string form of the image URL, the Row for the image, and the
    ///            Column for the image.
    public static func GenerateTileInformation(From: SatelliteMap, When: Date) -> [(Path: String, Row: Int, Column: Int)]
    {
        var TileList = [(Path: String, Row: Int, Column: Int)]()
        for Row in 0 ..< From.VerticalTileCount
        {
            for Column in 0 ..< From.HorizontalTileCount
            {
                let Path = From.GetQueryFor(When, X: Column, Y: Row)
                TileList.append((Path, Row, Column))
            }
        }
        return TileList
    }
}
