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
        guard TypeIsValid(Setting, Type: NSSize.self) else
        {
            Debug.FatalError("\(Setting) is not an NSSize")
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
        guard TypeIsValid(Setting, Type: NSSize.self) else
        {
            Debug.FatalError("\(Setting) is not an NSSize")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            guard Parts.count == 2 else
            {
                Debug.FatalError("Mal-formed NSSize found for \(Setting.rawValue): \"\(Raw)\"")
            }
            guard let Width = Double(String(Parts[0])) else
            {
                Debug.FatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
            }
            guard let Height = Double(String(Parts[1])) else
            {
                Debug.FatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
            }
            return NSSize(width: Width, height: Height)
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
        guard TypeIsValid(Setting, Type: NSSize.self) else
        {
            Debug.FatalError("\(Setting) is not an NSSize")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            guard Parts.count == 2 else
            {
                Debug.FatalError("Mal-formed NSSize found for \(Setting.rawValue): \"\(Raw)\"")
            }
            guard let Width = Double(String(Parts[0])) else
            {
                Debug.FatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
            }
            guard let Height = Double(String(Parts[1])) else
            {
                Debug.FatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
            }
            return NSSize(width: Width, height: Height)
        }
        return Default
    }
}
