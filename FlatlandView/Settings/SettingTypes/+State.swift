//
//  +State.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Thin wrapper around boolean functions that return simple state values instead.
/// This extension is intended to be used with user interface controls as a set of
/// convenience methods for cleaner code.
extension Settings
{
    // MARK: - State (boolean) functions.
    
    /// Returns the state of the setting.
    /// - Note: Only `.on` and `.off` are supported.
    /// - Parameter Setting: The setting whose state will be returned.
    /// - Returns: Setting value stored in the passed setting key.
    public static func GetState(_ Setting: SettingKeys) -> NSControl.StateValue
    {
        return GetBool(Setting) ? .on : .off
    }
    
    /// Set the state of the setting.
    /// - Note: Only `.on` and `.off` are supported. All states not `.on` and `.off`
    ///         will be converted to `false` when stored internally.
    /// - Parameter Setting: The setting whose state will be set.
    public static func SetState(_ Setting: SettingKeys, _ Value: NSControl.StateValue)
    {
        let Actual = Value == .on ? true : false
        SetBool(Setting, Actual)
    }
    
    /// Queries a state setting value.
    /// - Warning: A fatal error is generated if the setting key does not resolve to a boolean.
    /// - Note: Only `.on` and `.off` are supported.
    /// - Parameter Setting: The setting key that will be queried.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is
    ///                         passed to the completion handler.
    public static func QueryState(_ Setting: SettingKeys, Completion: (NSControl.StateValue) -> Void)
    {
        if !TypeIsValid(Setting, Type: Bool.self)
        {
            fatalError("\(Setting) is not a boolean")
        }
            let ActualValue: NSControl.StateValue = UserDefaults.standard.bool(forKey: Setting.rawValue) ? .on : .off
            Completion(ActualValue)
    }
    
    /// Inverts the state of the setting.
    /// - Note: Only `.on` and `.off` are supported.
    /// - Parameter Setting: The setting whose state will be inverted (eg, `.on` to `.off` or `.off` to `.on`).
    /// - Parameter SendNotification: If true, a notification of the change will be sent to all subscribers.
    /// - Returns: The inverted state value.
    public static func InvertState(_ Setting: SettingKeys, SendNotification: Bool = true) -> NSControl.StateValue
    {
        let OldState = GetState(Setting)
        var NewState: NSControl.StateValue = .on
        if OldState == .on
        {
            NewState = .off
        }
        else
        {
            NewState = .on
        }
        UserDefaults.standard.set(NewState == .on ? true : false, forKey: Setting.rawValue)
        if SendNotification
        {
            NotifySubscribers(Setting: Setting, OldValue: OldState, NewValue: NewState)
        }
        return NewState
    }
    
    /// Toggles the state of the the passed setting key. Thin wrapper around `InvertState`.
    /// - Note: Only `.on` and `.off` are supported.
    /// - Parameter Setting: The setting key whose value will be inverted.
    /// - Parameter SendNotification: If true, a notification of the change will be sent to all subscribers.
    /// - Returns: New setting value.
    @discardableResult public static func ToggleState(_ Setting: SettingKeys, SendNotification: Bool = true) -> NSControl.StateValue
    {
        return InvertState(Setting, SendNotification: SendNotification)
    }
}
