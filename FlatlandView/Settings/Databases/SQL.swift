//
//  SQL.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/9/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

/// Utility class to make using SQLite3 more Swift-like.
class SQL
{
    /// Setup a query to access a database.
    /// - Parameter For: The database handle to the database to query.
    /// - Parameter Query: The query string.
    /// - Returns: Result for the operation. On success, the query's handle (non-optional) is returned.
    public static func SetupQuery(For Database: OpaquePointer?, Query: String) -> Result<OpaquePointer, DatabaseOperationResult>
    {
        if Database == nil
        {
            return .failure(.NilDatabase)
        }
        if Query.isEmpty
        {
            return .failure(.EmptyQuery)
        }
        var QueryHandle: OpaquePointer? = nil
        if sqlite3_prepare(Database, Query, -1, &QueryHandle, nil) != SQLITE_OK
        {
            LastSQLErrorMessage = String(cString: sqlite3_errmsg(Database))
            return .failure(.QueryPreparationError)
        }
        if QueryHandle == nil
        {
            return .failure(.BadQueryHandleReturned)
        }
        return .success(QueryHandle!)
    }
    
    /// Return the extended error message and value.
    /// - Parameter From: The handle of the database where the error occurred.
    /// - Returns: Tuple with the error message and error value.
    public static func ExtendedError(From: OpaquePointer?) -> (String, Int32)
    {
        let ExErrorCode = sqlite3_extended_errcode(From)
        var Message = ""
        if let CMessage = sqlite3_errmsg(From)
        {
         Message = String(cString: CMessage)
        }
        return (Message, ExErrorCode)
    }
    
    public static var LastSQLErrorMessage: String = ""
    
    /// Return the number of rows in a database table.
    /// - Parameter Database: Handle to the database with the table to count.
    /// - Parameter Table: Name of the table to count rows.
    /// - Returns: Result with the number of rows.
    public static func RowCount(Database Handle: OpaquePointer?, Table Name: String) -> Result<Int, DatabaseOperationResult>
    {
        let GetCount = "SELECT COUNT (*) FROM \(Name)"
        let QuerySetupResult = SetupQuery(For: Handle, Query: GetCount)
        switch QuerySetupResult
        {
            case .success(let CountQuery):
                while sqlite3_step(CountQuery) == SQLITE_ROW
                {
                    let Count = sqlite3_column_int(CountQuery, 0)
                    return .success(Int(Count))
                }
                
            case .failure(let Failure):
                return .failure(.ErrorGettingRowCount)
        }
        return .failure(.ErrorGettingRowCount)
    }
    
    // MARK: - String-related functions
    
    /// Remove apostrophe ("`'`") characters from the passed string.
    /// - Parameter From: The string from which apostrophes will be removed.
    /// - Returns: String wil all apostrophes removed.
    public static func RemoveApostrophes(From: String) -> String
    {
        var Working = From
        let Forbidden: Set<Character> = ["'"]
        Working.removeAll(where: {Forbidden.contains($0)})
        return Working
    }
    
    /// Add the SQLite escape character to characters that need to be escaped.
    /// - Parameter To: The string which will be escaped.
    /// - Returns: New string with proper escaping.
    public static func AddEscapes(To: String) -> String
    {
        var NewString = ""
        if To.contains("'")
        {
            for Char in To
            {
                if Char == String.Element("'")
                {
                    NewString.append("\\")
                    NewString.append(Char)
                }
                else
                {
                    NewString.append(Char)
                }
            }
        }
        else
        {
            return To
        }
        return NewString
    }
    
    /// Creates a Sqlite column list.
    /// - Parameter Names: Names to add to the list.
    /// - Returns: String in the format `({name1}, {name2}...)`.
    public static func MakeColumnList(_ Names: [String]) -> String
    {
        var List = "("
        for Index in 0 ..< Names.count
        {
            List.append(Names[Index])
            if Index < Names.count - 1
            {
                List.append(", ")
            }
        }
        List.append(")")
        return List
    }
    
    // MARK: - Column reading functions.
    
    /// Read an integer from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the integer value to read.
    /// - Returns: Integer value at the specific column. Nil on error.
    public static func ReadIntColumn(Handle: OpaquePointer?, Index: Int32) -> Int?
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value
    }
    
    /// Read an integer from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the integer value to read.
    /// - Parameter Default: Default value to return on error. Defaults to `0`.
    /// - Returns: Integer value at the specific column.
    public static func ReadIntColumn(Handle: OpaquePointer?, Index: Int32, Default: Int = 0) -> Int
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value
    }
    
    /// Read a double from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the double value to read.
    /// - Returns: Double value at the specific column. Nil on error.
    public static func ReadDoubleColumn(Handle: OpaquePointer?, Index: Int32) -> Double?
    {
        let Value = sqlite3_column_double(Handle, Index)
        return Value
    }
    
    /// Read a double from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the double value to read.
    /// - Parameter Default: Default value to return on error. Defaults to `0.0`.
    /// - Returns: Double value at the specific column.
    public static func ReadDoubleColumn(Handle: OpaquePointer?, Index: Int32, Default: Double = 0.0) -> Double
    {
        let Value = sqlite3_column_double(Handle, Index)
        return Value
    }
    
    /// Read a boolean from a SQLite table.
    /// - Note: Booleans are stored as integers. A value of `0` is false and any other value is true.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the boolean value to read.
    /// - Returns: Double value at the specific boolean. Nil on error.
    public static func ReadBoolColumn(Handle: OpaquePointer?, Index: Int32) -> Bool?
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value > 0 ? true : false
    }
    
    /// Read a boolean from a SQLite table.
    /// - Note: Booleans are stored as integers. A value of `0` is false and any other value is true.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the boolean value to read.
    /// - Parameter Default: Default value to return on error. Defaults to `true`.
    /// - Returns: Double value at the specific boolean.
    public static func ReadBoolColumn(Handle: OpaquePointer?, Index: Int32, Default: Bool = true) -> Bool
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value > 0 ? true : false
    }
    
    /// Read a string from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the string value to read.
    /// - Returns: String value at the specific column. Nil on error.
    public static func ReadStringColumn(Handle: OpaquePointer?, Index: Int32) -> String?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            return Value
        }
        return nil
    }
    
    /// Read a string from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the string value to read.
    /// - Parameter Default: The default value to return on error.
    /// - Returns: String value at the specific column. Nil on error.
    public static func ReadStringColumn(Handle: OpaquePointer?, Index: Int32, Default: String = "") -> String
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            return Value
        }
        return Default
    }
    
    /// Read a UUID from a SQLite table.
    /// - Note: UUIDs are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the UUID value to read.
    /// - Returns: UUID value at the specific column. Nil on error.
    public static func ReadUUIDColumn(Handle: OpaquePointer?, Index: Int32) -> UUID?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let UValue = UUID(uuidString: Value)
            {
                return UValue
            }
        }
        return nil
    }
    
    /// Read a UUID from a SQLite table.
    /// - Note: UUIDs are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the UUID value to read.
    /// - Parameter Default: The default value to return on error.
    /// - Returns: UUID value at the specific column.
    public static func ReadUUIDColumn(Handle: OpaquePointer?, Index: Int32, Default: UUID = UUID()) -> UUID
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let UValue = UUID(uuidString: Value)
            {
                return UValue
            }
        }
        return Default
    }
    
    /// Read a date from a SQLite table.
    /// - Note: Dates are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the date value to read.
    /// - Returns: Date value at the specific column. Nil on error.
    public static func ReadDateColumn(Handle: OpaquePointer?, Index: Int32) -> Date?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = Date.PrettyDateToDate(Value)
            {
                return Final
            }
        }
        return nil
    }
    
    /// Read a date from a SQLite table.
    /// - Note: Dates are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the date value to read.
    /// - Parameter Default: The default value to return on error.
    /// - Returns: Date value at the specific column.
    public static func ReadDateColumn(Handle: OpaquePointer?, Index: Int32, Default: Date = Date()) -> Date
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = Date.PrettyDateToDate(Value)
            {
                return Final
            }
        }
        return Default
    }
    
    /// Read a color from a SQLite table.
    /// - Note: Colors are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the color value to read.
    /// - Returns: Color value at the specific column. Nil on error.
    public static func ReadColorColumn(Handle: OpaquePointer?, Index: Int32) -> NSColor?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = NSColor(HexString: Value)
            {
                return Final
            }
        }
        return nil
    }
    
    /// Read a color from a SQLite table.
    /// - Note: Colors are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the color value to read.
    /// - Parameter Default: The default value to return on error. Defaults to `NSColor.gray`.
    /// - Returns: Color value at the specific column.
    public static func ReadColorColumn(Handle: OpaquePointer?, Index: Int32, Default: NSColor = NSColor.gray) -> NSColor
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = NSColor(HexString: Value)
            {
                return Final
            }
        }
        return Default
    }
}

enum DatabaseOperationResult: String, CaseIterable, Error
{
    case Success = "Success"
    case QueryPreparationError = "Query preparation error"
    case BadQueryHandleReturned = "Bad query handle returned"
    case NilDatabase = "Database handle is nil"
    case EmptyQuery = "Query is empty"
    case ErrorGettingRowCount = "Error preparing for getting row count"
}
