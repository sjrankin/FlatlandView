//
//  +Generic.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension Settings
{
    // MARK: - Generic setting handling.
    
    /// Set a value to the settings.
    /// - Note: This function does not support enum-based settings.
    /// - Parameter For: The setting key where to store the value.
    /// - Parameter Value: The value to store as to `Any?`.
    /// - Parameter CompletionHandler: Called after the operation has completed. Will have errors if any
    ///                                occurred.
    public static func SetValue(For Key: SettingKeys, _ Value: Any?,
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
                    
                case "NSSize":
                    if let FinalSize = Value as? NSSize
                    {
                        SetNSSize(Key, FinalSize)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    
                case "CGPoint":
                    if let FinalPoint = Value as? CGPoint
                    {
                        SetCGPoint(Key, FinalPoint)
                        CompletionHandler?(.success(KeyType.self))
                    }
                    else
                    {
                        CompletionHandler?(.failure(.ConversionError))
                    }
                    
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
    public static func GetValue(For Key: SettingKeys,
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
                    
                case "NSSize":
                    CompletionHandler(.success((GetNSSize(Key) as Any?, KeyType)))
                    
                case "CGPoint":
                    CompletionHandler(.success((GetCGPoint(Key) as Any?, KeyType)))
                    
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
