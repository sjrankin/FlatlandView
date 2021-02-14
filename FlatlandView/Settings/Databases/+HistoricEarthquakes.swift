//
//  +HistoricEarthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

// MARK: - Historic earthquake database handling.

extension DBIF
{
    /// Get historic earthquakes by date range.
    /// - Parameter Start: The starting date for the range of earthquakes to return.
    /// - Parameter End: The ending date for the range of earthquakes to return.
    /// - Returns: Array of earthquakes from the specified range. May be empty if nothing found.
    public static func GetHistoricQuakes(Start: Date, End: Date) -> [Earthquake]
    {
        let StartSeconds = Start.timeIntervalSince1970
        let EndSeconds = Start.timeIntervalSince1970
        return GetHistoricQuakes(Start: StartSeconds, End: EndSeconds)
    }
    
    /// Get historic earthquakes by date range.
    /// - Parameter Start: The starting date for the range of earthquakes to return. The starting date is
    ///                    defined as the number of seconds since 1970.
    /// - Parameter End: The ending date for the range of earthquakes to return. The ending date is
    ///                  defined as the number of seconds since 1970.
    /// - Returns: Array of earthquakes from the specified range. May be empty if nothing found.
    public static func GetHistoricQuakes(Start: Double, End: Double) -> [Earthquake]
    {
        print("Start=\(Date(timeIntervalSince1970: Start)), End=\(Date(timeIntervalSince1970: End))")
        var Results = [Earthquake]()
        let WherePhrase = "WHERE Time BETWEEN \(Start) AND \(End)"
        let GetQuery = "SELECT * FROM \(QuakeTableNames.Historic.rawValue) \(WherePhrase)"
        var QueryHandle: OpaquePointer? = nil
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.QuakeHandle, Query: GetQuery)
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query \(GetQuery) for historic earthquakes: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.QuakeHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [Earthquake]()
        }
        
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.ID.rawValue)!
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.Longitude.rawValue)!
            let Place = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Place.rawValue)!
            let Magnitude = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.Magnitude.rawValue)!
            let Depth = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.Depth.rawValue)!
            let Time = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.Time.rawValue)!
            let Updated = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.Updated.rawValue)!
            let Code = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Code.rawValue)!
            let Tsunami = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.Tsunami.rawValue)!
            let Status = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Status.rawValue)!
            let MMI = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.MMI.rawValue)!
            let Felt = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.Felt.rawValue)!
            let Significance = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.Significance.rawValue)!
            let Sequence = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.Sequence.rawValue)!
            let Notified = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.Notified.rawValue)!
            let Region = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.FlatlandRegion.rawValue)!
            let Marked = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.Marked.rawValue)!
            let MagType = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.MagType.rawValue)!
            let MagError = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.MagError.rawValue)!
            let MagNST = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.MagNS.rawValue)!
            let DMin = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.DMin.rawValue)!
            let Alert = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Alert.rawValue)!
            let Title = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Title.rawValue)!
            let Types = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Types.rawValue)!
            let EventType = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.EventType.rawValue)!
            let Detail = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Detail.rawValue)!
            let TZ = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.TZ.rawValue)!
            let EventPageURL = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.EventPageURL.rawValue)!
            let Sources = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Sources.rawValue)!
            let Net = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.Net.rawValue)!
            let NST = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.NST.rawValue)!
            let Gap = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.Gap.rawValue)!
            let IDs = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.IDs.rawValue)!
            let HorizontalError = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.HorizontalError.rawValue)!
            let CDI = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.CDI.rawValue)!
            let RMS = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.RMS.rawValue)!
            let NPH = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.NPH.rawValue)!
            let LocationSource = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.LocationSource.rawValue)!
            let MagSource = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.MagSource.rawValue)!
            let ContextDistance = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: QuakeColumns.ContextDistance.rawValue)!
            let DebugQuake = SQL.ReadIntColumn(Handle: QuakeHandle, Index: QuakeColumns.DebugQuake.rawValue)!
            let QuakeDate = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.QuakeDate.rawValue)!
            let QuakeID = SQL.ReadUUIDColumn(Handle: QuakeHandle, Index: QuakeColumns.QuakeID.rawValue)!
            let EventID = SQL.ReadStringColumn(Handle: QuakeHandle, Index: QuakeColumns.EventID.rawValue)!
            
            let HQuake = Earthquake(PKID)
            HQuake.Latitude = Latitude
            HQuake.Longitude = Longitude
            HQuake.Place = Place
            HQuake.Magnitude = Magnitude
            HQuake.Depth = Depth
            HQuake.Time = Date(timeIntervalSince1970: Time)
            HQuake.Updated = Date(timeIntervalSince1970: Updated)
            HQuake.Code = Code
            HQuake.Tsunami = Tsunami
            HQuake.Status = Status
            HQuake.MMI = MMI
            HQuake.Felt = Felt
            HQuake.Significance = Significance
            HQuake.Sequence = Sequence
            HQuake.Notified = Notified == 0 ? false : true
            HQuake.RegionName = Region
            HQuake.Marked = Marked == 0 ? false : true
            HQuake.MagType = MagType
            HQuake.MagError = MagError
            HQuake.MagNST = MagNST
            HQuake.DMin = DMin
            HQuake.Alert = Alert
            HQuake.Title = Title
            HQuake.Types = Types
            HQuake.EventType = EventType
            HQuake.Detail = Detail
            HQuake.TZ = TZ
            HQuake.EventPageURL = EventPageURL
            HQuake.Sources = Sources
            HQuake.Net = Net
            HQuake.NST = NST
            HQuake.Gap = Gap
            HQuake.IDs = IDs
            HQuake.HorizontalError = HorizontalError
            HQuake.CDI = CDI
            HQuake.RMS = RMS
            HQuake.NPH = NPH
            HQuake.LocationSource = LocationSource
            HQuake.MagSource = MagSource
            HQuake.ContextDistance = ContextDistance
            HQuake.DebugQuake = DebugQuake == 0 ? false : true
            HQuake.ID = QuakeID
            HQuake.EventID = EventID
            
            Results.append(HQuake)
        }
        
        return Results
    }
}