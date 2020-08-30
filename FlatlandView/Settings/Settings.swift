//
//  Settings.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// This class encapsulates settings into a set of functions that rely on enums to select the
/// value rather than strings. This class also allows other classes to "subscribe" to changed
/// value events.
class Settings
{
    // MARK: - Initialization.
    
    /// Initialize settings. Run only if the initialization flag hasn't been set, or the force
    /// reinitialize flag is true.
    /// - Parameter ForceReinitialize: If true, settings will be reset to their default values. In
    ///                                this case, no messages will be returned to subscribers indicating
    ///                                changes have been made.
    public static func Initialize(_ ForceReinitialize: Bool = false)
    {
        if WasInitialized()
        {
            if !ForceReinitialize
            {
                return
            }
        }
        
        print("Initializing settings.")
        InitializeBool(.InitializationFlag, true)
        InitializeEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .MapType)
        InitializeBool(.ShowNight, true)
        InitializeEnum(.RelativeToNoon, EnumType: HourValueTypes.self, ForKey: .HourType)
        InitializeEnum(.UTC, EnumType: TimeLabels.self, ForKey: .TimeLabel)
        InitializeDouble(.NightMaskAlpha, 0.4)
        
        InitializeBool(.ShowUserLocations, false)
        InitializeDoubleNil(.LocalLatitude, nil)
        InitializeDoubleNil(.LocalLongitude, nil)
        InitializeString(.LocalName, "")
        InitializeInt(.LocalTimeZoneOffset, 0)
        InitializeString(.UserLocations, "")
        
        InitializeBool(.Show2DEquator, true) 
        InitializeBool(.Show2DPolarCircles, true)
        InitializeBool(.Show2DTropics, true)
        InitializeBool(.Show2DPrimeMeridians, true)
        InitializeBool(.Show2DNoonMeridians, true)
        
        InitializeBool(.ShowCities, true)
        InitializeColor(.AfricanCityColor, NSColor.blue)
        InitializeColor(.AsianCityColor, NSColor.brown)
        InitializeColor(.EuropeanCityColor, NSColor.magenta)
        InitializeColor(.NorthAmericanCityColor, NSColor.green)
        InitializeColor(.SouthAmericanCityColor, NSColor.cyan)
        InitializeColor(.CapitalCityColor, NSColor.yellow)
        InitializeColor(.WorldCityColor, NSColor.red)
        
        InitializeDouble(.FieldOfView, 90.0)
        InitializeDouble(.OrthographicScale, 14.0)
        InitializeBool(.UseHDRCamera, false)
    }
    
    /// Determines if settings were initialized.
    /// - Returns: True if settings were initialized, false if not.
    public static func WasInitialized() -> Bool
    {
        return GetBool(.InitializationFlag)
    }
    
    // MARK: - Subscriber management.
    
    /// List of subscribers we send change notices to.
    static var Subscribers = [SettingChangedProtocol]()
    
    /// Add a subscriber. Subscribers receive change notices for most changes. (Initialization
    /// events are not sent.)
    /// - Parameter NewSubscriber: A new subscriber to receive change notices. Must implement
    ///                            the `SettingChangedProtocol`.
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
    
    /// Remove a subscriber. Should be called when a class/subscriber goes out of scope.
    /// - Parameter OldSubscriber: The subscriber to remove. If not present, no action is taken.
    public static func RemoveSubscriber(_ OldSubscriber: SettingChangedProtocol)
    {
        Subscribers.removeAll(where: {$0.SubscriberID() == OldSubscriber.SubscriberID()})
    }
    
    /// Called when a change to a setting value is made. The old value and new value and setting
    /// that changed is sent to the subscriber.
    /// - Note:
    ///   - Changes made via an initialization function are *not* reported to subscribers.
    ///   - Subscribers are notified even if `NewValue` has the same value as `OldValue`.
    /// - Parameter Setting: The setting that was changed.
    /// - Parameter OldValue: The value before the change.
    /// - Parameter Newvalue: The value after the change.
    public static func NotifySubscribers(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        for Subscriber in Subscribers
        {
            Subscriber.SettingChanged(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
        }
    }
    
    // MARK: - Validation functions.
    
    /// Determines if the passed type is valid for the passed setting type/key.
    /// - Parameter For: The setting key show type will be tested against `Type`.
    /// - Parameter Type: The type to test against the type in `SettingKeyTypes`.
    /// - Returns: True if the passed type matches the type in the `SettingKeyTypes` table, false otherwise.
    public static func TypeIsValid(_ For: SettingTypes, Type: Any) -> Bool
    {
        let TypeName = "\(Type)"
        if let BaseType = SettingKeyTypes[For]
        {
            let BaseName = "\(BaseType)"
            return TypeName == BaseName
        }
        return false
    }
    
    // MARK: - Boolean functions.
    
    /// Initialize a Boolean setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the boolean to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeBool(_ Setting: SettingTypes, _ Value: Bool)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Return a boolean setting value.
    /// - Parameter Setting: The setting whose boolean value will be returned.
    /// - Returns: Boolean value of the setting.
    public static func GetBool(_ Setting: SettingTypes) -> Bool
    {
        if !TypeIsValid(Setting, Type: Bool.self)
        {
            fatalError("\(Setting) is not a boolean")
        }
        return UserDefaults.standard.bool(forKey: Setting.rawValue)
    }
    
    /// Queries a boolean setting value.
    /// - Parameter Setting: The setting whose boolean value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryBool(_ Setting: SettingTypes, Completion: (Bool) -> Void)
    {
        if !TypeIsValid(Setting, Type: Bool.self)
        {
            fatalError("\(Setting) is not a boolean")
        }
        let BoolValue = UserDefaults.standard.bool(forKey: Setting.rawValue)
        Completion(BoolValue)
    }
    
    /// Save a boolean value to the specfied setting.
    /// - Parameter Setting: The setting that will be updated.
    /// - Parameter Value: The new value.
    public static func SetBool(_ Setting: SettingTypes, _ Value: Bool)
    {
        if !TypeIsValid(Setting, Type: Bool.self)
        {
            fatalError("\(Setting) is not a boolean")
        }
        let OldValue = UserDefaults.standard.bool(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - String functions.
    
    /// Initialize a String setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the string to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeString(_ Setting: SettingTypes, _ Value: String)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Returns a string from the specified setting.
    /// - Parameter Setting: The setting whose string value will be returned.
    /// - Parameter Default: If the setting does not exist, this value will be set, then returned.
    /// - Returns: String found at the specified setting, or `Default` if it does not exist.
    public static func GetString(_ Setting: SettingTypes, _ Default: String) -> String
    {
        if !TypeIsValid(Setting, Type: String.self)
        {
            fatalError("\(Setting) is not a string")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            return Raw
        }
        UserDefaults.standard.set(Default, forKey: Setting.rawValue)
        return Default
    }
    
    /// Returns a string from the specified setting.
    /// - Parameter Setting: The setting whose string value will be returned.
    /// - Returns: String found at the specified setting, or nil if it does not exist.
    public static func GetString(_ Setting: SettingTypes) -> String?
    {
        if !TypeIsValid(Setting, Type: String.self)
        {
            fatalError("\(Setting) is not a string")
        }
        return UserDefaults.standard.string(forKey: Setting.rawValue)
    }
    
    /// Returns a string from the specified setting.
    /// - Note: **Intended only for internal Settings usage.**
    /// - Parameter Setting: The setting whose string value will be returned.
    /// - Returns: String found at the specified setting, or nil if it does not exist.
    private static func GetMaskedString(_ Setting: SettingTypes) -> String?
    {
        return UserDefaults.standard.string(forKey: Setting.rawValue)
    }
    
    /// Queries a string setting value.
    /// - Parameter Setting: The setting whose String value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryString(_ Setting: SettingTypes, Completion: (String?) -> Void)
    {
        if !TypeIsValid(Setting, Type: String.self)
        {
            fatalError("\(Setting) is not a string")
        }
        let StringValue = UserDefaults.standard.string(forKey: Setting.rawValue)
        Completion(StringValue)
    }
    
    /// Save a string at the specified setting.
    /// - Parameter Setting: The setting where the string value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetString(_ Setting: SettingTypes, _ Value: String)
    {
        if !TypeIsValid(Setting, Type: String.self)
        {
            fatalError("\(Setting) is not a string")
        }
        let OldValue = UserDefaults.standard.string(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - Int functions.
    
    /// Initialize an Integer setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the integer to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeInt(_ Setting: SettingTypes, _ Value: Int)
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
    public static func GetInt(_ Setting: SettingTypes) -> Int
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
    public static func GetInt(_ Setting: SettingTypes, IfZero: Int) -> Int
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
    
    /// Queries an integer setting value.
    /// - Parameter Setting: The setting whose integer value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryInt(_ Setting: SettingTypes, Completion: (Int) -> Void)
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
    public static func SetInt(_ Setting: SettingTypes, _ Value: Int)
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
    
    // MARK: - Double functions.
    
    /// Initialize a Double setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the double to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeDouble(_ Setting: SettingTypes, _ Value: Double)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Initialize a Double? setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the double? to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeDoubleNil(_ Setting: SettingTypes, _ Value: Double? = nil)
    {
        if !TypeIsValid(Setting, Type: Double.self)
        {
            fatalError("\(Setting) is not a Double")
        }
        if let Actual = Value
        {
            UserDefaults.standard.set(Double(Actual), forKey: Setting.rawValue)
        }
        else
        {
            UserDefaults.standard.set(nil, forKey: Setting.rawValue)
        }
    }
    
    /// Returns a double value from the specified setting.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Returns: Double found at the specified setting.
    public static func GetDouble(_ Setting: SettingTypes) -> Double
    {
        if !TypeIsValid(Setting, Type: Double.self)
        {
            fatalError("\(Setting) is not a Double")
        }
        return UserDefaults.standard.double(forKey: Setting.rawValue)
    }
    
    /// Queries a double setting value.
    /// - Parameter Setting: The setting whose double value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryDouble(_ Setting: SettingTypes, Completion: (Double) -> Void)
    {
        if !TypeIsValid(Setting, Type: Double.self)
        {
            fatalError("\(Setting) is not a Double")
        }
        let DoubleValue = UserDefaults.standard.double(forKey: Setting.rawValue)
        Completion(DoubleValue)
    }
    
    /// Returns a double value from the specified setting, returning a passed value if the setting
    /// value is 0.0.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Parameter IfZero: The value to return if the stored value is 0.0.
    /// - Returns: Double found at the specified setting, the value found in `IfZero` if the stored
    ///            value is 0.0.
    public static func GetDouble(_ Setting: SettingTypes, _ IfZero: Double = 0) -> Double
    {
        if !TypeIsValid(Setting, Type: Double.self)
        {
            fatalError("\(Setting) is not a Double")
        }
        let Value = UserDefaults.standard.double(forKey: Setting.rawValue)
        if Value == 0.0
        {
            return IfZero
        }
        return Value
    }
    
    /// Returns a nilable double value from the specified setting.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Parameter Default: The default value to return if the stored value is nil. Not returned
    ///                      if the contents of `Default` is nil.
    /// - Returns: The value stored at the specified setting, the contents of `Double` if the stored
    ///            value is nil, nil if `Default` is nil.
    public static func GetDoubleNil(_ Setting: SettingTypes, _ Default: Double? = nil) -> Double?
    {
        if !TypeIsValid(Setting, Type: Double?.self)
        {
            fatalError("\(Setting) is not a Double?")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = Double(Raw)
            {
                return Final
            }
        }
        if let UseDefault = Default
        {
            UserDefaults.standard.set("\(UseDefault)", forKey: Setting.rawValue)
            return UseDefault
        }
        return nil
    }
    
    /// Queries a Double? setting value.
    /// - Parameter Setting: The setting whose Double? value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryDoubleNil(_ Setting: SettingTypes, Completion: (Double?) -> Void)
    {
        if !TypeIsValid(Setting, Type: Double?.self)
        {
            fatalError("\(Setting) is not a Double?")
        }
        let DoubleNil = GetDoubleNil(Setting)
        Completion(DoubleNil)
    }
    
    /// Save a double value at the specified setting.
    /// - Parameter Setting: The setting where the double value will be stored.
    /// - Parameter Value: The value to save.
    public static func SetDouble(_ Setting: SettingTypes, _ Value: Double)
    {
        if !TypeIsValid(Setting, Type: Double.self)
        {
            fatalError("\(Setting) is not a Double?")
        }
        let OldValue = UserDefaults.standard.double(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Save a nilable double value at the specified setting.
    /// - Note: `Double?` values are saved as strings but converted before being returned.
    /// - Parameter Setting: The setting where the double? value will be stored.
    /// - Parameter Value: The double? value to save.
    public static func SetDoubleNil(_ Setting: SettingTypes, _ Value: Double? = nil)
    {
        if !TypeIsValid(Setting, Type: Double?.self)
        {
            fatalError("\(Setting) is not a Double?")
        }
        let OldValue = GetDoubleNil(Setting)
        let NewValue = Value
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - CGFloat functions.
    
    /// Initialize a CGFloat setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the CGFloat to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeCGFloat(_ Setting: SettingTypes, _ Value: CGFloat)
    {
        UserDefaults.standard.set(Double(Value), forKey: Setting.rawValue)
    }
    
    /// Initialize a CGFloat? setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the CGFloat? to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeCGFloatNil(_ Setting: SettingTypes, _ Value: CGFloat? = nil)
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        if let Actual = Value
        {
            UserDefaults.standard.set(Double(Actual), forKey: Setting.rawValue)
        }
        else
        {
            UserDefaults.standard.set(nil, forKey: Setting.rawValue)
        }
    }
    
    /// Returns a CGFloat value from the specified setting.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Returns: CGFloat found at the specified setting.
    public static func GetCGFloat(_ Setting: SettingTypes) -> CGFloat
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        return CGFloat(UserDefaults.standard.double(forKey: Setting.rawValue))
    }
    
    /// Queries a CGFloat setting value.
    /// - Parameter Setting: The setting whose CGFloat value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryCGFloat(_ Setting: SettingTypes, Completion: (CGFloat) -> Void)
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let CGFloatValue = CGFloat(UserDefaults.standard.double(forKey: Setting.rawValue))
        Completion(CGFloatValue)
    }
    
    /// Returns a CGFloat value from the specified setting, returning a passed value if the setting
    /// value is 0.0.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Parameter IfZero: The value to return if the stored value is 0.0.
    /// - Returns: CGFloat found at the specified setting, the value found in `IfZero` if the stored
    ///            value is 0.0.
    public static func GetCGFloat(_ Setting: SettingTypes, _ IfZero: CGFloat = 0) -> CGFloat
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let Value = UserDefaults.standard.double(forKey: Setting.rawValue)
        if Value == 0.0
        {
            return IfZero
        }
        return CGFloat(Value)
    }
    
    /// Returns a nilable CGFloat value from the specified setting.
    /// - Parameter Setting: The setting whose CGFloat value will be returned.
    /// - Parameter Default: The default value to return if the stored value is nil. Not returned
    ///                      if the contents of `Default` is nil.
    /// - Returns: The value stored at the specified setting, the contents of `Double` if the stored
    ///            value is nil, nil if `Default` is nil.
    public static func GetCGFloatNil(_ Setting: SettingTypes, _ Default: CGFloat? = nil) -> CGFloat?
    {
        if !TypeIsValid(Setting, Type: CGFloat?.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = Double(Raw)
            {
                return CGFloat(Final)
            }
        }
        if let UseDefault = Default
        {
            UserDefaults.standard.set("\(UseDefault)", forKey: Setting.rawValue)
            return UseDefault
        }
        return nil
    }
    
    /// Queries a CGFloat? setting value.
    /// - Parameter Setting: The setting whose CGFloat? value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryCGFloatNil(_ Setting: SettingTypes, Completion: (CGFloat?) -> Void)
    {
        if !TypeIsValid(Setting, Type: CGFloat?.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let CGFloatNil = GetCGFloatNil(Setting)
        Completion(CGFloatNil)
    }
    
    /// Save a CGFloat value at the specified setting.
    /// - Parameter Setting: The setting where the CGFloat value will be stored.
    /// - Parameter Value: The value to save.
    public static func SetCGFloat(_ Setting: SettingTypes, _ Value: CGFloat)
    {
        if !TypeIsValid(Setting, Type: CGFloat.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let OldValue = CGFloat(UserDefaults.standard.double(forKey: Setting.rawValue))
        let NewValue = Value
        UserDefaults.standard.set(Double(NewValue), forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Save a nilable CGFloat value at the specified setting.
    /// - Note: `CGFloat?` values are saved as strings but converted before being returned.
    /// - Parameter Setting: The setting where the CGFloat? value will be stored.
    /// - Parameter Value: The CGFloat? value to save.
    public static func SetCGFloatNil(_ Setting: SettingTypes, _ Value: CGFloat? = nil)
    {
        if !TypeIsValid(Setting, Type: CGFloat?.self)
        {
            fatalError("\(Setting) is not a CGFloat")
        }
        let OldValue = GetCGFloatNil(Setting)
        let NewValue = Value
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
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
    public static func InitializeRect(_ Setting: SettingTypes, _ Value: NSRect)
    {
        let Encoded = EncodeRect(Value)
        UserDefaults.standard.set(Encoded, forKey: Setting.rawValue)
    }
    
    /// Save the value of an `NSRect` to user settings.
    /// - Parameter Setting: The setting where the `NSRect` will be stored.
    /// - Parameter Value: The value to store.
    public static func SetRect(_ Setting: SettingTypes, _ Value: NSRect)
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
    public static func GetRect(_ Setting: SettingTypes) -> NSRect?
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
    public static func GetRect(_ Setting: SettingTypes, Default: NSRect? = nil) -> NSRect
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
    
    // MARK: - Color functions.
    
    /// Initialize an NSColor setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the color to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeColor(_ Setting: SettingTypes, _ Value: NSColor)
    {
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue)
    }
    
    /// Returns a color from the specified setting.
    /// - Parameter Setting: The setting whose color will be returned.
    /// - Returns: The color stored at the specified setting, nil if not found.
    public static func GetColor(_ Setting: SettingTypes) -> NSColor?
    {
        if !TypeIsValid(Setting, Type: NSColor.self)
        {
            fatalError("\(Setting) is not an NSColor")
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
    public static func QueryColor(_ Setting: SettingTypes, Completion: (NSColor?) -> Void)
    {
        if !TypeIsValid(Setting, Type: NSColor.self)
        {
            fatalError("\(Setting) is not an NSColor")
        }
        let ColorValue = GetColor(Setting)
        Completion(ColorValue)
    }
    
    /// Returns a color from the specified setting.
    /// - Parameter Setting: The setting whose color will be returned.
    /// - Parameter Default: The value returned if the setting does not contain a valid color.
    /// - Returns: The color stored at the specified setting, the contents of `Default` if no valid
    ///            color found.
    public static func GetColor(_ Setting: SettingTypes, _ Default: NSColor) -> NSColor
    {
        if !TypeIsValid(Setting, Type: NSColor.self)
        {
            fatalError("\(Setting) is not an NSColor")
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
    public static func GetCGColor(_ Setting: SettingTypes, _ Default: NSColor) -> CGColor
    {
        if !TypeIsValid(Setting, Type: NSColor.self)
        {
            fatalError("\(Setting) is not an NSColor")
        }
        return GetColor(Setting, Default).cgColor
    }
    
    /// Save a color at the specified setting.
    /// - Parameter Setting: The setting where to save the color.
    /// - Parameter Value: The color to save.
    public static func SetColor(_ Setting: SettingTypes, _ Value: NSColor)
    {
        if !TypeIsValid(Setting, Type: NSColor.self)
        {
            fatalError("\(Setting) is not an NSColor")
        }
        let OldValue = GetColor(Setting)
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: Value)
    }
    
    // MARK: - Date-based settings.
    
    /// Initialize a date settings. No notification is sent to subscribers.
    /// - Note: Internally, dates are saved as a double with the value being the number of seconds
    ///         since 1970.
    /// - Parameter NewValue: The value to set.
    /// - Parameter ForKey: The setting key.
    public static func InitializeDate(_ NewValue: Date, ForKey: SettingTypes)
    {
        UserDefaults.standard.set(NewValue.timeIntervalSince1970, forKey: ForKey.rawValue)
    }
    
    /// Returns a date from the specified setting.
    /// - Parameter Setting: The setting key whose date value will be returned.
    /// - Returns: The date stored in the specified setting key. May be 1 January 1970 if not
    ///            previously set.
    public static func GetDate(_ Setting: SettingTypes) -> Date
    {
        if !TypeIsValid(Setting, Type: Date.self)
        {
            fatalError("\(Setting) is not a Date")
        }
        let Raw = UserDefaults.standard.double(forKey: Setting.rawValue)
        return Date(timeIntervalSince1970: Raw)
    }
    
    /// Returns a date from the specified setting. If the date appears to have not been set previously,
    /// the value in `IfZero` is returned (as well as being saved to the specified setting key).
    /// - Parameter Setting: The setting key whose date value will be returned.
    /// - Parameter IfZero: The value to save and return if the key holds `0.0` (which indicates
    ///                     no value has previously been stored.
    /// - Returns: The date stored in the specified setting, the value of `IfZero` if no previous
    ///            date was stored.
    public static func GetDate(_ Setting: SettingTypes, _ IfZero: Date) -> Date
    {
        if !TypeIsValid(Setting, Type: Date.self)
        {
            fatalError("\(Setting) is not a Date")
        }
        let Raw = UserDefaults.standard.double(forKey: Setting.rawValue)
        if Raw == 0.0
        {
            SetDate(Setting, IfZero)
            return IfZero
        }
        return Date(timeIntervalSince1970: Raw)
    }
    
    /// Save the passed date to the specified setting.
    /// - Parameter Setting: The setting key where to save the date.
    /// - Parameter Value: The value to save.
    public static func SetDate(_ Setting: SettingTypes, _ Value: Date)
    {
        if !TypeIsValid(Setting, Type: Date.self)
        {
            fatalError("\(Setting) is not a Date")
        }
        let OldValue = GetDate(Setting)
        UserDefaults.standard.set(Value.timeIntervalSince1970, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: Value)
    }
    
    // MARK: - Enum-based settings.
    
    /// Initialize an Enum-based setting. No notification is sent to subscribers.
    /// - Parameter NewValue: The value to set.
    /// - Parameter EnumType: The type of enum to save.
    /// - Parameter ForKey: The setting key.
    public static func InitializeEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingTypes)
    {
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum type 'A' to Enum type 'B'.")
        }
        UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
    }
    
    /// Return an enum case value from user settings.
    /// - Note: A fatal error is generated if `ForKey` does not point to a string setting.
    /// - Note: See: [Pass an enum type name](https://stackoverflow.com/questions/38793536/possible-to-pass-an-enum-type-name-as-an-argument-in-swift)
    /// - Parameter ForKey: The setting key that points to where the enum case is stored (as a string).
    /// - Parameter EnumType: The type of the enum to return.
    /// - Parameter Default: The default value returned for when `ForKey` has yet to be set.
    /// - Returns: Enum value (of type `EnumType`) for the specified setting key.
    public static func GetEnum<T: RawRepresentable>(ForKey: SettingTypes, EnumType: T.Type, Default: T) -> T where T.RawValue == String
    {
        if !TypeIsValid(ForKey, Type: EnumType.self)
        {
            fatalError("\(ForKey) is not \(EnumType.self)")
        }
        if let Raw = GetMaskedString(ForKey)
        {
            guard let Value = EnumType.init(rawValue: Raw) else
            {
                return Default
            }
            return Value
        }
        return Default
    }
    
    /// Return an enum case value from user settings.
    /// - Note: A fatal error is generated if `ForKey` does not point to a string setting.
    /// - Note: See: [Pass an enum type name](https://stackoverflow.com/questions/38793536/possible-to-pass-an-enum-type-name-as-an-argument-in-swift)
    /// - Parameter ForKey: The setting key that points to where the enum case is stored (as a string).
    /// - Parameter EnumType: The type of the enum to return.
    /// - Returns: Enum value (of type `EnumType`) for the specified setting key. Nil returned if the setting was not found.
    public static func GetEnum<T: RawRepresentable>(ForKey: SettingTypes, EnumType: T.Type) -> T? where T.RawValue == String
    {
        if !TypeIsValid(ForKey, Type: EnumType.self)
        {
            fatalError("\(ForKey) is not \(EnumType.self)")
        }
        if let Raw = GetMaskedString(ForKey)
        {
            guard let Value = EnumType.init(rawValue: Raw) else
            {
                return nil
            }
            return Value
        }
        return nil
    }
    
    /// Queries an enum setting value.
    /// - Parameter Setting: The setting whose enum value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryEnum<T: RawRepresentable>(_ Setting: SettingTypes, EnumType: T.Type, Completion: (T?) -> Void) where T.RawValue == String
    {
        if !TypeIsValid(Setting, Type: EnumType.self)
        {
            fatalError("\(Setting) is not \(EnumType.self)")
        }
        let EnumValue = GetEnum(ForKey: Setting, EnumType: EnumType)
        Completion(EnumValue)
    }
    
    /// Saves an enum value to user settings. This function will convert the enum value into a string (so the
    /// enum *must* be `String`-based) and save that.
    /// - Note: Fatal errors are generated if:
    ///   - `NewValue` is not from `EnumType`.
    ///   - `ForKey` does not point to a String setting.
    /// - Parameter NewValue: Enum case to save.
    /// - Parameter EnumType: The type of enum the `NewValue` is based on. If `NewValue` is not from `EnumType`,
    ///                       a fatal error will occur.
    /// - Parameter ForKey: The settings key to use to indicate where to save the value.
    /// - Parameter Completed: Closure called at the end of the saving process.
    public static func SetEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingTypes,
                                                    Completed: ((SettingTypes) -> Void)) where T.RawValue == String
    {
        if !TypeIsValid(ForKey, Type: EnumType.self)
        {
            fatalError("\(ForKey) is not \(EnumType.self)")
        }
        let OldValue = GetEnum(ForKey: ForKey, EnumType: EnumType.self)
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum A to Enum B.")
        }
        UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
        Completed(ForKey)
        NotifySubscribers(Setting: ForKey, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Saves an enum value to user settings. This function will convert the enum value into a string (so the
    /// enum *must* be `String`-based) and save that.
    /// - Note: Fatal errors are generated if:
    ///   - `NewValue` is not from `EnumType`.
    ///   - `ForKey` does not point to a String setting.
    /// - Parameter NewValue: Enum case to save.
    /// - Parameter EnumType: The type of enum the `NewValue` is based on. If `NewValue` is not from `EnumType`,
    ///                       a fatal error will occur.
    /// - Parameter ForKey: The settings key to use to indicate where to save the value.
    public static func SetEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingTypes) where T.RawValue == String
    {
        if !TypeIsValid(ForKey, Type: EnumType.self)
        {
            fatalError("\(ForKey) is not \(EnumType.self)")
        }
        let OldValue = GetEnum(ForKey: ForKey, EnumType: EnumType.self)
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum type 'A' to Enum type 'B'.")
        }
        UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
        NotifySubscribers(Setting: ForKey, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - Font settings.
    
    /// Return a stored font object.
    /// - Note: Stored fonts are stored in serialized form. Serialized stored fonts are strings. So therefore,
    ///         if no string can be found, nil is returned.
    /// - Parameter Setting: Where the stored font resides.
    /// - Returns: Deserialized stored string on success, nil if not found.
    public static func GetFont(_ Setting: SettingTypes) -> StoredFont?
    {
        if let Raw = Settings.GetString(Setting)
        {
            return StoredFont(RawValue: Raw)
        }
        return nil
    }
    
    /// Return a stored font object.
    /// - Parameter Setting: Where the stored font resides.
    /// - Parameter Default: The default to use if no stored font is found. If no stored font is found, the
    ///                      default is written to user settings.
    /// - Returns: The stored font at the specified setting, `Default` if not found.
    public static func GetFont(_ Setting: SettingTypes, _ Default: StoredFont) -> StoredFont
    {
        if let Stored = GetFont(Setting)
        {
            return Stored
        }
        SetFont(Setting, Default)
        return Default
    }
    
    /// Save a stored font object.
    /// - Parameter Setting: Where to save the stored font.
    /// - Paramater Value: The stored font to save. It is serialized before being saved.
    public static func SetFont(_ Setting: SettingTypes, _ Value: StoredFont)
    {
        let PreviousFont = GetFont(Setting)
        let Serialized = Value.SerializeFont()
        UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: PreviousFont, NewValue: Value)
    }
    
    /// Extract the font name from a saved font record. Font records have the name as the first item in the
    /// font record.
    /// - Parameter From: The font record from which the font name will be extracted.
    /// - Returns: The name of the font from the passed font record. Nil on error.
    public static func ExtractFontName(From Saved: String) -> String?
    {
        let Parts = Saved.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count < 1
        {
            return nil
        }
        let Part = String(Parts[0])
        return Part
    }
    
    /// Extract the font size from a saved font record. Font records have the size as the second item in the
    /// font record.
    /// - Parameter From: The font record from which the font size will be extracted.
    /// - Returns: The size of the font from the passed font record. Nil on error.
    public static func ExtractFontSize(From Saved: String) -> CGFloat?
    {
        let Parts = Saved.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count < 2
        {
            return nil
        }
        let Part = String(Parts[1])
        if let DFontSize = Double(Part)
        {
            return CGFloat(DFontSize)
        }
        return nil
    }
    
    // MARK: - SCNVector3 settings.
    
    /// Get a stored `SCNVector3` value from settings.
    /// - Note: If the specified setting does not exist or returns an error when it is parsed, the default
    ///         value will be stored in its place and returned.
    /// - Parameter Setting: The setting key where the vector lives in the setting.
    /// - Parameter Default: The default value returned if there is no valid value currently stored in
    ///                      the settings. Standard default value is (0.0, 0.0, 0.0).
    /// - Returns: Populated `SCNVector3` value from user settings. If not available, the value of `Default`
    ///            is returned.
    public static func GetVector(_ Setting: SettingTypes, _ Default: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) -> SCNVector3
    {
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let StoredVector = SCNVector3.Deserialize(Raw)
            {
                return StoredVector
            }
        }
        let Serialized = SCNVector3.Serialize(Default)
        UserDefaults.standard.setValue(Serialized, forKey: Setting.rawValue)
        return Default
    }
    
    /// Saves the passed `SCNVector3` value in user settings.
    /// - Parameter Setting: The setting key where to store the value.
    /// - Parameter NewValue: The value to store.
    public static func SetVector(_ Setting: SettingTypes, _ NewValue: SCNVector3)
    {
        let Serialized = SCNVector3.Serialize(NewValue)
        UserDefaults.standard.setValue(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: nil, NewValue: NewValue as Any)
    }
    
    // MARK: - Special settings.
    
    /// Load earthquake regions.
    /// - Returns: Array of previously stored earthquake regions. Empty if no regions available.
    public static func GetEarthquakeRegions() -> [EarthquakeRegion]
    {
        var Regions = [EarthquakeRegion]()
        let Raw = UserDefaults.standard.string(forKey: SettingTypes.EarthquakeRegions.rawValue)
        if let Parts = Raw?.split(separator: "∫", omittingEmptySubsequences: true)
        {
            for Part in Parts
            {
                if let Region = EarthquakeRegion.Decode(Raw: String(Part))
                {
                    Regions.append(Region)
                }
            }
        }
        return Regions
    }
    
    /// Save earthquake regions.
    /// - Parameter Regions: Array of earthquake regions to save.
    public static func SetEarthquakeRegions(_ Regions: [EarthquakeRegion])
    {
        var Final: String = ""
        for Region in Regions
        {
            Final.append("\(Region)")
            Final.append("∫")
        }
        UserDefaults.standard.setValue(Final, forKey: SettingTypes.EarthquakeRegions.rawValue)
        NotifySubscribers(Setting: .EarthquakeRegions, OldValue: nil, NewValue: Regions as Any)
    }
    
    /// Parse a single entry in the stored earthquake magnitude level to color.
    /// - Parameter Mag: Raw magnitude value.
    /// - Parameter Color: Raw color value.
    /// - Parameter FinalMag: On success, the magnitude level. On failure, undefined.
    /// - Parameter FinalColor: On success, the color for the associated magnitude. On failure, undefined.
    /// - Returns: True if `Mag` and `Color` are well-defined, false otherwise. If false is returned,
    ///            `FinalMag` and `FinalColor` are undefined.
    private static func IsValidMagColor(_ Mag: String, _ Color: String, _ FinalMag: inout Double,
                                        _ FinalColor: inout NSColor) -> Bool
    {
        let SomeDouble = Double(Mag)
        let SomeColor = NSColor(HexString: Color)
        if SomeDouble == nil || SomeColor == nil
        {
            return false
        }
        FinalMag = SomeDouble!
        FinalColor = SomeColor!
        return true
    }
    
    /// Get a dictionary of earthquake magnitudes to colors.
    /// - Returns: Dictionary of colors to earthquake magnitude levels.
    public static func GetMagnitudeColors() -> [EarthquakeMagnitudes: NSColor]
    {
        if let Raw = UserDefaults.standard.string(forKey: SettingTypes.EarthquakeMagnitudeColors.rawValue)
        {
            let Parts = Raw.split(separator: ";", omittingEmptySubsequences: true)
            if Parts.count == 6
            {
                var ColorDict = [EarthquakeMagnitudes: NSColor]()
                for Part in Parts
                {
                    let SubParts = String(Part).split(separator: ",", omittingEmptySubsequences: true)
                    if SubParts.count != 2
                    {
                        SetMagnitudeColors(DefaultMagnitudeColors(), Notify: false)
                        return DefaultMagnitudeColors()
                    }
                    var FinalMag: Double = 0.0
                    var FinalColor: NSColor = NSColor.white
                    if !IsValidMagColor(String(SubParts[0]), String(SubParts[1]), &FinalMag, &FinalColor)
                    {
                        SetMagnitudeColors(DefaultMagnitudeColors(), Notify: false)
                        return DefaultMagnitudeColors()
                    }
                    let MagIndex = EarthquakeMagnitudes(rawValue: FinalMag)!
                    ColorDict[MagIndex] = FinalColor
                }
                return ColorDict
            }
        }
        SetMagnitudeColors(DefaultMagnitudeColors(), Notify: false)
        return DefaultMagnitudeColors()
    }
    
    /// Returns a dictionary of default colors for earthquake magnitudes.
    /// - Returns: Dictionary of colors to earthquake magnitude levels.
    public static func DefaultMagnitudeColors() -> [EarthquakeMagnitudes: NSColor]
    {
        let ColorDict: [EarthquakeMagnitudes: NSColor] =
            [
                .Mag4: NSColor(HexString: "#FEFCBF")!,
                .Mag5: NSColor(HexString: "#FEFB00")!,
                .Mag6: NSColor(HexString: "#FFD478")!,
                .Mag7: NSColor(HexString: "#FF9300")!,
                .Mag8: NSColor(HexString: "#FF2F92")!,
                .Mag9: NSColor(HexString: "#FF2400")!
            ]
        return ColorDict
    }
    
    /// Save a set of colors associated with earthquake magnitude levels.
    /// - Parameter MagColors: A dictionary of colors for magnitude levels.
    /// - Parameter Notify: If true, subscribers are notified of changes. Defaults to `true`.
    public static func SetMagnitudeColors(_ MagColors: [EarthquakeMagnitudes: NSColor], Notify: Bool = true)
    {
        var Final = ""
        for (Mag, Color) in MagColors
        {
            Final.append("\(Mag.rawValue),\(Color.Hex);")
        }
        UserDefaults.standard.set(Final, forKey: SettingTypes.EarthquakeMagnitudeColors.rawValue)
        if Notify
        {
            NotifySubscribers(Setting: .EarthquakeMagnitudeColors, OldValue: nil, NewValue: MagColors)
        }
    }
    
    /// Determines if both the local latitude and local longitude have been set.
    /// - Returns: True if the device location has been set, false if not.
    public static func HaveLocalLocation() -> Bool
    {
        if GetDoubleNil(.LocalLatitude) == nil
        {
            return false
        }
        if GetDoubleNil(.LocalLongitude) == nil
        {
            return false
        }
        return true
    }
    
    /// Save a list of user locations.
    /// - Note: User locations are saved at `SettingTypes.UserLocations`.
    /// - Parameter List: List of location information to save.
    public static func SetLocations(_ List: [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: NSColor)])
    {
        if List.count == 0
        {
            UserDefaults.standard.set("", forKey: SettingTypes.UserLocations.rawValue)
            return
        }
        var LocationList = ""
        for (ID, Location, Name, Color) in List
        {
            var Item = ID.uuidString + ","
            Item.append("\(Location.Latitude),\(Location.Longitude),")
            Item.append("\(Name),")
            let ColorName = Color.Hex
            Item.append("\(ColorName);")
            LocationList.append(Item)
        }
        UserDefaults.standard.set(LocationList, forKey: "UserLocations")
        NotifySubscribers(Setting: .UserLocations, OldValue: nil, NewValue: nil)
    }
    
    /// Get the list of user locations.
    /// - Note: User locations are saved at `SettingTypes.UserLocations`.
    /// - Returns: List of user location information.
    public static func GetLocations() -> [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: NSColor)]
    {
        var Results = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: NSColor)]()
        if let Raw = UserDefaults.standard.string(forKey: "UserLocations")
        {
            let Locations = Raw.split(separator: ";", omittingEmptySubsequences: true)
            for Where in Locations
            {
                var ID: UUID = UUID()
                var Lat: Double = 0.0
                var Lon: Double = 0.0
                var Name: String = ""
                var Color: NSColor = NSColor.red
                let Raw = String(Where)
                let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
                if Parts.count == 5
                {
                    for Index in 0 ..< Parts.count
                    {
                        let Part = String(Parts[Index]).trimmingCharacters(in: CharacterSet.whitespaces)
                        switch Index
                        {
                            case 0:
                                ID = UUID(uuidString: Part)!
                                
                            case 1:
                                Lat = Double(Part)!
                                
                            case 2:
                                Lon = Double(Part)!
                                
                            case 3:
                                Name = Part
                                
                            case 4:
                                if let ProcessedColor = NSColor(HexString: Part)
                                {
                                    Color = ProcessedColor
                                }
                                else
                                {
                                    Color = NSColor.red
                                }
                                
                            default:
                                break
                        }
                    }
                }
                Results.append((ID: ID, GeoPoint2(Lat, Lon), Name: Name, Color: Color))
            }
        }
        else
        {
            return []
        }
        return Results
    }
    
    /// Returns the default city group color.
    /// - Parameter For: The city group for which the default color will be returned.
    /// - Returns: Color for the specified city group.
    public static func DefaultCityGroupColor(For: CityGroups) -> NSColor
    {
        switch For
        {
            case .AfricanCities:
                return NSColor.blue
                
            case .AsianCities:
                return NSColor.brown
                
            case .EuropeanCities:
                return NSColor.magenta
                
            case .NorthAmericanCities:
                return NSColor.green
                
            case .SouthAmericanCities:
                return NSColor.cyan
                
            case .WorldCities:
                return NSColor.red
                
            case .CapitalCities:
                return NSColor.yellow
        }
    }
    
    /// Determines if the specific longitude line should be drawn.
    /// - Parameter Longitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    public static func DrawLongitudeLine(_ Longitude: Longitudes) -> Bool
    {
        switch Longitude
        {
            case .AntarcticCircle, .ArcticCircle:
                return Settings.GetBool(.Show3DPolarCircles)
                
            case .Equator:
                return Settings.GetBool(.Show3DEquator)
                
            case .TropicOfCancer, .TropicOfCapricorn:
                return Settings.GetBool(.Show3DTropics)
        }
    }
    
    /// Determines if the specific latitude line should be drawn.
    /// - Parameter Latitude: The line whose drawing status will be returned.
    /// - Returns: True if the line should be drawn, false if not.
    public static func DrawLatitudeLine(_ Latitude: Latitudes) -> Bool
    {
        switch Latitude
        {
            case .PrimeMeridian, .OtherPrimeMeridian:
                return Settings.GetBool(.Show3DPrimeMeridians)
                
            case .AntiPrimeMeridian, .OtherAntiPrimeMeridian:
                return Settings.GetBool(.Show3DPrimeMeridians)
        }
    }
    
    // MARK: - Custom city lists
    
    /// Returns the list of all cities in the user's custom city list.
    /// - Note: Invalid city IDs (eg, not property formed UUIDs) are ignored and not added to the returned list.
    /// - Returns: List of city IDs.
    public static func GetCustomCities() -> [UUID]
    {
        var IDList = [UUID]()
        let Raw = Settings.GetString(.CustomCityList, "")
        if Raw.isEmpty
        {
            return IDList
        }
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let RawID = String(Part)
            if let CityID = UUID(uuidString: RawID)
            {
                IDList.append(CityID)
            }
        }
        return IDList
    }
    
    /// Save the user's custom city list.
    /// - Parameter List: The list of custom cities created by the user. Each item in the list is a valid
    ///                   city ID found in the city table.
    /// - Parameter Notify: If true, subscribers are notified of changes to the list when it is set.
    public static func SetCustomCities(_ List: [UUID], Notify: Bool = true)
    {
        var Working = ""
        for ID in List
        {
            Working.append(ID.uuidString)
            Working.append(",")
        }
        UserDefaults.standard.setValue(Working, forKey: SettingTypes.CustomCityList.rawValue)
        if Notify
        {
            NotifySubscribers(Setting: .CustomCityList, OldValue: nil, NewValue: List)
        }
    }
    
    // MARK: - Notified earthquake list.
    
    /// Returns all earthquakes the user has been notified about. Earthquakes older than 30 days old are
    /// discarded here and not returned.
    /// - Returns: Array of tuples of an earthquake ID and its age in reference seconds.
    public static func GetNotifiedEarthquakes() -> [(String, Double)]
    {
        let Raw = Settings.GetString(.NotifiedEarthquakes, "")
        if Raw.isEmpty
        {
            return [(String, Double)]()
        }
        let Now = Date().timeIntervalSinceReferenceDate
        let Parts = Raw.split(separator: "/", omittingEmptySubsequences: true)
        var Final = [(String, Double)]()
        for Part in Parts
        {
            let SubParts = Part.split(separator: ",", omittingEmptySubsequences: true)
            if SubParts.count != 2
            {
                continue
            }
            let ID = String(SubParts[0])
            let RawTime = String(SubParts[1])
            if let When = Double(RawTime)
            {
                let Delta = Now - When
                let Days = Delta / (24.0 * 60.0 * 60.0)
                if Days < 31.0
                {
                    Final.append((ID, When))
                }
            }
        }
        return Final
    }
    
    /// Save earthquakes the user has been notified about.
    /// - Parameter QuakeList: The list of earthquakes (tuple of USGS ID and reference seconds)) to save.
    public static func SetNotifiedEarthquakes(_ QuakeList: [(String, Double)])
    {
        var Final = ""
        for (ID, When) in QuakeList
        {
            let Quake = "\(ID)/\(When),"
            Final.append(Quake)
        }
        UserDefaults.standard.set(Final, forKey: SettingTypes.NotifiedEarthquakes.rawValue)
    }
    
    // MARK: - Generic setting handling.
    
    /// Set a value to the settings.
    /// - Note: This function does not support enum-based settings.
    /// - Parameter For: The setting key where to store the value.
    /// - Parameter Value: The value to store as to `Any?`.
    /// - Parameter CompletionHandler: Called after the operation has completed. Will have errors if any
    ///                                occurred.
    public static func SetValue(For Key: SettingTypes, _ Value: Any?,
                                CompletionHandler: ((Result<Any, SettingErrors>) -> ())? = nil)
    {
        if let KeyType = SettingKeyTypes[Key]
        {
            let KeyTypeName = "\(KeyType.self)"
            switch KeyTypeName
            {
                case "Int":
                    if let FinalInt = Value as? Int
                    {
                        SetInt(Key, FinalInt)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "Double":
                    if let FinalDouble = Value as? Double
                    {
                        SetDouble(Key, FinalDouble)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "Double?":
                    if let FinalDoubleNil = Value as? Double?
                    {
                        SetDoubleNil(Key, FinalDoubleNil)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "CGFloat":
                    if let FinalCGFloat = Value as? CGFloat
                    {
                        SetCGFloat(Key, FinalCGFloat)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "CGFloat?":
                    if let FinalCGFloatNil = Value as? CGFloat?
                    {
                        SetCGFloatNil(Key, FinalCGFloatNil)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "String":
                    if let FinalString = Value as? String
                    {
                        SetString(Key, FinalString)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "SCNVector3":
                    if let FinalVector = Value as? SCNVector3
                    {
                        SetVector(Key, FinalVector)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "Date":
                    if let FinalDate = Value as? Date
                    {
                        SetDate(Key, FinalDate)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "NSColor":
                    if let FinalColor = Value as? NSColor
                    {
                        SetColor(Key, FinalColor)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "NSRect":
                    if let FinalRect = Value as? NSRect
                    {
                        SetRect(Key, FinalRect)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                case "Bool":
                    if let FinalBool = Value as? Bool
                    {
                        SetBool(Key, FinalBool)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    return
                    
                default:
                    CompletionHandler?(.failure(.BadType))
            }
        }
        CompletionHandler?(.failure(.NoType))
    }
    
    /// Attempts to return the value (cast to `Any?`) of the passed setting key. The value is returned to the
    /// completion handler.
    /// - Note: Enum types are not supported here.
    /// - Parameter For: The setting key whose value will be returned.
    /// - Parameter CompletionHandler: The closure to which the result is returned.
    public static func GetValue(For Key: SettingTypes,
                                CompletionHandler: @escaping (Result<(Any?, Any), SettingErrors>) -> ())
    {
        if let KeyType = SettingKeyTypes[Key]
        {
            let KeyTypeName = "\(KeyType.self)"
            switch KeyTypeName
            {
                case "Int":
                    CompletionHandler(.success((GetInt(Key) as Any?, KeyType)))
                    return
                    
                case "Double":
                    CompletionHandler(.success((GetDouble(Key) as Any?, KeyType)))
                    return
                    
                case "Double?":
                    CompletionHandler(.success((GetDoubleNil(Key) as Any?, KeyType)))
                    return
                    
                case "CGFloat":
                    CompletionHandler(.success((GetCGFloat(Key) as Any?, KeyType)))
                    return
                    
                case "CGFloat?":
                    CompletionHandler(.success((GetCGFloatNil(Key) as Any?, KeyType)))
                    return
                    
                case "String":
                    CompletionHandler(.success((GetString(Key) as Any?, KeyType)))
                    return
                    
                case "SCNVector3":
                    CompletionHandler(.success((GetVector(Key) as Any?, KeyType)))
                    return
                    
                case "Date":
                    CompletionHandler(.success((GetDate(Key) as Any?, KeyType)))
                    return
                    
                case "NSColor":
                    CompletionHandler(.success((GetColor(Key) as Any?, KeyType)))
                    return
                    
                case "NSRect":
                    CompletionHandler(.success((GetRect(Key) as Any?, KeyType)))
                    return
                    
                case "Bool":
                    CompletionHandler(.success((GetBool(Key) as Any?, KeyType)))
                    return
                    
                default:
                    CompletionHandler(.failure(.BadType))
            }
        }
        CompletionHandler(.failure(.NoType))
    }
}

/// Setting errors that may occur.
enum SettingErrors: String, CaseIterable, Error
{
    /// No error - operation was a success.
    case Success = "Success"
    /// Bad type specified.
    case BadType = "BadType"
    /// No type found for setting key.
    case NoType = "NoType"
    /// Error converting from one type to another.
    case ConversionError = "ConversionError"
}
