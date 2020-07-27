//
//  EarthData.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthData
{
    public weak var Delegate: AsynchronousDataProtocol? = nil
    
    func GetEarthTiles()
    {
        DispatchQueue.global(qos: .background).async
        {
            let url = URL(string: "https://gibs.earthdata.nasa.gov/wmts/epsg4326/best/MODIS_Terra_CorrectedReflectance_TrueColor/default/2012-07-09/250m/6/13/36.jpg")
            if let ImageData = try? Data(contentsOf: url!)
            {
                if let Image = NSImage(data: ImageData)
                {
                    print("Image=\(Image)")
                }
            }
        }
    }
    
    var StartTime: Double = 0
    var CurrentTiles = [(Int, Int, NSImage)]()
    
    /// Download tiles for the specified satellite and date.
    /// - Note: Control returns immediately as the tiles are downloaded in the background.
    /// - Parameter For: Determines the satellite and wavelengths.
    /// - Parameter ForDate: The date for which the tiles are desired.
    /// - Parameter Completed: Completion handler. Called when each tile is downloaded and when all tiles are
    ///                        downloaded. Parameters are All downloaded (true if all downloaded, false if not),
    ///                        Tile row, Tile column, Tile image. The Tile image is set to nil if all tiles
    ///                        have been downloaded. When completed the Tile Row is set to the expected row count and
    ///                        the Tile Column is set to the expected column count.
    func DownloadTiles(_ For: EarthDataTiles = .MODISTerra, ForDate: Date, Completed: ((Bool, Int, Int, NSImage?) -> ())? = nil)
    {
        DispatchQueue.global(qos: .background).async
        {
            self.DownloadCompletionHandler = Completed
            self.CurrentTiles.removeAll()
            //max column is 79
            //max row is 39
            self.StartTime = CACurrentMediaTime()
            for Row in 0 ... 9
            {
                for Column in 0 ... 19
                {
                    var TileURL = "https://gibs.earthdata.nasa.gov/wmts/epsg4326/best/"
                    TileURL.append(self.TileMap[For]!.rawValue)
                    let EarthDate = Utility.MakeEarthDate(From: ForDate)
                    let TileMatrix = "4"
                    let TileRow = "\(Row)"
                    let TileColumn = "\(Column)"
                    TileURL.append("/default/\(EarthDate)/250m/\(TileMatrix)/\(TileRow)/\(TileColumn).jpg")
                    if let FinalURL = URL(string: TileURL)
                    {
                        self.GetTile(From: FinalURL, Row: Row, Column: Column, TotalExpected: 40,
                                     MaxRows: 10, MaxColumns: 20)
                    }
                }
            }
        }
    }
    
    var DownloadCompletionHandler: ((Bool, Int, Int, NSImage?) -> ())? = nil
    
    let TileMap: [EarthDataTiles: EarthDataTileTypes] =
        [
            .SuomiTrueColor: .Suomi_Reflectance_TrueColor,
            .SuomiDayNightBand: .Suomi_DayNightBand_ENCC,
            .NOAATrueColor: .NOAA_Reflectance_TrueColor,
            .MODISTerra: .MODIS_Terra_Reflectance_TrueColor,
            .MODISAqua: .MODIS_Aqua_Reflectange_TrueColor
        ]
    
    /// Get a single image tile at the specificed URL.
    /// - Parameter From: The URL of the tile to retrieve.
    /// - Parameter Row: The row index of the tile.
    /// - Parameter Column: The column index of the tile.
    /// - Parameter TotalExpected: The number of expected tiles to receive.
    /// - Parameter MaxRows: The maximum number of rows.
    /// - Parameter MaxColumns: The maximum number of columns.
    func GetTile(From TileURL: URL, Row: Int, Column: Int, TotalExpected: Int,
                 MaxRows: Int, MaxColumns: Int)
    {
        DispatchQueue.global(qos: .background).async
        {
            do
            {
                let ImageData = try Data(contentsOf: TileURL)
                if let Image = NSImage(data: ImageData)
                {
                    self.CurrentTiles.append((Row, Column, Image))
                    if let Handler = self.DownloadCompletionHandler
                    {
                        Handler(false, Row, Column, Image)
                    }
                    if self.CurrentTiles.count == TotalExpected
                    {
                        let LoadSeconds = CACurrentMediaTime() - self.StartTime
                        #if DEBUG
                        print("Load time for all tiles: \(LoadSeconds.RoundedTo(1)) seconds")
                        #endif
                        if let Handler = self.DownloadCompletionHandler
                        {
                            Handler(true, MaxRows, MaxColumns, nil)
                        }
                    }
                }
            }
            catch
            {
                print("Error returned for row \(Row), column \(Column): \(error)")
            }
        }
    }
}

enum EarthDataTileTypes: String
{
    case Suomi_Reflectance_TrueColor = "VIIRS_SNPP_CorrectedReflectance_TrueColor"
    case Suomi_DayNightBand_ENCC = "VIIRS_SNPP_DayNightBand_ENCC"
    case NOAA_Reflectance_TrueColor = "VIIRS_NOAA20_CorrectedReflectance_TrueColor"
    case MODIS_Terra_Reflectance_TrueColor = "MODIS_Terra_CorrectedReflectance_TrueColor"
    case MODIS_Aqua_Reflectange_TrueColor = "MODIS_Aqua_CorrectedReflectance_TrueColor"
}

enum EarthDataTiles: String, CaseIterable
{
    case SuomiTrueColor = "Suomi True Color"
    case SuomiDayNightBand = "Suomi Day/Night Band"
    case NOAATrueColor = "NOAA 20 True Color"
    case MODISTerra = "MODIS Terra True Color"
    case MODISAqua = "MODIS Aque True Color"
}
