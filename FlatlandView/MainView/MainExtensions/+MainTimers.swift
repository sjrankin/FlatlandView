//
//  +MainTimers.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    // MARK: - Main Timer
    
    @objc func MainTimerHandler()
    {
        let LabelType = Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .None)
        let Now = GetUTC()
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        var TimeZoneAbbreviation = ""
        if LabelType == .UTC
        {
            TimeZoneAbbreviation = "UTC"
        }
        else
        {
            TimeZoneAbbreviation = GetLocalTimeZoneID() ?? "UTC"
        }
        let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
        Formatter.timeZone = TZ
        var Final = Formatter.string(from: Now)
        let Parts = Final.split(separator: ":")
        if !Settings.GetBool(.TimeLabelSeconds)
        {
            Final = "\(Parts[0]):\(Parts[1])"
        }
        let FinalText = Final + " " + TimeZoneAbbreviation
        var IsNewHour = false
        if PreviousHourValue.isEmpty
        {
            PreviousHourValue = String(Parts[0])
        }
        else
        {
            if PreviousHourValue != String(Parts[0])
            {
                IsNewHour = true
                PreviousHourValue = String(Parts[0])
            }
        }
        if LabelType == .None
        {
            MainTimeLabelTop.stringValue = ""
            MainTimeLabelBottom.stringValue = ""
        }
        else
        {
            MainTimeLabelTop.stringValue = FinalText
            MainTimeLabelBottom.stringValue = FinalText
        }
        
        let CurrentSeconds = Now.timeIntervalSince1970
        var ElapsedSeconds = 0
        if CurrentSeconds != OldSeconds
        {
            OldSeconds = CurrentSeconds
            var Cal = Calendar(identifier: .gregorian)
            //Use UTC time zone for rotational calculations, not the local time zone (if the user
            //is using the local zone). All calculations are based on UTC and so if local time zones
            //are used, the map wil be rotated incorrectly.
            Cal.timeZone = TimeZone(abbreviation: "UTC")!
            let Hour = Cal.component(.hour, from: Now)
            let Minute = Cal.component(.minute, from: Now)
            let Second = Cal.component(.second, from: Now)
            ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
            let Percent = Double(ElapsedSeconds) / Double(24 * 60 * 60)
            let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
            Main2DView.RotateImageTo(PrettyPercent)
            if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
            {
                if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .WallClock) == .WallClock
                {
                    Main3DView?.UpdateWallClockHours(NewTime: Now)
                }
            }
            if Settings.GetBool(.EnableHourEvent)
            {
                if Minute == 0 && !HourSoundTriggered
                {
                    Main3DView.FlashAllHours(Count: 3)
//                    Main3DView.FlashHoursInSequence(Count: 3)
                    HourSoundTriggered = true
                    SoundManager.Play(ForEvent: .HourChime)
                }
            }
            if Minute != 0
            {
                HourSoundTriggered = false
            }
        }
    }
    
    func GetUTC() -> Date
    {
        return Date()
    }
    
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    #if DEBUG
    @objc func DebugTimerHandler()
    {
        #if true
        let DurationValue = Utility.DurationBetween(Seconds1: CACurrentMediaTime(),
                                                    Seconds2: UptimeStart)
        UptimeValue.stringValue = DurationValue
        #else
        if Date.timeIntervalSinceReferenceDate - StartDebugCount >= 1.0
        {
            StartDebugCount = Date.timeIntervalSinceReferenceDate
            UptimeSeconds = UptimeSeconds + 1
            UptimeValue.stringValue = "\(UptimeSeconds)"
        }
        #endif
    }
    #endif
}
