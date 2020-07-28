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
    /// from the call to `LoadMap` to the call of this completion handler.
    typealias MapLoadedHandler = ((NSImage, Double) -> ())?
    
    func LoadMap(_ Map: inout SatelliteMap, Completed: MapLoadedHandler = nil)
    {
        let StartTime = CACurrentMediaTime()
        MainDelegate?.SetIndicatorColor(NSColor.systemYellow)
        MainDelegate?.SetIndicatorText("Getting tiles")
        MainDelegate?.SetIndicatorPercent(0.0)
        
        Map.URLs.removeAll()
        let TilesX = Map.HorizontalTileCount
        let TilesY = Map.VerticalTileCount
        
        var DayComponent = DateComponents()
        DayComponent.day = -1
        let Cal = Calendar.current
        let Yesterday = Cal.date(byAdding: DayComponent, to: Date())!
        
        Map.URLs = SatelliteMap.GenerateTiles(From: Map, When: Yesterday)
        let ExpectedCount = Map.URLs.count
        
        TileMap.removeAll()
        Results.removeAll()
        DownloadCount = 0
        
        for (Path, Row, Column) in Map.URLs
        {
            if let TileURL = URL(string: Path)
            {
                GetTile(From: TileURL, Row: Row, Column: Column, ExpectedCount: ExpectedCount,
                        MaxRows: Map.VerticalTileCount, MaxColumns: Map.HorizontalTileCount)
                {
                    //Called when all tiles are downloaded - time to start assembling them.
                    self.CreateMapFromTiles(TilesX: TilesX, TilesY: TilesY)
                    {
                        Image, Duration in
                        let TotalDuration = Duration + CACurrentMediaTime() - StartTime
                        Completed?(Image, TotalDuration)
                    }
                }
            }
        }
    }
    
    func CreateMapFromTiles(TilesX: Int, TilesY: Int, Completion: MapLoadedHandler = nil)
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
        
        DispatchQueue.global(qos: .background).async
        {
            var Count = 0
            let TileSize = 128
            let BackgroundHeight = TilesY * TileSize
            let BackgroundWidth = TilesX * TileSize
            var Background = NSImage(size: NSSize(width: BackgroundWidth / 2, height: BackgroundHeight / 2))
            Background.lockFocus()
            NSColor.systemYellow.drawSwatch(in: NSRect(origin: .zero, size: Background.size))
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
                    OperationQueue.main.addOperation
                    {
                        self.MainDelegate?.SetIndicatorPercent(Double(Count) / Double(self.Results.count))
                    }
                }
            }
            let Duration = CACurrentMediaTime() - Start
            Completion?(Background, Duration)
        }
    }
    
    var TileMap = [UUID: (Int, Int)]()
    var Results = [(Row: Int, Column: Int, ID: UUID, Image: NSImage)]()
    var DownloadCount = 0
    
    func GetTile(From: URL, Row: Int, Column: Int, ExpectedCount: Int,
                 MaxRows: Int, MaxColumns: Int,
                 Completed: (() -> ())? = nil)
    {
        DispatchQueue.global(qos: .background).async
        {
            do
            {
                let ImageData = try Data(contentsOf: From)
                if let Image = NSImage(data: ImageData)
                {
                    objc_sync_enter(self.AccessLock)
                    defer{objc_sync_exit(self.AccessLock)}
                    let ID = UUID()
                    self.Results.append((Row, Column, ID, Image))
                    self.TileMap[ID] = (Row, Column)
                    self.DownloadCount = self.DownloadCount + 1
                    self.MainDelegate?.SetIndicatorPercent(Double(self.DownloadCount) / Double(ExpectedCount))
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
    
    public func ResizeImage(Image: NSImage, Longest: CGFloat) -> NSImage
    {
        let ImageMax = max(Image.size.width, Image.size.height)
        if ImageMax <= Longest
        {
            print("resize returned early")
            return Image
        }
        let Ratio = Longest / ImageMax
        let NewSize = NSSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        print(">>>> NewSize=\(NewSize)")
        let NewImage = NSImage(size: NewSize)
        NewImage.lockFocus()
        Image.draw(in: NSMakeRect(0, 0, NewSize.width, NewSize.height),
                   from: NSMakeRect(0, 0, Image.size.width, Image.size.height),
                   operation: NSCompositingOperation.sourceOver,
                   fraction: CGFloat(1))
        NewImage.unlockFocus()
        NewImage.size = NewSize
        print("resized image to \(NewImage.size)")
        return NewImage
    }
}
