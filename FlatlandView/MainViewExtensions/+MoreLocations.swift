//
//  +MoreLocations.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

extension MainView
{
    /// Initialize the world heritage site database.
    /// - Warning: A fatal error is generated on error.
    public static func InitializeWorldHeritageSites()
    {
        if UnescoInitialized
        {
            return
        }
        UnescoInitialized = true
        if let UnescoURL = FileIO.GetUnescoDatabaseURL()
        {
            if sqlite3_open_v2(UnescoURL.path, &MainView.UnescoHandle,
                               SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
            {
                fatalError("Error opening \(UnescoURL.path), \(String(cString: sqlite3_errmsg(MainView.UnescoHandle!)))")
            }
        }
        else
        {
            fatalError("Error getting URL for Unesco database.")
        }
    }
    
    /// Return the number of Unesco world heritage sites in the database.
    /// - Returns: Number of world heritage sites in the database.
    func SiteCount() -> Int
    {
        let GetCount = "SELECT COUNT(*) FROM Sites"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(MainView.UnescoHandle, GetCount, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return Int(Count)
            }
        }
        print("Error returned when preparing \"\(GetCount)\"")
        return 0
    }
    
    /// Return all Unesco world heritage site information.
    /// - Returns: Array of world heritage sites.
    func GetAllSites() -> [WorldHeritageSite]
    {
        return MainView.GetAllSites()
    }
    
    /// Return all Unesco world heritage site information.
    /// - Returns: Array of world heritage sites.
    public static func GetAllSites() -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        let GetQuery = "SELECT * FROM Sites"
        let QueryHandle = SetupQuery(DB: UnescoHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let UID = Int(sqlite3_column_int(QueryHandle, 0))
            let ID = Int(sqlite3_column_int(QueryHandle, 1))
            let Name = String(cString: sqlite3_column_text(QueryHandle, 2))
            let Year = Int(sqlite3_column_int(QueryHandle, 3))
            let Longitude = Double(sqlite3_column_double(QueryHandle, 4))
            let Latitude = Double(sqlite3_column_double(QueryHandle, 5))
            let Hectares = Double(sqlite3_column_double(QueryHandle, 6))
            let Category = String(cString: sqlite3_column_text(QueryHandle, 7))
            let ShortCategory = String(cString: sqlite3_column_text(QueryHandle, 8))
            let Countries = String(cString: sqlite3_column_text(QueryHandle, 9))
            let Site = WorldHeritageSite(UID, ID, Name, Year, Latitude, Longitude, Hectares,
                                         Category, ShortCategory, Countries)
            Results.append(Site)
        }
        MainView.LastReadList = Results
        return Results
    }
    
    /// Set up a query in to the database.
    /// - Parameter DB: The handle of the database for the query.
    /// - Parameter Query: The query string.
    /// - Returns: Handle for the query. Valid only for the same database the query was generated for.
     static func SetupQuery(DB: OpaquePointer?, Query: String) -> OpaquePointer?
    {
        if DB == nil
        {
            return nil
        }
        if Query.isEmpty
        {
            return nil
        }
        var QueryHandle: OpaquePointer? = nil
        if sqlite3_prepare(DB, Query, -1, &QueryHandle, nil) != SQLITE_OK
        {
            let LastSQLErrorMessage = String(cString: sqlite3_errmsg(DB))
            print("Error preparing query \"\(Query)\": \(LastSQLErrorMessage)")
            return nil
        }
        return QueryHandle
    }
    
    private static var LastReadList = [WorldHeritageSite]()
    
    /// Returns the last read set of World Heritage Sites.
    /// - Returns: Array of World Heritage Sites.
    public static func GetLastReadList() -> [WorldHeritageSite]
    {
        return LastReadList
    }
    
    /// Returns a list of all unique county names in the passed set of world heritage sites.
    /// - Parameter FromSites: List of world heritage sites.
    /// - Returns: Array of unique country names derived from the passed list of sites.
    public static func WorldHeritageCountryList(_ FromSites: [WorldHeritageSite]) -> [String]
    {
        var CountrySet = Set<String>()
        for Site in FromSites
        {
            CountrySet.insert(Site.Countries)
        }
        return Array(CountrySet).sorted()
    }
    
    /// Returns a list of all unique inscription years in the passed set of world heritage sites.
    /// - Parameter FromSites: List of world heritage sites.
    /// - Returns: Array of unique inscription years derived from the passed list of sites.
    public static func WorldHeritageInscriptionDates(_ FromSites: [WorldHeritageSite]) -> [Int]
    {
        var YearSet = Set<Int>()
        for Site in FromSites
        {
            YearSet.insert(Site.DateInscribed)
        }
        return Array(YearSet).sorted()
    }
    
    /// Filter a set of World Heritage Sites by country.
    /// - Parameter Sites: The set of World Heritage Sites to filter.
    /// - Parameter ByCountry: The country to return. Case senstive. If empty, all countries are returned.
    /// - Returns: List of World Heritage Sites filtered by the supplied parameters.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite], ByCountry: String) -> [WorldHeritageSite]
    {
        if ByCountry.isEmpty
        {
            return Sites
        }
        var Results = [WorldHeritageSite]()
        for Site in Sites
        {
            if Site.Countries == ByCountry
            {
                Results.append(Site)
            }
        }
        return Results
    }
    
    /// Filter a set of World Heritage Sites by date inscribed.
    /// - Parameter Sites: The set of World Heritage Sites to filter.
    /// - Parameter ByYear: The year to filter by. If nil, all World Heritage Sites are returned.
    /// - Parameter YearFilter: How to use `ByYear` when filtering sites.
    /// - Returns: List of World Heritage Sites filtered by the supplied parameters.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite], ByYear: Int? = nil,
                                                YearFilter: YearFilters) -> [WorldHeritageSite]
    {
        if let Year = ByYear
        {
            var Results = [WorldHeritageSite]()
            for Site in Sites
            {
                switch YearFilter
                {
                    case .Only:
                        if Site.DateInscribed == Year
                        {
                            Results.append(Site)
                    }
                    
                    case .UpTo:
                        if Site.DateInscribed <= Year
                        {
                            Results.append(Site)
                    }
                    
                    case .After:
                        if Site.DateInscribed >= Year
                        {
                            Results.append(Site)
                    }
                    
                    case .All:
                        Results.append(Site)
                }
            }
            return Results
        }
        else
        {
            return Sites
        }
    }
    
    /// Filter a set of World Heritage Sites by site type.
    /// - Parameter Sites: The set of World Heritage Sites to filter.
    /// - Parameter ByType: The type of stie to return.
    /// - Returns: List of World Heritage Sites filtered by the supplied parameters.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite], ByType: SiteTypeFilters) -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        for Site in Sites
        {
            switch ByType
            {
                case .Both:
                    if Site.Category == "Mixed"
                    {
                        Results.append(Site)
                }
                
                case .Cultural:
                    if Site.Category == "Cultural"
                    {
                        Results.append(Site)
                }
                
                case .Natural:
                    if Site.Category == "Natural"
                    {
                        Results.append(Site)
                }
                
                case .Either:
                    Results.append(Site)
            }
        }
        return Results
    }
    
    /// Apply multiple filters to the source list of World Heritage Sites.
    /// - Note: Filters are applied in this order:
    ///        1 Site type.
    ///        2 Site country.
    ///        3 Site inscribed year.
    /// - Parameter Sites: Source list to filter.
    /// - Parameter ByType: The type of site to return.
    /// - Parameter ByCountry: The country of the site.
    /// - Parameter ByYear: The year the site was inscribed.
    /// - Parameter WithYearFilter: How to filter the year.
    /// - Returns: List of sites that meet all passed criteria.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite],
                                                ByType: SiteTypeFilters,
                                                ByCountry: String,
                                                ByYear: Int?,
                                                WithYearFilter: YearFilters) -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        Results = FilterWorldHeritageSites(Sites, ByType: ByType)
        Results = FilterWorldHeritageSites(Results, ByCountry: ByCountry)
        Results = FilterWorldHeritageSites(Results, ByYear: ByYear, YearFilter: WithYearFilter)
        return Results
    }
    
    /// Applies all currently saved World Heritage Site filters to the passed list of World Heritage
    /// Sites and returns the result.
    /// - Parameter Sites: The list of World Heritage Sites to filter.
    /// - Returns: Filtered result.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite]) -> [WorldHeritageSite]
    {
        #if true
        let SiteType = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: SiteTypeFilters.self, Default: .Either)
        let SiteCountry = Settings.GetString(.SiteCountry, "")
        let SiteYear = Settings.GetInt(.SiteYear)
        let SiteYearFilter = Settings.GetEnum(ForKey: .SiteYearFilter, EnumType: YearFilters.self, Default: .All)
        #else
        let SiteType = Settings.GetWorldHeritageSiteTypeFilter()
        let SiteCountry = Settings.GetWorldHeritageSiteCountry()
        let SiteYear = Settings.GetWorldHeritageSiteInscribedYear()
        let SiteYearFilter = Settings.GetWorldHeritageSiteInscribedYearFilter()
        #endif
        return FilterWorldHeritageSites(Sites,
                                        ByType: SiteType,
                                        ByCountry: SiteCountry,
                                        ByYear: SiteYear,
                                        WithYearFilter: SiteYearFilter)
    }
}
