//
//  SoundManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SoundManager
{
    public static func Play(Name: String)
    {
        NSSound(named: Name)?.play()
    }
    
    public static func Play(ForEvent: SoundEvents)
    {
        if let SoundName = GetSoundForEvent(ForEvent)
        {
            Play(Name: SoundName)
        }
    }
    
    public static func GetSoundForEvent(_ EventType: SoundEvents) -> String?
    {
        if let SoundName = EventSoundMap[EventType]
        {
            return SoundName
        }
        return nil
    }
    
    static var EventSoundMap: [SoundEvents: String] =
    [
        .BadInput: Sounds.Tink.rawValue,
        .HourChime: Sounds.Blow.rawValue,
        .NewEarthquake: Sounds.Sosumi.rawValue,
        .Debug: Sounds.Frog.rawValue
    ]
}

enum Sounds: String, CaseIterable
{
    case Basso = "Basso"
    case Blow = "Blow"
    case Bottle = "Bottle"
    case Frog = "Frog"
    case Funk = "Funk"
    case Glass = "Glass"
    case Hero = "Hero"
    case Morse = "Morse"
    case Ping = "Ping"
    case Pop = "Pop"
    case Purr = "Purr"
    case Sosumi = "Sosumi"
    case Submarine = "Submarine"
    case Tink = "Tink"
}

enum SoundEvents: String, CaseIterable
{
    case BadInput = "BadInput"
    case HourChime = "HourChime"
    case NewEarthquake = "NewEarthquake"
    case Debug = "DebugEvent"
}
