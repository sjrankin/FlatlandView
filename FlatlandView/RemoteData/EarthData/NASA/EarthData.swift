//
//  EarthData.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Handles retrieval of GIBS (Global Imagery Browse Server from NASA) image tiles.
/// - Note: We acknowledge the use of imagery provided by services from NASA's Global Imagery Browse Services (GIBS), part of NASA's Earth Observing System Data and Information System (EOSDIS).
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
    typealias MapLoadedHandler = ((NSImage, Double, Date, Bool, Any?) -> ())?
    
    /// Start downloading image tiles for the passed map type and date.
    /// - Note: If `.EnableNASATiles` is false, control is immedately returned and the last value of the
    ///         completion handler is set to `false`.
    /// - Parameter Map: The satellite map type to download.
    /// - Parameter For: The date of the satellite map to download. If too early, all data may not be
    ///                  available.
    /// - Parameter Completed: Called when the process is completed.
    func LoadMap(_ Map: SatelliteMap, For ImageDate: Date, Completed: MapLoadedHandler = nil)
    {
        Debug.Print("Loading satellite map \(Map.SatelliteMapType.rawValue)")
        if !Settings.GetBool(.EnableNASATiles)
        {
            Debug.Print("LoadMap called but EnableNASATiles is false.")
            Completed?(NSImage(), 0.0, ImageDate, false, nil)
            return
        }
        let StartTime = CACurrentMediaTime()
        
        Map.URLs.removeAll()
        let TilesX = Map.HorizontalTileCount
        let TilesY = Map.VerticalTileCount
        
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Load Tile Queue for \(Map)"
        Queue.addOperation
        {
            MemoryDebug.Open("Get NASA Tiles")
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
                        self.CreateMapFromTiles(TilesX: TilesX, TilesY: TilesY, When: ImageDate, Name: Map.Layer)
                        {
                            Image, Duration, When, Done, Name in
                            let TotalDuration = Duration + CACurrentMediaTime() - StartTime
                            Debug.Print("Created satellite map in \(TotalDuration.RoundedTo(1)) seconds)")
                            Completed?(Image, TotalDuration, When, Done, Map.SatelliteMapType)
                            MemoryDebug.Close("Get NASA Tiles")
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
    func CreateMapFromTiles(TilesX: Int, TilesY: Int, When: Date, Name: String,
                            Completion: MapLoadedHandler = nil)
    {
        Debug.Print(">>>>>>> Started map creation.")
        let Start = CACurrentMediaTime()
        
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
                Debug.Print("Missing tile at row \(Row), column \(Column)")
            }
        }
        
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Map Assembly Queue"
        Queue.addOperation
        {
            var Count = 0
            let TileSize = Int(SatelliteConstants.TileSize.rawValue)
            let BackgroundHeight = TilesY * TileSize
            let BackgroundWidth = TilesX * TileSize
            var Background = NSImage(size: NSSize(width: BackgroundWidth / 2, height: BackgroundHeight / 2))
            Background.lockFocus()
            NSColor.black.drawSwatch(in: NSRect(origin: .zero, size: Background.size))
            Background.unlockFocus()
            Background = self.ResizeImage(Image: Background, Longest: CGFloat(TilesX * TileSize))
            autoreleasepool
            {
                for (Row, Column, _, Tile) in self.Results
                {
                    let FinalTileY = (TilesY - Row) - 1
                    let Point = NSPoint(x: Column * TileSize, y: FinalTileY * TileSize)
                    let ReducedTile = self.ResizeImage(Image: Tile, Longest: CGFloat(TileSize))
                    Background = self.BlitImage(ReducedTile, On: Background, At: Point)!
                    Count = Count + 1
                }
            }
            let Duration = CACurrentMediaTime() - Start
            Completion?(Background, Duration, When, true, Name)
        }
        Debug.Print(">>>>>>> Completed map creation.")
    }
    
    var TileMap = [UUID: (Int, Int)]()
    var Results = [(Row: Int, Column: Int, ID: UUID, Image: NSImage)]()
     var CountLock = NSObject()
    
    private  var _DownloadCount: Int = 0
    public  var DownloadCount: Int
    {
        get
        {
            objc_sync_enter(CountLock)
            defer{objc_sync_exit(CountLock)}
            return _DownloadCount
        }
        set
        {
            objc_sync_enter(CountLock)
            defer{objc_sync_exit(CountLock)}
            _DownloadCount = newValue
        }
    }

    private static var CumulativeCountLock = NSObject()
    private static var _CumulativeTilesDownloaded: Int = 0
    public static var CumulativeTilesDownloaded: Int
    {
        get
        {
            objc_sync_enter(CumulativeCountLock)
            defer{objc_sync_exit(CumulativeCountLock)}
            return _CumulativeTilesDownloaded
        }
        set
        {
            objc_sync_enter(CumulativeCountLock)
            defer{objc_sync_exit(CumulativeCountLock)}
            _CumulativeTilesDownloaded = newValue
        }
    }
    
    private static var CumulativeByteCountLock = NSObject()
    private static var _CumulativeByteCount: UInt64 = 0
    public static var CumulativeByteCount: UInt64
    {
        get
        {
            objc_sync_enter(CumulativeByteCountLock)
            defer{objc_sync_exit(CumulativeByteCountLock)}
            return _CumulativeByteCount
        }
        set
        {
            objc_sync_enter(CumulativeByteCountLock)
            defer{objc_sync_exit(CumulativeByteCountLock)}
            _CumulativeByteCount = newValue
        }
    }
    
    public static var CumulativeDurations = [Double]()
    
    public static func TotalDownloadDuration() -> Double
    {
        var Total: Double = 0.0
        for Down in CumulativeDurations
        {
            Total = Total + Down
        }
        return Total
    }
    
    public static func MeanDownloadDuration() -> Double
    {
        if CumulativeDurations.isEmpty
        {
            return 0.0
        }
        var Total: Double = 0.0
        for Down in CumulativeDurations
        {
            Total = Total + Down
        }
        return Total / Double(CumulativeDurations.count)
    }
    
    /// Call a NASA server to get an image tile.
    /// - Parameter From: The URL of the image tile to return.
    /// - Parameter Row: The row of the tile in the full image.
    /// - Parameter Column: The column of the tile in the full image.
    /// - Parameter ExpectedCount: The expected number of returned tiles.
    /// - Parameter MaxRows: The maximum number of rows in the full image.
    /// - Parameter MaxColumns: The maximum number of columns in the full image.
    /// - Parameter Completed: Closure called when a tile has been received.
    func GetTile(From: URL, Row: Int, Column: Int, ExpectedCount: Int, MaxRows: Int, MaxColumns: Int,
                 Completed: (() -> ())? = nil)
    {
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Tile Retrieval Queue \(Column)x\(Row)"
        Queue.addOperation
        {
            do
            {
                let ImageData = try Data(contentsOf: From)
                if let Image = NSImage(data: ImageData)
                {
                    objc_sync_enter(self.AccessLock)
                    var ByteSize = Int(Image.size.width * Image.size.height)
                    ByteSize = ByteSize * 4
                    EarthData.CumulativeByteCount = EarthData.CumulativeByteCount + UInt64(ByteSize)
                    let ID = UUID()
                    self.Results.append((Row, Column, ID, Image))
                    self.TileMap[ID] = (Row, Column)
                    self.DownloadCount = self.DownloadCount + 1
                    EarthData.CumulativeTilesDownloaded = EarthData.CumulativeTilesDownloaded + 1
                    objc_sync_exit(self.AccessLock)
                    if self.DownloadCount == ExpectedCount
                    {
                        Completed?()
                    }
                }
            }
            catch
            {
                Debug.Print("Error on tile \(Column)x\(Row): \(error.localizedDescription)")
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
    
    /// Returns the specified satellite map information for the given map type and set of satellite maps.
    /// - Parameter For: The type of satellite map to return.
    /// - Parameter From: The array of pre-existing satellite maps.
    /// - Returns: A `SatelliteMap` object for the specified map type on success, nil if not found.
    public static func MapFromMaps(For: MapTypes, From: [SatelliteMap]) -> SatelliteMap?
    {
        for Map in From
        {
            if Map.SatelliteMapType == For
            {
                return Map
            }
        }
        return nil
    }
    
    /// Return a list of satellite map data for getting image tiles from NASA.
    /// - Returns: Array of all available satellite map definitions.
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
                                 ForDate: Date(),
                                 MatrixSet: "500m"))
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
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_SNPP_VIIRS_CorrectedReflectance_M3I3M11,
                                 Layer: "VIIRS_SNPP_CorrectedReflectance_BandsM3-I3-M11",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_SNPP_VIIRS_DayNightBand_At_Sensor_Radiance,
                                 Layer: "VIIRS_SNPP_DayNightBand_At_Sensor_Radiance",
                                 ForDate: Date(),
                                 MatrixSet: "500m",
                                 Format: "png"))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_SNPP_Brightness_Temp_BandI5_Day,
                                 Layer: "VIIRS_SNPP_Brightness_Temp_BandI5_Day",
                                 ForDate: Date(),
                                 Format: "png"))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_SNPP_Brightness_Temp_BandI5_Night,
                                 Layer: "VIIRS_SNPP_Brightness_Temp_BandI5_Night",
                                 ForDate: Date(),
                                 Format: "png"))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_NOAA20_VIIRS_CorrectedReflectance_TrueColor,
                                 Layer: "VIIRS_NOAA_CorrectedReflectance_TrueColor",
                                 ForDate: Date()))
        Maps.append(SatelliteMap(MapType: MapTypes.GIBS_NOAA20_VIIRS_CorrectedReflectance_M3I3I11,
                                 Layer: "VIIRS_NOAA20_CorrectedReflectance_BandsM3-I3-M11",
                                 ForDate: Date()))
        
        return Maps
    }
}
