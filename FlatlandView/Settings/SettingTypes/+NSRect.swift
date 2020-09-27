//
//  +NSRect.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - NSRect functions.
    
    /// Encode an `NSRect` into a string for saving into user defaults.
    /// - Parameter Rect: The `NSRect` to encode.
    /// - Returns: String with the passed `NSRect` encoded.
    private static func EncodeRect(_ Rect: NSRect) -> String
    {
        return "\(Rect.origin.x),\(Rect.origin.y),\(Rect.size.width),\(Rect.size.height)"
    }
    
    /// Decode an encoded `NSRect`.
    /// - Parameter Encoded: The encoded `NSRect` to decode.
    /// - Returns: `NSRect` populated with the values in `Encoded` on success, nil on error (badly
    ///            encoded data or incorrect data format).
    private static func DecodeRect(_ Encoded: String) -> NSRect?
    {
        let Parts = Encoded.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 4
        {
            return nil
        }
        let OX = Double(String(Parts[0]))
        let OY = Double(String(Parts[1]))
        let SW = Double(String(Parts[2]))
        let SH = Double(String(Parts[3]))
        if OX == nil || OY == nil || SW == nil || SH == nil
        {
            return nil
        }
        return NSRect(origin: CGPoint(x: OX!, y: OY!), size: CGSize(width: SW!, height: SH!))
    }
    
    /// Initialize an `NSRect` setting. Subscribers are not notified.
    /// - Parameter Setting: The setting where the `NSRect` will be stored.
    /// - Parameter Value: The `NSRect` to save.
    public static func InitializeRect(_ Setting: SettingKeys, _ Value: NSRect)
    {
        let Encoded = EncodeRect(Value)
        UserDefaults.standard.set(Encoded, forKey: Setting.rawValue)
    }
    
    /// Save the value of an `NSRect` to user settings.
    /// - Parameter Setting: The setting where the `NSRect` will be stored.
    /// - Parameter Value: The value to store.
    public static func SetRect(_ Setting: SettingKeys, _ Value: NSRect)
    {
        if !TypeIsValid(Setting, Type: NSRect.self)
        {
            fatalError("\(Setting) is not a NSRect")
        }
        let OldValue = GetRect(Setting)
        let Encoded = EncodeRect(Value)
        UserDefaults.standard.set(Encoded, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: Encoded)
    }
    
    /// Returns an `NSRect` saved in user settings.
    /// - Parameter Setting: The location of the saved `NSRect`.
    /// - Returns: Populated `NSRect` on success, nil on error.
    public static func GetRect(_ Setting: SettingKeys) -> NSRect?
    {
        if !TypeIsValid(Setting, Type: NSRect.self)
        {
            fatalError("\(Setting) is not a NSRect")
        }
        if let Value = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            return DecodeRect(Value)
        }
        else
        {
            return nil
        }
    }
    
    /// Returns an `NSRect` saved in user settings.
    /// - Note: If there is no value at the specified settings, the value in `Default` will be returned
    ///         if it is not nil. If it is not nil, the value in `Default` will also be written to
    ///         `Setting`.
    /// - Parameter Setting: The location of the saved `NSRect`.
    /// - Parameter Default: If present the default value to return if `Setting` does not yet have
    ///                      a value.
    /// - Returns: The value found in `Setting` if it exists, the value found in `Default` if
    ///            `Setting` is empty, `NSRect.zero` if `Default` is nil.
    public static func GetRect(_ Setting: SettingKeys, Default: NSRect? = nil) -> NSRect
    {
        if !TypeIsValid(Setting, Type: NSRect.self)
        {
            fatalError("\(Setting) is not a NSRect")
        }
        if let Value = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Actual = DecodeRect(Value)
            {
                return Actual
            }
        }
        
        if let SaveMe = Default
        {
            SetRect(Setting, SaveMe)
            return SaveMe
        }
        
        return NSRect.zero
    }
}
