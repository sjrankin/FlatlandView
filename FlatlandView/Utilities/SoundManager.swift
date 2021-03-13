//
//  SoundManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation

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
    
    /// Holds the `AVAudioPlayer` instance. If not stored as a property (or global), no sound will be heard
    /// because the AVAudioPlay will go out of scope almost immediately.
    /// - Note: See: [AVAudioPlayer play does not play sound](https://stackoverflow.com/questions/29379524/avaudioplayer-play-does-not-play-sound)
    private static var Player: AVAudioPlayer? = nil
    
    /// Play a sound packaged with the bundle.
    /// - Note: If there are errors playing the sound, control will return immediately.
    /// - Parameter Name: Name of the sound. All sounds in the bundle must end with `.mp3` (and be that type)
    ///                   but the name passed here should not include the extension.
    private static func PlayBundleSound(_ Name: String)
    {
        guard let SoundUrl = Bundle.main.url(forResource: Name, withExtension: "mp3") else
        {
            Debug.Print("Error getting \(Name) in bundle.")
            return
        }
        do
        {
            Player = try AVAudioPlayer(contentsOf: SoundUrl, fileTypeHint: AVFileType.mp3.rawValue)
            guard let ThePlayer = Player else
            {
                Debug.Print("Error creating audio player")
                return
            }
            ThePlayer.play()
        }
        catch
        {
            Debug.Print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    /// Play a sound with the specified name. No error checking is done.
    /// - Parameter Name: The name of the sound to play.
    public static func Play(Name: String)
    {
        if Settings.GetBool(.EnableSounds)
        {
            if IsAsset(Name)
            {
                PlayBundleSound(Name)
                return
            }
            NSSound(named: Name)?.play()
        }
    }
    
    private static func IsAsset(_ Name: String) -> Bool
    {
        for SoundName in AdditionalSounds
        {
            if SoundName.rawValue == Name
            {
                return true
            }
        }
        return false
    }
    
    /// Plays a sound given the passed sound enumeration.
    /// - Note: See [Accessing Audio Files in Asset Catalogs](https://developer.apple.com/library/archive/qa/qa1913/_index.html)
    /// - Parameter Sound: The sound enumeration to play. If nil, no action is taken.
    public static func Play(Sound: Sounds?)
    {
        if let TheSound = Sound
        {
            if AdditionalSounds.contains(TheSound)
            {
                if let SoundName = AdditionalToResource[TheSound]
                {
                    if let Asset = NSDataAsset(name: SoundName)
                    {
                        do
                    {
                        let Player = try AVAudioPlayer(data: Asset.data, fileTypeHint: "mp3")
                        Player.play()
                    }
                        catch
                        {
                            Debug.Print("Error playing \(TheSound.rawValue): \(error.localizedDescription)")
                        }
                    }
                }
            }
            else
            {
                Play(Name: TheSound.rawValue)
            }
        }
    }
    
    /// Play a sound for the passed event.
    /// - Parameter ForEvent: The event whose sound will be played.
    public static func Play(ForEvent: SoundEvents)
    {
        #if true
        Play(Sound: GetEventSound(ForEvent))
        #else
        if let SoundName = GetSoundForEvent(ForEvent)
        {
            Play(Name: SoundName)
        }
        #endif
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
    
    /// Return the sound enumeration for the passed sound event.
    /// - Parameter EventType: The event whose sound enumeration is returned.
    /// - Returns: `Sounds` enumeration for the passed event.
    public static func GetEventSound(_ EventType: SoundEvents) -> Sounds?
    {
        if let TheEvent = EventSoundMap[EventType]
        {
            return Sounds(rawValue: TheEvent)
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
    
    /// Array of sounds in the asset catelog.
    static var AdditionalSounds = [Sounds.Chime, Sounds.Cymbal, Sounds.Doorbell, Sounds.Fiddle,
                                   Sounds.Gong]
    
    /// Map of sounds to asset catelog sound names.
    static var AdditionalToResource: [Sounds: String] =
        [
            Sounds.Chime: "Chime3",
            Sounds.Cymbal: "Cymbal",
            Sounds.Doorbell: "Doorbell",
            Sounds.Fiddle: "Fiddle",
            Sounds.Gong: "Gong"
        ]
}

enum SoundClasses: String, CaseIterable
{
    case General = "General"
    case BuiltIn = "Built-In"
    case Flatland = "Flatland"
    case Asset = "Asset"
    case User = "User"
}

/// Sounds for events.
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
    //Non-built-in sounds
    case Chime = "Chime"
    case Cymbal = "Cymbal"
    case Doorbell = "Doorbell"
    case Fiddle = "Fiddle"
    case Gong = "Gong"
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
