//
//  +NSSize.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - NSSize functions.
    
    /// Set an NSSize value.
    /// - Warming: A fatal error will be thrown if the type of `Setting` is not `NSSize`.
    /// - Parameter Setting: The setting where the value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetNSSize(_ Setting: SettingKeys, _ Value: NSSize)
    {
        if !TypeIsValid(Setting, Type: NSSize.self)
        {
            fatalError("\(Setting) is not an NSSize")
        }
        let Serialized = "\(Value.width),\(Value.height)"
        let OldValue = GetNSSize(Setting)
        UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: Value)
    }
    
    /// Get the NSSize value at the specified setting.
    /// - Warming: A fatal error will be thrown if the type of `Setting` is not `NSSize`.
    /// - Parameter Setting: The setting where the NSSize value is stored.
    /// - Parameter Default: If there is no value in `Setting` and `Default` has a value, the value in
    ///                      `Default` will be returned.
    /// - Returns: The NSSize value on success, nil if not available.
    public static func GetNSSize(_ Setting: SettingKeys, Default: NSSize? = nil) -> NSSize?
    {
        if !TypeIsValid(Setting, Type: NSSize.self)
        {
            fatalError("\(Setting) is not an NSSize")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            if Parts.count != 2
            {
                fatalError("Mal-formed NSSize found for \(Setting.rawValue): \"\(Raw)\"")
            }
            if let Width = Double(String(Parts[0]))
            {
                if let Height = Double(String(Parts[1]))
                {
                    return NSSize(width: Width, height: Height)
                }
            }
            fatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
        }
        else
        {
            if let DefaultValue = Default
            {
                let Serialized = "\(DefaultValue.width),\(DefaultValue.height)"
                UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
                return Default
            }
            else
            {
                return nil
            }
        }
    }
    
    /// Get the NSSize value at the specified setting.
    /// - Warming: A fatal error will be thrown if the type of `Setting` is not `NSSize`.
    /// - Parameter Setting: The setting where the NSSize value is stored.
    /// - Parameter Default: If there is no value in `Setting` and `Default` has a value, the value in
    ///                      `Default` will be returned.
    /// - Returns: The NSSize value on success, value of `Default` if not available.
    public static func GetNSSize(_ Setting: SettingKeys, Default: NSSize) -> NSSize
    {
        if !TypeIsValid(Setting, Type: NSSize.self)
        {
            fatalError("\(Setting) is not an NSSize")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            if Parts.count != 2
            {
                fatalError("Mal-formed NSSize found for \(Setting.rawValue): \"\(Raw)\"")
            }
            if let Width = Double(String(Parts[0]))
            {
                if let Height = Double(String(Parts[1]))
                {
                    return NSSize(width: Width, height: Height)
                }
            }
            fatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
        }
        return Default
    }
}
