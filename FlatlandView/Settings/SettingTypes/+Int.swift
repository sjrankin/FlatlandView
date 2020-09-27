//
//  +Int.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - Int functions.
    
    /// Initialize an Integer setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the integer to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeInt(_ Setting: SettingKeys, _ Value: Int)
    {
        if !TypeIsValid(Setting, Type: Int.self)
        {
            fatalError("\(Setting) is not an Int")
        }
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Returns an integer from the specified setting.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Returns: Integer found at the specified setting.
    public static func GetInt(_ Setting: SettingKeys) -> Int
    {
        if !TypeIsValid(Setting, Type: Int.self)
        {
            fatalError("\(Setting) is not an Int")
        }
        return UserDefaults.standard.integer(forKey: Setting.rawValue)
    }
    
    /// Returns an integer from the specified setting.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Parameter IfZero: The value to return if the value in the setting is zero. If the value in the
    ///                     setting is zero, the value of `IfZero` is saved there.
    /// - Returns: Integer found at the specified setting. If that value is `0`, the value passed in `IfZero`
    ///            is saved in the setting then returned.
    public static func GetInt(_ Setting: SettingKeys, IfZero: Int) -> Int
    {
        if !TypeIsValid(Setting, Type: Int.self)
        {
            fatalError("\(Setting) is not an Int")
        }
        let Value = UserDefaults.standard.integer(forKey: Setting.rawValue)
        if Value == 0
        {
            UserDefaults.standard.setValue(IfZero, forKey: Setting.rawValue)
            return IfZero
        }
        return Value
    }
    
    /// Returns an integer from the specified setting.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Parameter IfZero: The value to return if the value in the setting is zero. If the value in the
    ///                     setting is zero, the value of `IfZero` is saved there. The value of this
    ///                     parameter is typecast to `Int`.
    /// - Returns: Integer found at the specified setting. If that value is `0`, the value passed in `IfZero`
    ///            is saved in the setting then returned.
    public static func GetInt(_ Setting: SettingKeys, IfZero: Defaults) -> Int
    {
        if !TypeIsValid(Setting, Type: Int.self)
        {
            fatalError("\(Setting) is not an Int")
        }
        let Value = UserDefaults.standard.integer(forKey: Setting.rawValue)
        if Value == 0
        {
            UserDefaults.standard.setValue(Int(IfZero.rawValue), forKey: Setting.rawValue)
            return Int(IfZero.rawValue)
        }
        return Value
    }
    
    /// Queries an integer setting value.
    /// - Parameter Setting: The setting whose integer value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryInt(_ Setting: SettingKeys, Completion: (Int) -> Void)
    {
        if !TypeIsValid(Setting, Type: Int.self)
        {
            fatalError("\(Setting) is not an Int")
        }
        let IntValue = UserDefaults.standard.integer(forKey: Setting.rawValue)
        Completion(IntValue)
    }
    
    /// Save an integer at the specified setting.
    /// - Parameter Setting: The setting where the integer value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetInt(_ Setting: SettingKeys, _ Value: Int)
    {
        if !TypeIsValid(Setting, Type: Int.self)
        {
            fatalError("\(Setting) is not an Int")
        }
        let OldValue = UserDefaults.standard.integer(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
}
