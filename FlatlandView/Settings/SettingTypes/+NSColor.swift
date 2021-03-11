//
//  +NSColor.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - Color functions.
    
    /// Initialize an NSColor setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the color to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeColor(_ Setting: SettingKeys, _ Value: NSColor)
    {
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue)
    }
    
    /// Returns a color from the specified setting.
    /// - Parameter Setting: The setting whose color will be returned.
    /// - Returns: The color stored at the specified setting, nil if not found.
    public static func GetColor(_ Setting: SettingKeys) -> NSColor?
    {
        guard TypeIsValid(Setting, Type: NSColor.self) else
        {
            Debug.FatalError("\(Setting) is not an NSColor")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = NSColor(HexString: Raw)
            {
                return Final
            }
        }
        return nil
    }
    
    /// Queries a color setting value.
    /// - Parameter Setting: The setting whose color value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryColor(_ Setting: SettingKeys, Completion: (NSColor?) -> Void)
    {
        guard TypeIsValid(Setting, Type: NSColor.self) else
        {
            Debug.FatalError("\(Setting) is not an NSColor")
        }
        let ColorValue = GetColor(Setting)
        Completion(ColorValue)
    }
    
    /// Returns a color from the specified setting.
    /// - Parameter Setting: The setting whose color will be returned.
    /// - Parameter Default: The value returned if the setting does not contain a valid color.
    /// - Returns: The color stored at the specified setting, the contents of `Default` if no valid
    ///            color found.
    public static func GetColor(_ Setting: SettingKeys, _ Default: NSColor) -> NSColor
    {
        guard TypeIsValid(Setting, Type: NSColor.self) else
        {
            Debug.FatalError("\(Setting) is not an NSColor")
        }
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
    
    /// Returns a color from the specified setting.
    /// - Parameter Setting: The setting whose color will be returned.
    /// - Parameter Default: The value returned if the setting does not contain a valid color.
    /// - Returns: The color stored at the specified setting, the contents of `Default` if no valid
    ///            color found. Value returned as a `CGColor`.
    public static func GetCGColor(_ Setting: SettingKeys, _ Default: NSColor) -> CGColor
    {
        guard TypeIsValid(Setting, Type: NSColor.self) else
        {
            Debug.FatalError("\(Setting) is not an NSColor")
        }
        return GetColor(Setting, Default).cgColor
    }
    
    /// Save a color at the specified setting.
    /// - Parameter Setting: The setting where to save the color.
    /// - Parameter Value: The color to save.
    public static func SetColor(_ Setting: SettingKeys, _ Value: NSColor)
    {
        guard TypeIsValid(Setting, Type: NSColor.self) else
        {
            Debug.FatalError("\(Setting) is not an NSColor")
        }
        let OldValue = GetColor(Setting)
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: Value)
    }
}
