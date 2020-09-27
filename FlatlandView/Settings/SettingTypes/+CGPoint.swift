//
//  +CGPoint.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - CGPoint functions.
    
    /// Set a CGPoint value.
    /// - Warming: A fatal error will be thrown if the type of `Setting` is not `CGPoint`.
    /// - Parameter Setting: The setting where the value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetCGPoint(_ Setting: SettingKeys, _ Value: CGPoint)
    {
        if !TypeIsValid(Setting, Type: CGPoint.self)
        {
            fatalError("\(Setting) is not a CGPoint")
        }
        let Serialized = "\(Value.x),\(Value.y)"
        let OldValue = GetCGPoint(Setting)
        UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: Value)
    }
    
    /// Get the CGPoint value at the specified setting.
    /// - Warming: A fatal error will be thrown if the type of `Setting` is not `CGPoint`.
    /// - Parameter Setting: The setting where the CGPoint value is stored.
    /// - Parameter Default: If there is no value in `Setting` and `Default` has a value, the value in
    ///                      `Default` will be returned.
    /// - Returns: The CGPoint value on success, nil if not available.
    public static func GetCGPoint(_ Setting: SettingKeys, Default: CGPoint? = nil) -> CGPoint?
    {
        if !TypeIsValid(Setting, Type: CGPoint.self)
        {
            fatalError("\(Setting) is not an CGPoint")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            if Parts.count != 2
            {
                fatalError("Mal-formed CGPoint found for \(Setting.rawValue): \"\(Raw)\"")
            }
            if let PointX = Double(String(Parts[0]))
            {
                if let PointY = Double(String(Parts[1]))
                {
                    return CGPoint(x: PointX, y: PointY)
                }
            }
            fatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
        }
        else
        {
            if let DefaultValue = Default
            {
                let Serialized = "\(DefaultValue.x),\(DefaultValue.y)"
                UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
                return Default
            }
            else
            {
                return nil
            }
        }
    }
    
    /// Get the CGPoint value at the specified setting.
    /// - Warming: A fatal error will be thrown if the type of `Setting` is not `CGPoint`.
    /// - Parameter Setting: The setting where the CGPoint value is stored.
    /// - Parameter Default: If there is no value in `Setting` and `Default` has a value, the value in
    ///                      `Default` will be returned.
    /// - Returns: The CGPoint value on success, the value in `Default` if not available.
    public static func GetCGPoint(_ Setting: SettingKeys, Default: CGPoint) -> CGPoint
    {
        if !TypeIsValid(Setting, Type: CGPoint.self)
        {
            fatalError("\(Setting) is not an CGPoint")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
            if Parts.count != 2
            {
                fatalError("Mal-formed CGPoint found for \(Setting.rawValue): \"\(Raw)\"")
            }
            if let PointX = Double(String(Parts[0]))
            {
                if let PointY = Double(String(Parts[1]))
                {
                    return CGPoint(x: PointX, y: PointY)
                }
            }
            fatalError("Error parsing value from \(Setting.rawValue): \"\(Raw)\"")
        }
        return Default
    }
    
}
