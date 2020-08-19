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
    public weak var MainDelegate: MainProtocol? = nil
    
    var AccessLock: NSObject = NSObject()
    
    /// Map loaded handler definition. First parameter is the completed map and the second is the duration
    /// from the call to `LoadMap` to the call of this completion handler. The third parameter is the date
    /// used to retrieve the individual map tiles. The fourth parameter indicates whether the process was
    /// able to be completed or not. If false, there was some reason (most likely the environment value was
    /// not set to "yes") for not downloading the map.
    typealias MapLoadedHandler = ((NSImage, Double, Date, Bool) -> ())?
    
    /// Start downloading image tiles for the passed map type and date.
    /// - Note: If `.EnableNASATiles` is false, control is immedately returned and the last value of the
    ///         completion handler is set to `false`.
    /// - Parameter Map: The satellite map type to download.
    /// - Parameter For: The date of the satellite map to download. If too early, all data may not be
    ///                  available.
    /// - Parameter Completed: Called when the process is completed.
    func LoadMap(_ Map: SatelliteMap, For ImageDate: Date, Completed: MapLoadedHandler = nil)
    {
        if !Settings.GetBool(.EnableNASATiles)
        {
            Completed?(NSImage(), 0.0, ImageDate, false)
            return
        }
        let StartTime = CACurrentMediaTime()
        MainDelegate?.SetIndicatorVisibility(true)
        MainDelegate?.SetIndicatorPercent(0.0)
        MainDelegate?.SetIndicatorColor(NSColor.yellow)
        MainDelegate?.SetIndicatorText("Getting tiles")
        
        Map.URLs.removeAll()
        let TilesX = Map.HorizontalTileCount
        let TilesY = Map.VerticalTileCount
        
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Load Tile Queue"
        Queue.addOperation
        {
            Map.URLs = SatelliteMap.GenerateTileInformation(From: Map, When: ImageDate)
            let ExpectedCount = Map.URLs.count
            
            self.TileMap.removeAll()
            self.Results.removeAll()
            self.DownloadCount = 0
            
            for (Path, Row, Column) in Map.URLs
            {
                if let TileURL = URL(string: Path)
                {
                    self.GetTile(From: TileURL, Row: Row, Column: Column, ExpectedCount: ExpectedCount,
                                 MaxRows: Map.VerticalTileCount, MaxColumns: Map.HorizontalTileCount)
                    {
                        //Called when all tiles are downloaded - time to start assembling them.
                        self.CreateMapFromTiles(TilesX: TilesX, TilesY: TilesY, When: ImageDate)
                        {
                            Image, Duration, When, Done in
                            let TotalDuration = Duration + CACurrentMediaTime() - StartTime
                            Completed?(Image, TotalDuration, When, Done)
                        }
                    }
                }
            }
        }
    }
    
    /// Given a set of tiles from NASA, create a seamless equirectangular image.
    /// - Parameter TilesX: Number of horizontal tiles.
    /// - Parameter TilesY: Number of vertical tiles.
    /// - Parameter When: The date for the images.
    /// - Parameter Completion: Called upon map completion.
    func CreateMapFromTiles(TilesX: Int, TilesY: Int, When: Date,
                            Completion: MapLoadedHandler = nil)
    {
        let Start = CACurrentMediaTime()
        MainDelegate?.SetIndicatorPercent(0.0)
        MainDelegate?.SetIndicatorText("Making map")
        MainDelegate?.SetIndicatorColor(NSColor.systemBlue)
        
        for Result in Results
        {
            if let _ = TileMap[Result.ID]
            {
                TileMap.removeValue(forKey: Result.ID)
            }
        }
        if TileMap.count > 0
        {
            for (_, (Row, Column)) in TileMap
            {
                print("Missing tile at row \(Row), column \(Column)")
            }
        }
        
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Map Assembly Queue"
        Queue.addOperation
        {
            var Count = 0
            let TileSize = 128
            let BackgroundHeight = TilesY * TileSize
            let BackgroundWidth = TilesX * TileSize
            var Background = NSImage(size: NSSize(width: BackgroundWidth / 2, height: BackgroundHeight / 2))
            print("CreateMapFromTiles: Background.size=\(Background.size)")
            Background.lockFocus()
            NSColor.systemYellow.drawSwatch(in: NSRect(origin: .zero, size: Background.size))
            Background.unlockFocus()
            Background = self.ResizeImage(Image: Background, Longest: CGFloat(TilesX * TileSize))
            print("CreateMapFromTiles: Resized Background.size=\(Background.size)")
            autoreleasepool
            {
                for (Row, Column, _, Tile) in self.Results
                {
                    let FinalTileY = (TilesY - Row) - 1
                    let Point = NSPoint(x: Column * TileSize, y: FinalTileY * TileSize)
                    let ReducedTile = self.ResizeImage(Image: Tile, Longest: CGFloat(TileSize))
                    Background = self.BlitImage(ReducedTile, On: Background, At: Point)!
                    Count = Count + 1
                    OperationQueue.main.addOperation
                    {
                        self.MainDelegate?.SetIndicatorPercent(Double(Count) / Double(self.Results.count))
                    }
                }
            }
            //Background = self.ResizeImage(Image: Background, Longest: 3600.0)
            //print("CreateMapFromTiles: Resized{2} Background.size=\(Background.size)")
            let Duration = CACurrentMediaTime() - Start
            Completion?(Background, Duration, When, true)
        }
    }
    
    var TileMap = [UUID: (Int, Int)]()
    var Results = [(Row: Int, Column: Int, ID: UUID, Image: NSImage)]()
    var DownloadCount = 0
    
    /// Call a NASA server to get an image tile.
    /// - Parameter From: The URL of the image tile to return.
    /// - Parameter Row: The row of the tile in the full image.
    /// - Parameter Column: The column of the tile in the full image.
    /// - Parameter ExpectedCount: The expected number of returned tiles.
    /// - Parameter MaxRows: The maximum number of rows in the full image.
    /// - Parameter MaxColumns: The maximum number of columns in the full image.
    /// - Parameter Completed: Closure called when a tile has been received.
    func GetTile(From: URL, Row: Int, Column: Int, ExpectedCount: Int,
                 MaxRows: Int, MaxColumns: Int,
                 Completed: (() -> ())? = nil)
    {
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Tile Retrieval Queue"
        Queue.addOperation
        {
            do
            {
                let ImageData = try Data(contentsOf: From)
                if let Image = NSImage(data: ImageData)
                {
                    objc_sync_enter(self.AccessLock)
                    //defer{objc_sync_exit(self.AccessLock)}
                    let ID = UUID()
                    self.Results.append((Row, Column, ID, Image))
                    self.TileMap[ID] = (Row, Column)
                    self.DownloadCount = self.DownloadCount + 1
                    self.MainDelegate?.SetIndicatorPercent(Double(self.DownloadCount) / Double(ExpectedCount))
                    objc_sync_exit(self.AccessLock)
                    if self.DownloadCount == ExpectedCount
                    {
                        Completed?()
                    }
                }
            }
            catch
            {
                print("Error on tile \(Column)x\(Row): \(error.localizedDescription)")
            }
        }
    }
    
    /// Blit a tile image onto the full map.
    /// - Parameter Tile: The tile to blit onto the background image.
    /// - Parameter On: The background image that will function as the full image once completed.
    /// - Parameter At: The location where to blit the `Tile` image onto `On`.
    /// - Returns: Image with the passed `Tile` blitted onto `Background` on success, nil on error.
    func BlitImage(_ Tile: NSImage, On Background: NSImage, At Point: NSPoint) -> NSImage?
    {
        autoreleasepool
        {
            let CIBGImg = Background.tiffRepresentation
            let BGImg = CIImage(data: CIBGImg!)
            let Offscreen = NSBitmapImageRep(ciImage: BGImg!)
            guard let Context = NSGraphicsContext(bitmapImageRep: Offscreen) else
            {
                return nil
            }
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = Context
            Tile.draw(at: Point, from: NSRect(origin: .zero, size: Tile.size),
                      operation: .sourceAtop, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            let Final = NSImage(size: Background.size)
            Final.addRepresentation(Offscreen)
            return Final
        }
    }
    
    /// Resize the passed image such that the longest dimension has a size proportional to `Longest`.
    /// - Parameter Image: The image to resize.
    /// - Parameter Longest: Used to determine the ratio of the longest dimension of the image.
    /// - Returns: Resized image.
    public func ResizeImage(Image: NSImage, Longest: CGFloat) -> NSImage
    {
        let ImageMax = max(Image.size.width, Image.size.height)
        if ImageMax <= Longest
        {
            return Image
        }
        let Ratio = Longest / ImageMax
        let NewSize = NSSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        let NewImage = NSImage(size: NewSize)
        NewImage.lockFocus()
        Image.draw(in: NSMakeRect(0, 0, NewSize.width, NewSize.height),
                   from: NSMakeRect(0, 0, Image.size.width, Image.size.height),
                   operation: NSCompositingOperation.sourceOver,
                   fraction: CGFloat(1))
        NewImage.unlockFocus()
        NewImage.size = NewSize
        return NewImage
    }
    
    public static func MakeSatelliteMapDefinitions() -> [SatelliteMap]
    {
        var Maps = [SatelliteMap]()
        
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_MODIS_Terra_CorrectedReflectance_TrueColor,
                                 Layer: "MODIS_Terra_CorrectedReflectance_TrueColor",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_MODIS_Terra_CorrectedReflectance_721,
                                 Layer: "MODIS_Terra_CorrectedReflectance_Bands721",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_MODIS_Terra_CorrectedReflectance_367,
                                 Layer: "MODIS_Terra_CorrectedReflectance_Bands367",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_MODIS_Terra_SurfaceReflectance_143,
                                 Layer: "MODIS_Terra_CorrectedReflectance_Bands143",
                                 ForDate: Date(), MatrixSet: "500m"))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_MODIS_Aqua_CorrectedReflectance_TrueColor,
                                 Layer: "MODIS_Aqua_CorrectedReflectance_TrueColor",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_MODIS_Aqua_CorrectedReflectance_721,
                                 Layer: "MODIS_Aqua_CorrectedReflectance_Bands721",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_SNPP_VIIRS_CorrectedReflectance_TrueColor,
                                 Layer: "VIIRS_SNPP_CorrectedReflectance_TrueColor",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_SNPP_VIIRS_CorrectedReflectance_M11I2I1,
                                 Layer: "VIIRS_SNPP_CorrectedReflectance_BandsM11-I2-I1",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_NOAA20_VIIRS_CorrectedReflectance_TrueColor,
                                 Layer: "VIIRS_NOAA_CorrectedReflectance_TrueColor",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_NOAA20_VIIRS_CorrectedReflectance_M3I3I11,
                                 Layer: "VIIRS_NOAA20_CorrectedReflectance_BandsM3-I3-M11",
                                 ForDate: Date()))
        
        return Maps
    }
}
