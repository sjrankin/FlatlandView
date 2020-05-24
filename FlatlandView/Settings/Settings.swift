//
//  Settings.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Settings
{
    // MARK: - Initialization.
    
    public static func Initialize()
    {
        if WasInitialized()
        {
            return
        }
        SetBool(.InitializationFlag, true)
    }
    
    public static func WasInitialized() -> Bool
    {
        return GetBool(.InitializationFlag)
    }
    
    // MARK: - Subscriber management.
    
    static var Subscribers = [SettingChangedProtocol]()
    
    public static func AddSubscriber(_ NewSubscriber: SettingChangedProtocol)
    {
        for Subscriber in Subscribers
        {
            if Subscriber.SubscriberID() == NewSubscriber.SubscriberID()
            {
                return
            }
        }
        Subscribers.append(NewSubscriber)
    }
    
    public static func RemoveSubscriber(_ OldSubscriber: SettingChangedProtocol)
    {
        Subscribers.removeAll(where: {$0.SubscriberID() == OldSubscriber.SubscriberID()})
    }
    
    public static func NotifySubscribers(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        for Subscriber in Subscribers
        {
            Subscriber.SettingChanged(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
        }
    }
    
    // MARK: - Boolean functions.
    
    public static func InitializeBool(_ Setting: SettingTypes, _ Value: Bool)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    public static func GetBool(_ Setting: SettingTypes) -> Bool
    {
        return UserDefaults.standard.bool(forKey: Setting.rawValue)
    }
    
    public static func SetBool(_ Setting: SettingTypes, _ Value: Bool)
    {
        let OldValue = UserDefaults.standard.bool(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - String functions.
    
    public static func InitializeString(_ Setting: SettingTypes, _ Value: String)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    public static func GetString(_ Setting: SettingTypes, _ Default: String) -> String
    {
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            return Raw
        }
        UserDefaults.standard.set(Default, forKey: Setting.rawValue)
        return Default
    }
    
    public static func GetString(_ Setting: SettingTypes) -> String?
    {
        return UserDefaults.standard.string(forKey: Setting.rawValue)
    }
    
    public static func SetString(_ Setting: SettingTypes, _ Value: String)
    {
        let OldValue = UserDefaults.standard.string(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - Int functions.
    
    public static func InitializeInt(_ Setting: SettingTypes, _ Value: Int)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    public static func GetInt(_ Setting: SettingTypes) -> Int
    {
        UserDefaults.standard.integer(forKey: Setting.rawValue)
    }
    
    public static func SetInt(_ Setting: SettingTypes, _ Value: Int)
    {
        let OldValue = UserDefaults.standard.integer(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - Double functions.
    
    public static func InitializeDouble(_ Setting: SettingTypes, _ Value: Double)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    public static func GetDouble(_ Setting: SettingTypes) -> Double
    {
        UserDefaults.standard.double(forKey: Setting.rawValue)
    }
    
    public static func SetDouble(_ Setting: SettingTypes, _ Value: Double)
    {
        let OldValue = UserDefaults.standard.double(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - Color functions.
    
    public static func InitializeColor(_ Setting: SettingTypes, _ Value: NSColor)
    {
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue)
    }
    
    public static func GetColor(_ Setting: SettingTypes) -> NSColor?
    {
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = NSColor(HexString: Raw)
            {
                return Final
            }
        }
        return nil
    }
    
    public static func GetColor(_ Setting: SettingTypes, _ Default: NSColor) -> NSColor
    {
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = NSColor(HexString: Raw)
            {
                return Final
            }
        }
        UserDefaults.standard.set(Default.Hex, forKey: Setting.rawValue)
        return Default
    }
    
    public static func SetColor(_ Setting: SettingTypes, _ Value: NSColor)
    {
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue) 
    }
}
