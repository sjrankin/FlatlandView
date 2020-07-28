//
//  SatelliteMap.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SatelliteMap
{
    init()
    {
        
    }
    
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
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: ObservationDate)
        let Month = Cal.component(.month, from: ObservationDate)
        var SMonth = "\(Month)"
        if Month < 10
        {
            SMonth = "0\(Month)"
        }
        let Day = Cal.component(.day, from: ObservationDate)
        var SDay = "\(Day)"
        if Day < 10
        {
            SDay = "0\(Day)"
        }
        let FinalDate = "default/\(Year)-\(SMonth)-\(SDay)/"
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
    
    public var SatelliteMapType: MapTypes = .GIBS_MODIS_Aqua_CorrectedReflectance_TrueColor
    
    public var Layer = "MODIS_Terra_CorrectedReflectance_TrueColor"
    
    public var Service = "wmts"
    
    public var EPSG = "4326"
    
    public var QueryType = "best"
    
    public var TileMatrixSet = "250m"
    
    public var ZoomLevel: Int = 4
    
    public var HorizontalTileCount = 20
    
    public var VerticalTileCount = 10
    
    public var FileType = "jpg"
    
    public var ObservationDate = Date()
    
    public var URLs = [(Path: String, Row: Int, Column: Int)]()
    
    public static func GenerateTiles(From: SatelliteMap, When: Date) -> [(Path: String, Row: Int, Column: Int)]
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
