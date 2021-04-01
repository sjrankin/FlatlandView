//
//  CSV.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/31/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Class to write CSV files.
class CSV
{
    /// Dirty flag.
    public static var IsDirty: Bool = false
    
    /// Lock for accessing data.
    private static var CSVLock = NSObject()
    
    /// Clear the stored data in memory. Has no effect on the saved .csv file.
    /// - Note: The caller **must** call `Write` before `Clear` if any data has not yet been saved.
    public static func Clear()
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        IsDirty = false
        CSVData.removeAll()
        _ColumnsSet = false
    }
    
    /// Set the columnar titles.
    /// - Note: **All prviously store data is deleted when calling this function.**
    /// - Parameter ColumnNames: The names of columns for the spreadsheet.
    public static func SetColumns(_ ColumnNames: [String])
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        IsDirty = true
        CSVData = [RowData]()
        let HeaderRow = RowData(ColumnNames)
        CSVData.append(HeaderRow)
        _ColumnsSet = true
    }
    
    /// Columns set flag.
    private static var _ColumnsSet: Bool = false
    
    /// Returns the value of the columns set flag.
    public static var ColumnsSet: Bool
    {
        get
        {
            objc_sync_enter(CSVLock)
            defer{objc_sync_exit(CSVLock)}
            return _ColumnsSet
        }
    }
    
    /// Sets one row of data.
    /// - Parameter RawData: The data to set.
    public static func SetData(_ RawData: RowData)
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        IsDirty = true
        CSVData.append(RawData)
    }
    
    /// Holds the data to save.
    private static var CSVData = [RowData]()
    
    /// Write the data to a text file with the specified name.
    /// - Note: Data is saved to the application's main root directory in the documents directory. While assumed,
    ///         is is not required the extension of the file name ends in `.csv`.
    /// - Parameter Name: The name of the file to save. Specifying the same file name will result in overwriting
    ///                   any files with the same name.
    /// - Parameter With: Delimiter between values. Defaults to "`,`".
    public static func WriteTo(Name: String, With Delimiter: String = ",")
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        if !IsDirty
        {
            return
        }
        IsDirty = false
        var Contents = ""
        for SomeRow in CSVData
        {
            var Row = ""
            for Column in SomeRow.ColumnData
            {
                Row = Row + Column + Delimiter
            }
            Row.removeLast()
            Row = Row + "\n"
            Contents = Contents + Row
        }
        let FileName = Name
        FileIO.WriteString(Contents, To: FileName)
    }
}

/// Contains one row's worth of data. Additionally, used to contain header/columnar data.
class RowData
{
    /// Initializer.
    /// - Parameter RawData: Raw data to add to the row.
    init(_ RawData: String...)
    {
        for OneColumn in RawData
        {
            ColumnData.append(OneColumn)
        }
    }
    
    /// Initializer.
    /// - Parameter RawData: Raw data to add to the row.
    init(_ RawData: [String])
    {
        ColumnData = RawData
    }
    
    /// Contains columnar data for the row.
    var ColumnData = [String]()
}
