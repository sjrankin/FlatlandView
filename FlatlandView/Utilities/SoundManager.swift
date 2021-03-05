//
//  SoundManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Manages sounds and the playing of sounds.
/// - Note:
///    - When playing sounds, control returns immediately.
///    - All sounds are played in the `SoundManager.Play` function. If the global setting `.EnableSounds` is
///      false, no sounds will be played regardless of the event.
class SoundManager
{
    /// Initialize the sound manager.
    public static func Initialize()
    {
        #if DEBUG
        EventSoundMap[.Debug] = Sounds.Frog.rawValue
        #endif
    }
    
    /// Play a sound with the specified name. No error checking is done.
    /// - Parameter Name: The name of the sound to play.
    public static func Play(Name: String)
    {
        if Settings.GetBool(.EnableSounds)
        {
            NSSound(named: Name)?.play()
        }
    }
    
    /// Play a sound for the passed event.
    /// - Parameter ForEvent: The event whose sound will be played.
    public static func Play(ForEvent: SoundEvents)
    {
        if let SoundName = GetSoundForEvent(ForEvent)
        {
            Play(Name: SoundName)
        }
    }
    
    /// Return the name of the sound for the specified event.
    /// - Parameter EventType: The event whose sound name is returned.
    /// - Returns: Name of the file for the event on success, nil if not found.
    public static func GetSoundForEvent(_ EventType: SoundEvents) -> String?
    {
        if let SoundName = EventSoundMap[EventType]
        {
            if SoundName == Sounds.None.rawValue
            {
                return nil
            }
            return SoundName
        }
        return nil
    }
    
    /// Map of events to sound names.
    static var EventSoundMap: [SoundEvents: String] =
        [
            .BadInput: Sounds.Tink.rawValue,
            .HourChime: Sounds.Blow.rawValue,
            .NewEarthquake: Sounds.Sosumi.rawValue,
        ]
}

enum SoundClasses: String, CaseIterable
{
    case General = "General"
    case BuiltIn = "Built-In"
    case Flatland = "Flatland"
    case User = "User"
}

/// Built-in system sounds.
enum Sounds: String, CaseIterable
{
    case None = "None"
    case User = "User File"
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
    case BadInput = "Bad Input"
    case HourChime = "Hour Chime"
    case NewEarthquake = "New Earthquake"
    #if DEBUG
    case Debug = "Debug Event"
    #endif
}
