//
//  TodayCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class TodayCode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PopulateTable()
        TodayTable.reloadData()
    }
    
    func PopulateTable()
    {
        var LocalSunrise = ""
        var LocalSunset = ""
        var LocalNoon = ""
        let Cal = Calendar.current
        let SunTimes = Sun()
        if Settings.GetBool(.ShowLocalData)
        {
            if Settings.HaveLocalLocation()
            {
                var RiseAndSetAvailable = true
                var SunRiseTime = Date()
                var SunSetTime = Date()
                let LocalLat = Settings.GetDoubleNil(.LocalLatitude)
                let LocalLon = Settings.GetDoubleNil(.LocalLongitude)
                let Location = GeoPoint2(LocalLat!, LocalLon!)
                if let SunriseTime = SunTimes.Sunrise(For: Date(), At: Location, TimeZoneOffset: 0)
                {
                    SunRiseTime = SunriseTime
                    LocalSunrise = SunriseTime.PrettyTime()
                }
                else
                {
                    RiseAndSetAvailable = false
                    LocalSunrise = "No sunrise"
                }
                if let SunsetTime = SunTimes.Sunset(For: Date(), At: Location, TimeZoneOffset: 0)
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
                }
                else
                {
                    LocalNoon = ""
                }
            }
            else
            {
                LocalSunset = "N/A"
                LocalSunrise = "N/A"
                LocalNoon = "N/A"
            }
        }
        TimeTable.append(("Local Sunrise", LocalSunrise))
        TimeTable.append(("Local Noon", LocalNoon))
        TimeTable.append(("Local Sunset", LocalSunset))
        
        let DaysDeclination = Sun.Declination(For: Date())
        let DeclinationLabel = "\(DaysDeclination.RoundedTo(3))°"
        TimeTable.append(("Declination", DeclinationLabel))
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(UpdateCurrentSeconds),
                                     userInfo: nil, repeats: true)
        TimeTable.append(("Seconds Elapsed",""))
        UpdateCurrentSeconds()
    }
    
    @objc func UpdateCurrentSeconds()
    {
        let Cal = Calendar.current
        let H = Cal.component(.hour, from: Date())
        let M = Cal.component(.minute, from: Date())
        let S = Cal.component(.second, from: Date())
        let CurrentSeconds = S + (M * 60) + (H * 60 * 60)
        let Index = IndexOfElapsedSeconds()
        if Index > -1
        {
            TimeTable[Index] = ("Seconds Elapsed", "\(CurrentSeconds)")
        }
        TodayTable.reloadData()
    }
    
    func IndexOfElapsedSeconds() -> Int
    {
        for Index in 0 ..< TimeTable.count
        {
            if TimeTable[Index].Event == "Seconds Elapsed"
            {
                return Index
            }
        }
        return -1
    }
    
    var TimeTable = [(Event: String, Value: String)]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return TimeTable.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "EventColumn"
            CellContents = TimeTable[row].Event
        }
        
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "WhenColumn"
            CellContents = TimeTable[row].Value
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var TodayTable: NSTableView!
}
