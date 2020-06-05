//
//  Settings.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

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
        return UserDefaults.standard.bool(forKey: Setting.rawValue)
    }
    
    /// Save a boolean value to the specfied setting.
    /// - Parameter Setting: The setting that will be updated.
    /// - Parameter Value: The new value.
    public static func SetBool(_ Setting: SettingTypes, _ Value: Bool)
    {
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
        return UserDefaults.standard.string(forKey: Setting.rawValue)
    }
    
    /// Save a string at the specified setting.
    /// - Parameter Setting: The setting where the string value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetString(_ Setting: SettingTypes, _ Value: String)
    {
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
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Returns an integer from the specified setting.
    /// - Parameter Setting: The setting whose integer value will be returned.
    /// - Returns: Integer found at the specified setting.
    public static func GetInt(_ Setting: SettingTypes) -> Int
    {
        UserDefaults.standard.integer(forKey: Setting.rawValue)
    }
    
    /// Save an integer at the specified setting.
    /// - Parameter Setting: The setting where the integer value will be saved.
    /// - Parameter Value: The value to save.
    public static func SetInt(_ Setting: SettingTypes, _ Value: Int)
    {
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
        UserDefaults.standard.double(forKey: Setting.rawValue)
    }
    
    /// Returns a double value from the specified setting, returning a passed value if the setting
    /// value is 0.0.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Parameter IfZero: The value to return if the stored value is 0.0.
    /// - Returns: Double found at the specified setting, the value found in `IfZero` if the stored
    ///            value is 0.0.
    public static func GetDouble(_ Setting: SettingTypes, _ IfZero: Double = 0) -> Double
    {
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
    
    /// Save a double value at the specified setting.
    /// - Parameter Setting: The setting where the double value will be stored.
    /// - Parameter Value: The value to save.
    public static func SetDouble(_ Setting: SettingTypes, _ Value: Double)
    {
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
        let OldValue = GetDoubleNil(Setting)
        let NewValue = Value
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
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
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = NSColor(HexString: Raw)
            {
                return Final
            }
        }
        return nil
    }
    
    /// Returns a color from the specified setting.
    /// - Parameter Setting: The setting whose color will be returned.
    /// - Parameter Default: The value returned if the setting does not contain a valid color.
    /// - Returns: The color stored at the specified setting, the contents of `Default` if no valid
    ///            color found.
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
    
    /// Save a color at the specified setting.
    /// - Parameter Setting: The setting where to save the color.
    /// - Parameter Value: The color to save.
    public static func SetColor(_ Setting: SettingTypes, _ Value: NSColor)
    {
        let OldValue = GetColor(Setting)
        UserDefaults.standard.set(Value.Hex, forKey: Setting.rawValue)
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
        if let Raw = GetString(ForKey)
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
        if let Raw = GetString(ForKey)
        {
            guard let Value = EnumType.init(rawValue: Raw) else
            {
                return nil
            }
            return Value
        }
        return nil
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
        let OldValue = GetEnum(ForKey: ForKey, EnumType: EnumType.self)
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum type 'A' to Enum type 'B'.")
        }
        UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
        NotifySubscribers(Setting: ForKey, OldValue: OldValue, NewValue: NewValue)
    }
    
    // MARK: - Special settings.
    
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
}
