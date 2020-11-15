//
//  +Query.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    /// Query a setting and return it's name, value, and type.
    /// - Paremter Key: The setting key whose data will be returned.
    /// - Returns: Tuple with the setting name, current value, and type.
    public static func Query(_ Key: SettingKeys) -> (Name: String, Value: String, Type: String)?
    {
        let SomeType = GetBaseSettingType(Key)
        if SomeType.isEmpty
        {
            return nil
        }
        var SettingValue = ""
        switch SomeType
        {
            case "Bool":
                SettingValue = "\(UserDefaults.standard.bool(forKey: Key.rawValue))"
                
            case "Int":
                SettingValue = "\(UserDefaults.standard.integer(forKey: Key.rawValue))"
                
            case "Double":
                SettingValue = "\(UserDefaults.standard.double(forKey: Key.rawValue))"
                
            case "Double?":
                SettingValue = "\(UserDefaults.standard.double(forKey: Key.rawValue))"
                
            case "NSColor":
                SettingValue = UserDefaults.standard.string(forKey: Key.rawValue) ?? ""
                
            case "String":
                SettingValue = UserDefaults.standard.string(forKey: Key.rawValue) ?? ""
                
            case "Date":
                SettingValue = "\(GetDate(Key))"
                
            case "NSSize":
                if let Size = GetNSSize(Key)
                {
                    SettingValue = "\(Size)"
                }
                else
                {
                    SettingValue = ""
                }
                
            case "NSRect":
                if let Rect = GetRect(Key)
                {
                    SettingValue = "\(Rect)"
                }
                else
                {
                    SettingValue = ""
                }
                
            case "CGPoint":
                if let Point = GetCGPoint(Key)
                {
                    SettingValue = "\(Point)"
                }
                else
                {
                    SettingValue = ""
                }
                
            default:
                SettingValue = UserDefaults.standard.string(forKey: Key.rawValue) ?? ""
        }
        
        return (Name: Key.rawValue, Value: SettingValue, Type: SomeType)
    }
    
    /// Return the type of the passed setting key.
    /// - Parameter Key: The key whose type is returned.
    /// - Returns: Name of the type.
    public static func GetBaseSettingType(_ Key: SettingKeys) -> String
    {
        if let SomeType = SettingKeyTypes[Key]
        {
            return "\(SomeType)"
        }
        return ""
    }
    
    public static func TryToSet(_ Key: SettingKeys, WithValue: String) -> Bool
    {
        let SomeType = GetBaseSettingType(Key)
        switch SomeType
        {
            case "Bool":
                if let BValue = Bool(WithValue)
                {
                    SetBool(Key, BValue)
                    return true
                }
                else
                {
                    return false
                }
                
            case "Int":
                if let IValue = Int(WithValue)
                {
                    SetInt(Key, IValue)
                    return true
                }
                else
                {
                    return false
                }
                
            case "Double", "Double?":
                if let DValue = Double(WithValue)
                {
                    SetDouble(Key, DValue)
                    return true
                }
                else
                {
                    return false
                }
                
            case "String":
                SetString(Key, WithValue)
                return true
                
            case "NSColor":
                if let Color = NSColor(HexString: WithValue)
                {
                    SetColor(Key, Color)
                    return true
                }
                else
                {
                    return false
                }
                
            case "NSRect":
                UserDefaults.standard.setValue(WithValue, forKey: Key.rawValue)
                return true
                
            case "NSSize":
                UserDefaults.standard.setValue(WithValue, forKey: Key.rawValue)
                return true
                
            case "Date":
                UserDefaults.standard.setValue(WithValue, forKey: Key.rawValue)
                return true
                
            case "CGPoint":
                UserDefaults.standard.setValue(WithValue, forKey: Key.rawValue)
                return true
                
            default:
                UserDefaults.standard.setValue(WithValue, forKey: Key.rawValue)
                return true
        }
    }
}
