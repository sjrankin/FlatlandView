//
//  TodayCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Runs the today UI.
/// - Warning: If no internet connection is available, this dialog should not be run.
class TodayCode: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                 WindowManagement
{
    weak var Main: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SetLocation()
    }
    
    /// Get the proper location to use to show data. The proper location depends on whether the user wants to
    /// see the home location or another location.
    /// - Note: This function calls `reverseGeocodeLocation` and therefore needs internet access. If there is
    ///         no access, some data will not be visible.
    /// - Note: The actual population of the data table and UI elements is done by a call in the closure to the
    ///         call to reverseGeocodeLocation - see `GeocoderCompletion`
    func SetLocation()
    {
        let LocalLat = ShowHomeData ? Settings.GetDoubleNil(.LocalLatitude) : Settings.GetDoubleNil(.DailyLocationLatitude)
        let LocalLon = ShowHomeData ? Settings.GetDoubleNil(.LocalLongitude) : Settings.GetDoubleNil(.DailyLocationLongitude)
        let Loc = CLLocation(latitude: LocalLat!, longitude: LocalLon!)
        let Coder = CLGeocoder()
        Coder.reverseGeocodeLocation(Loc, completionHandler: GeocoderCompletion)
//        SolarNow = SolarToday(For: Date(), Latitude: LocalLat!, Longitude: LocalLon!)
        SolarNow = SolarToday(For: Date(), Latitude: 53.01667, Longitude: 158.65)//51.6014, Longitude: 5.3122)
        {
            Success in
            if Success
            {
                let HourOffset = self.SolarNow.TimezoneSeconds! / (60 * 60)
                let LocalOffset = self.SolarNow.CurrentTimezoneSeconds / (60 * 60)
                let OffsetDelta = LocalOffset - HourOffset
                let AdjustBy = Double(OffsetDelta * 60 * 60 * -1)
                var RiseString = "n/a"
                var SetString = "n/a"
                if let Rise = self.SolarNow.Sunrise
                {
                    RiseString = Date.PrettyTime(From: Rise.addingTimeInterval(AdjustBy))
                }
                if let SetTime = self.SolarNow.Sunset
                {
                    SetString = Date.PrettyTime(From: SetTime.addingTimeInterval(AdjustBy))
                }
                print("SolarNow Sunrise=\(RiseString), Sunset=\(SetString), Timezone offset=\(HourOffset), Local offset=\(LocalOffset)")
            }
        }
    }
    
    var ShowHomeData = true
    var SolarNow: SolarToday! = nil
    
    /// Populate the data needed to display the current (or otherwise specified) data for the location.
    /// This function assumes it is called from the closure that gets the geolocation data.
    func PopulateTable()
    {
        TimeTable.removeAll()
        var LocationString = ""
        var HomeName = ""
        var LocalSunrise = ""
        var LocalSunset = ""
        var LocalNoon = ""
        var SunlightHours = ""
        var SunlightPercent = ""
        let Cal = Calendar.current
        let SunTimes = Sun()
        var LocationAvailable = false
        if ShowHomeData
        {
            if Settings.GetDoubleNil(.LocalLatitude) != nil && Settings.GetDoubleNil(.LocalLongitude) != nil
            {
                LocationAvailable = true
            }
        }
        else
        {
            if Settings.GetDoubleNil(.DailyLocationLatitude) != nil && Settings.GetDoubleNil(.DailyLocationLongitude) != nil
            {
                LocationAvailable = true
            }
        }
        if LocationAvailable
        {
            if ShowHomeData
            {
                HomeName = Settings.GetString(.LocalName, "")
            }
            else
            {
                HomeName = Settings.GetString(.DailyLocationName, "")
            }
            LocationNote.stringValue = ""
            var RiseAndSetAvailable = true
            var SunRiseTime = Date()
            var SunSetTime = Date()
            let LocalLat = ShowHomeData ? Settings.GetDoubleNil(.LocalLatitude) : Settings.GetDoubleNil(.DailyLocationLatitude)
            let LocalLon = ShowHomeData ? Settings.GetDoubleNil(.LocalLongitude) : Settings.GetDoubleNil(.DailyLocationLongitude)
            let Location = GeoPoint(LocalLat!, LocalLon!)
            let LatS = LocalLat! >= 0.0 ? "\(LocalLat!.RoundedTo(4))N" : "\(abs(LocalLat!).RoundedTo(4))S"
            let LonS = LocalLon! >= 0.0 ? "\(LocalLon!.RoundedTo(4))E" : "\(abs(LocalLon!).RoundedTo(4))W"
            LocationString = "\(LatS), \(LonS)"
            let TZSeconds = TimeZoneSeconds ?? 0
            //print("TZSeconds=\(TZSeconds), Date=\(Date())")
            
            let TimeStringAtLocation = DateToTimeZoneDate(Date(), Timezone: TimeZone(secondsFromGMT: TZSeconds)!)
            let (DateString, TimeString) = ParseTimeZoneDate(TimeStringAtLocation)
            let AdjustedDate = StringDateToDate(DateString, TimeString)
            //print("***>> \(DateString), \(TimeString) = \(AdjustedDate!)")

            #if true
            let DateToUse = AdjustedDate!
            //print("** DateToUse=\(DateToUse), Date=\(Date())")
            #else
            let DateToUse = Date()
            #endif

                //print("TimeZoneTime: \(DateToTimeZoneDate(Date(), Timezone: TimeZone(secondsFromGMT: TZSeconds)!))")
                if let SunriseTime = SunTimes.Sunrise(For: DateToUse, At: Location, TimeZoneOffset: 0)
                {
                    SunRiseTime = SunriseTime
                    LocalSunrise = SunriseTime.PrettyTime()
                }
                else
                {
                    RiseAndSetAvailable = false
                    LocalSunrise = "No sunrise"
                }
                if let SunsetTime = SunTimes.Sunset(For: DateToUse, At: Location, TimeZoneOffset: 0)
                {
                    SunSetTime = SunsetTime
                    LocalSunset = SunsetTime.PrettyTime()
                }
                else
                {
                    RiseAndSetAvailable = false
                    LocalSunset = "No sunset"
                }

            if RiseAndSetAvailable
            {
                let RiseHour = Cal.component(.hour, from: SunRiseTime)
                let RiseMinute = Cal.component(.minute, from: SunRiseTime)
                let RiseSecond = Cal.component(.second, from: SunRiseTime)
                let SetHour = Cal.component(.hour, from: SunSetTime)
                let SetMinute = Cal.component(.minute, from: SunSetTime)
                let SetSecond = Cal.component(.second, from: SunSetTime)
                let RiseSeconds = RiseSecond + (RiseMinute * 60) + (RiseHour * 60 * 60)
                let SetSeconds = SetSecond + (SetMinute * 60) + (SetHour * 60 * 60)
                let SecondDelta = SetSeconds - RiseSeconds
                let NoonTime = RiseSeconds + (SecondDelta / 2)
                let (NoonHour, NoonMinute, NoonSecond) = Date.SecondsToTime(NoonTime)
                let HourS = "\(NoonHour)"
                let MinuteS = (NoonMinute < 10 ? "0" : "") + "\(NoonMinute)"
                let SecondS = (NoonSecond < 10 ? "0" : "") + "\(NoonSecond)"
                LocalNoon = "\(HourS):\(MinuteS):\(SecondS)"
                let SunlightSeconds = SetSeconds - RiseSeconds + 1
                SunlightHours = Utility.MakePrettyElapsedTime(SunlightSeconds, AppendSeconds: true)
                let SunPercent = Double(SunlightSeconds) / Double(24.0 * 60.0 * 60.0) * 100.0
                SunlightPercent = "\(SunPercent.RoundedTo(2))"
            }
            else
            {
                LocalNoon = ""
            }
        }
        else
        {
            HomeName = "N/A"
            LocationString = "Not set"
            LocalSunset = "N/A"
            LocalSunrise = "N/A"
            LocalNoon = "N/A"
            SunlightHours = "N/A"
            SunlightPercent = ""
        }
        
        TimeTable.append(("Location", HomeName))
        TimeTable.append(("Country", GeoCountry))
        TimeTable.append(("Coordinates", LocationString))
        TimeTable.append(("Time at Location", ""))
        TimeTable.append(("Time Zone", GeoTimeZone))
        TimeTable.append(("Local Sunrise", LocalSunrise))
        TimeTable.append(("Local Noon", LocalNoon))
        TimeTable.append(("Local Sunset", LocalSunset))
        TimeTable.append(("Daylight Hours", "\(SunlightHours)"))
        TimeTable.append(("Daylight Percent", "\(SunlightPercent)%"))
        
        let DaysDeclination = Sun.Declination(For: Date())
        let DeclinationLabel = "\(DaysDeclination.RoundedTo(4))°"
        TimeTable.append(("Declination", DeclinationLabel))
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(UpdateCurrentSeconds),
                                     userInfo: nil, repeats: true)
        TimeTable.append(("Seconds Elapsed",""))
        UpdateCurrentSeconds()
    }
    
    var TimeZoneSeconds: Int? = nil
    
    /// Close for server call to reverse locate a coordinate.
    /// - Parameter Placemarks: Array of placemarks related to the coordinates passed to the original call.
    /// - Parameter Err: Errors, if any.
    func GeocoderCompletion(_ Placemarks: [CLPlacemark]?, _ Err: Error?)
    {
        if let PM = Placemarks?[0]
        {
            let CountryName = PM.country ?? "unknown"
            let TimeZoneDescription = PM.timeZone?.description ?? "unknown"
            let Offset = PM.timeZone?.secondsFromGMT()
            GeoCountry = CountryName
            var OffsetString = ""
            if let TZOffset = Offset
            {
                let OffsetValue = TZOffset / (60 * 60)
                var OffsetSign = ""
                if OffsetValue > 0
                {
                    OffsetSign = "+"
                }
                OffsetString = "\(OffsetSign)\(OffsetValue)"
            }
            GeoTimeZone = "\(CleanupTimezone(TimeZoneDescription)) \(OffsetString)"
            if let TZ = PM.timeZone
            {
                TimeZoneSeconds = TZ.secondsFromGMT(for: Date())
                print("TimeZoneSeconds=\(TimeZoneSeconds!)")
            }
        }
        PopulateTable()
        TodayTable.reloadData()
    }
    
    func CleanupTimezone(_ Raw: String) -> String
    {
        let Parts = Raw.split(separator: "(", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return Raw
        }
        let CleanedUp = String(Parts[0]).trimmingCharacters(in: .whitespaces)
        return CleanedUp
    }
    
    var GeoCountry: String = ""
    var GeoTimeZone: String = ""
    
    @objc func UpdateCurrentSeconds()
    {
        guard let TZSeconds = TimeZoneSeconds else
        {
            return
        }
        var Cal = Calendar.current
        Cal.timeZone = TimeZone(secondsFromGMT: TZSeconds)!
        let H = Cal.component(.hour, from: Date())
        let M = Cal.component(.minute, from: Date())
        let S = Cal.component(.second, from: Date())
        let CurrentSeconds = S + (M * 60) + (H * 60 * 60)
        if let Index = IndexOfRow(With: "Seconds Elapsed")
        {
            let Percent = Double(CurrentSeconds) / (24.0 * 60.0 * 60.0) * 100.0
            TimeTable[Index] = ("Seconds Elapsed", "\(CurrentSeconds)\t\t\(Percent.RoundedTo(2))%")
        }
        if let TimeIndex = IndexOfRow(With: "Time at Location")
        {
            if let TZ = TimeZone(secondsFromGMT: TZSeconds)
            {
                let TimeStringAtLocation = DateToTimeZoneDate(Date(), Timezone: TZ)
                let (DateString, TimeString) = ParseTimeZoneDate(TimeStringAtLocation)
                let Final = "\(TimeString)\t\(DateString)"
                TimeTable[TimeIndex] = ("Time at Location", Final)
            }
        }
        TodayTable.reloadData()
    }
    
    func ParseDateString(_ Raw: String) -> (Day: Int, Month: Int, Year: Int)?
    {
        let Parts = Raw.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            return nil
        }
        guard let Day = Int(String(Parts[0])) else
        {
            return nil
        }
        guard let Year = Int(String(Parts[2])) else
        {
            return nil
        }
        guard let Month = ShortMonths.firstIndex(of: String(Parts[1])) else
        {
            return nil
        }
        return (Day, Month, Year)
    }
    
    func ParseTimeString(_ Raw: String) -> (Hour: Int, Minute: Int, Seconds: Int)?
    {
        let Parts = Raw.split(separator: ":", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            return nil
        }
        guard let Hour = Int(String(Parts[0])) else
        {
            return nil
        }
        guard let Minute = Int(String(Parts[1])) else
        {
            return nil
        }
        guard let Seconds = Int(String(Parts[2])) else
        {
            return nil
        }
        return (Hour, Minute, Seconds)
    }
    
    func StringDateToDate(_ DateString: String, _ TimeString: String) -> Date?
    {
        guard let (Day, Month, Year) = ParseDateString(DateString) else
        {
            return nil
        }
        guard let (Hour, Minute, Seconds) = ParseTimeString(TimeString) else
        {
            return nil
        }
        var Components = DateComponents()
        Components.year = Year
        Components.month = Month - 1
        Components.day = Day
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Seconds
        if let TZSeconds = TimeZoneSeconds
        {
            Components.timeZone = TimeZone(secondsFromGMT: TZSeconds)
        }
        var Final = Calendar.current.date(from: Components)
        if let TZSeconds = TimeZoneSeconds
        {
            Final = Final?.addingTimeInterval(Double(TZSeconds))
        }
        return Final
    }
    
    let ShortMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    func ParseTimeZoneDate(_ Raw: String) -> (DateString: String, TimeString: String)
    {
        let Parts = Raw.split(separator: "T", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            Debug.FatalError("Invalid date string passed to \(#function)")
        }
        
        let DatePart = String(Parts[0])
        let DateParts = DatePart.split(separator: "-", omittingEmptySubsequences: true)
        if DateParts.count != 3
        {
            Debug.FatalError("Error parsing date in \(#function)")
        }
        let YearPart = String(DateParts[0])
        let MonthPart = String(DateParts[1])
        let DayPart = String(DateParts[2])
        guard let MonthValue = Int(MonthPart) else
        {
            Debug.FatalError("Error converting month value \(MonthPart) to Int in \(#function)")
        }
        if MonthValue < 1 || MonthValue > 12
        {
            Debug.FatalError("Invalid month value: \(MonthValue) in \(#function)")
        }
        let MonthName = ShortMonths[MonthValue - 1]
        let FinalDateString = "\(DayPart) \(MonthName) \(YearPart)"
        
        let TimePart = String(Parts[1])
        let TimeParts = TimePart.split(separator: "+", omittingEmptySubsequences: true)
        if TimeParts.count != 2
        {
            Debug.FatalError("Invalid time string apssed to \(#function)")
        }
        let FinalTime = String(TimeParts[0])
        
        return (DateString: FinalDateString, TimeString: FinalTime)
    }
    
    func DateToTimeZoneDate(_ When: Date, Timezone: TimeZone) -> String
    {
        let DFormatter = DateFormatter()
        DFormatter.timeZone = Timezone
        DFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let StringDate = DFormatter.string(from: When)
        return StringDate
    }
    
    func ToOtherDate(Timezone: TimeZone) -> Date
    {
        let DFormatter = DateFormatter()
        DFormatter.timeZone = Timezone
        DFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let Other = DFormatter.date(from: DateToTimeZoneDate(Date(), Timezone: Timezone))!
        return Other
    }
    
    func IndexOfRow(With Title: String) -> Int?
    {
        for Index in 0 ..< TimeTable.count
        {
            if TimeTable[Index].Event == Title
            {
                return Index
            }
        }
        return nil
    }
    
    var TimeTable = [(Event: String, Value: String)]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return TimeTable.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 26.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var IsValue = false
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "EventColumn"
            CellContents = TimeTable[row].Event
        }
        
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "WhenColumn"
            CellContents = TimeTable[row].Value
            IsValue = true
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if IsValue
        {
            Cell?.textField?.font = NSFont.boldSystemFont(ofSize: 16.0)
        }
        else
        {
            Cell?.textField?.font = NSFont.systemFont(ofSize: 16.0)
        }
        return Cell
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleSetHomeLocationButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Today", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "LocationWindow") as? LocationWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? LocationController
            Controller?.IsForHomeLocation = true
            self.view.window?.beginSheet(Window!)
            {
                Result in
                if Result == .OK
                {
                    self.ShowHomeData = true
                    self.SetLocation()
                }
            }
        }
    }
    
    @IBAction func HandleUseOtherLocationButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Today", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "LocationWindow") as? LocationWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? LocationController
            Controller?.IsForHomeLocation = false
            self.view.window?.beginSheet(Window!)
            {
                Result in
                if Result == .OK
                {
                    self.ShowHomeData = false
                    self.SetLocation()
                }
            }
        }
    }
    
    @IBAction func HandleLocationChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.selectedSegment == 0
            {
                ShowHomeData = true
            }
            else
            {
                ShowHomeData = false
            }
            SetLocation()
        }
    }
    
    @IBOutlet weak var LocationNote: NSTextField!
    @IBOutlet weak var TodayTable: NSTableView!
}
