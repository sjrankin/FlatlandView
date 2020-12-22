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
        TimeTable.removeAll()
        let LocalLat = ShowHomeData ? Settings.GetDoubleNil(.UserHomeLatitude) : Settings.GetDoubleNil(.DailyLocationLatitude)
        let LocalLon = ShowHomeData ? Settings.GetDoubleNil(.UserHomeLongitude) : Settings.GetDoubleNil(.DailyLocationLongitude)
        SolarNow = SolarToday(For: Date(), Latitude: LocalLat!, Longitude: LocalLon!,
                              HaveNewLocationData(_:_:_:_:_:_:_:_:_:_:_:))
    }
    
    /// New location received from `SolarToday`.
    /// - Parameters:
    ///   - Success: If true, data was returned successfull. If false, there was an error.
    ///   - Sunrise: Sunrise for the data and location.
    ///   - Sunset: Sunset for the data and locatoin.
    ///   - Country: Country for the location.
    ///   - TimezoneName: Name of the time zone for the location.
    ///   - TimezoneSeconds: Seconds offset for the location's timezone from GMT.
    ///   - CurrentTimeZoneSeconds: Seconds offset for the current (eg, computer's) location's timezone from GMT.
    ///   - TestDate: The date used for calculations. Returned for reference.
    ///   - Latitude: The latitude used for calculations. Returned for reference.
    ///   - Longitude: The longitude used for calculations. Returned for reference.
    ///   - OtherData: Other data returned from Apple's servers not strictly necessary for the purpose of
    ///                the dialog.
    func HaveNewLocationData(_ Success: Bool, _ Sunrise: Date?, _ Sunset: Date?, _ Country: String,
                             _ TimezoneName: String, _ TimezoneSeconds: Int, _ CurrentTimeZoneSeconds: Int,
                             _ TestDate: Date, _ Latitude: Double, _ Longitude: Double, _ OtherData: LocationData?)
    {
        if Success
        {
            self.TimeZoneSeconds = TimezoneSeconds
            LocationNote.stringValue = ""
            TimeTable.removeAll()
            let HomeName = ShowHomeData ? Settings.GetString(.UserHomeName, "") : Settings.GetString(.DailyLocationName, "")
            let LatS = Latitude >= 0.0 ? "\(Latitude.RoundedTo(4))N" : "\(abs(Latitude).RoundedTo(4))S"
            let LonS = Longitude >= 0.0 ? "\(Longitude.RoundedTo(4))E" : "\(abs(Longitude).RoundedTo(4))W"
            let LocationString = "\(LatS), \(LonS)"
            var LocalNoon = ""
            var SunlightHours = ""
            var SunlightPercent = ""
            var RiseTime = Date()
            var SetTime = Date()
            let HourOffset = TimezoneSeconds / (60 * 60)
            let LocalOffset = CurrentTimeZoneSeconds / (60 * 60)
            let OffsetDelta = LocalOffset - HourOffset
            let AdjustBy = Double(OffsetDelta * 60 * 60 * -1)
            var RiseAndSetAvailable = true
            var RiseString = "N/A"
            var SetString = "N/A"
            var RiseTimeForNoon = Date()
            var SetTimeForNoon = Date()
            if let RiseTimeActual = Sunrise
            {
                RiseTime = RiseTimeActual
                RiseTimeForNoon = RiseTime.addingTimeInterval(AdjustBy)
                RiseString = Date.PrettyTime(From: RiseTimeForNoon)
            }
            else
            {
                RiseAndSetAvailable = false
            }
            if let SetTimeActual = Sunset
            {
                SetTime = SetTimeActual
                SetTimeForNoon = SetTime.addingTimeInterval(AdjustBy)
                SetString = Date.PrettyTime(From: SetTimeForNoon)
            }
            else
            {
                RiseAndSetAvailable = false
            }
            if RiseAndSetAvailable
            {
                let Cal = Calendar.current
                let RiseHour = Cal.component(.hour, from: RiseTimeForNoon)
                let RiseMinute = Cal.component(.minute, from: RiseTimeForNoon)
                let RiseSecond = Cal.component(.second, from: RiseTimeForNoon)
                let SetHour = Cal.component(.hour, from: SetTimeForNoon)
                let SetMinute = Cal.component(.minute, from: SetTimeForNoon)
                let SetSecond = Cal.component(.second, from: SetTimeForNoon)
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
            TimeTable.append(("Location", HomeName))
            if let AdminArea = OtherData?.AdministrativeArea
            {
                if AdminArea != HomeName
                {
                    TimeTable.append(("Administrative", AdminArea))
                }
            }
            if let SubAdminArea = OtherData?.SubAdministrativeArea
            {
                if SubAdminArea != HomeName
                {
                    TimeTable.append(("Sub-Administrative", SubAdminArea))
                }
            }
            if let Locality = OtherData?.Locality
            {
                if Locality != HomeName
                {
                    TimeTable.append(("Locality", Locality))
                }
            }
            if let SubLocality = OtherData?.SubLocality
            {
                if SubLocality != HomeName
                {
                    TimeTable.append(("Sub-Locality", SubLocality))
                }
            }
            if let Inland = OtherData?.InlandWater
            {
                TimeTable.append(("Inland Water", Inland))
            }
            if let Ocean = OtherData?.Ocean
            {
                TimeTable.append(("Ocean", Ocean))
            }
            TimeTable.append(("Country", Country))
            TimeTable.append(("Coordinates", LocationString))
            TimeTable.append(("Time at Location", ""))
            TimeTable.append(("Time Zone", TimezoneName))
            TimeTable.append(("Local Sunrise", RiseString))
            TimeTable.append(("Local Noon", LocalNoon))
            TimeTable.append(("Local Sunset", SetString))
            TimeTable.append(("Daylight Hours", "\(SunlightHours)"))
            TimeTable.append(("Daylight Percent", "\(SunlightPercent)%"))
            let DaysDeclination = Sun.Declination(For: Date())
            let DeclinationLabel = "\(DaysDeclination.RoundedTo(4))°"
            TimeTable.append(("Declination", DeclinationLabel))
            SecondsTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                target: self,
                                                selector: #selector(UpdateCurrentSeconds),
                                                userInfo: nil,
                                                repeats: true)
            TimeTable.append(("Seconds Elapsed",""))
            UpdateCurrentSeconds()
            TodayTable.reloadData()
        }
    }

    var SecondsTimer: Timer? = nil
    var ShowHomeData = true
    var SolarNow: SolarToday! = nil
    var TimeZoneSeconds: Int? = nil
    
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
        let TimeParts = TimePart.Split(Separators: ["+", "-"], omittingEmptySubsequences: true)
        if TimeParts.count != 2
        {
            Debug.FatalError("Invalid time string passed to \(#function)")
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
        if TimeTable.count < 1
        {
            return nil
        }
        if row > TimeTable.count - 1
        {
            return nil
        }
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
            SecondsTimer?.invalidate()
            SecondsTimer = nil
            SetLocation()
        }
    }
    
    @IBOutlet weak var LocationNote: NSTextField!
    @IBOutlet weak var TodayTable: NSTableView!
}
