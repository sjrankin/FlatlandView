//
//  SCNVector3.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension SCNVector3
{
    init(_ Value: Double)
    {
        self = SCNVector3(Value, Value, Value)
    }
    
    init(_ Value: CGFloat)
    {
        self = SCNVector3(Value, Value, Value)
    }
    
    init(_ Value: Float)
    {
        self = SCNVector3(Value, Value, Value)
    }
    
    init(_ Value: Int)
    {
        self = SCNVector3(Value, Value, Value)
    }
    
    /// Serialize an `SCNVector3` structure into a string.
    /// - Parameter Vector: The SCNVector3 value to serialize.
    /// - Returns: Serialized version of the passed `SCNVector3` value.
    public static func Serialize(_ Vector: SCNVector3) -> String
    {
        let Serialized = "\(Vector.x),\(Vector.y),\(Vector.z)"
        return Serialized
    }
    
    /// Deserialize a previously serialized `SCNVector3` value.
    /// - Note: The expected format is a string with double values separated by commas.
    /// - Note: Strings passed to this function should be serialized with `SCNVector3.Serialize`.
    /// - Parmaeter Serialized: The previously serialized `SCNVector3` value.
    /// - Returns: `SCNVector3` structure populated with the values parsed from `Serialized`. Nil on error.
    public static func Deserialize(_ Serialized: String) -> SCNVector3?
    {
        let Parts = Serialized.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            return nil
        }
        var X: Double = 0.0
        var Y: Double = 0.0
        var Z: Double = 0.0
        if let PartX = Double(String(Parts[0]))
        {
            X = PartX
        }
        else
        {
            Debug.Print("\(#function): Failed to parse 'X' value: \(String(Parts[0]))")
            return nil
        }
        if let PartY = Double(String(Parts[1]))
        {
            Y = PartY
        }
        else
        {
            Debug.Print("\(#function): Failed to parse 'Y' value: \(String(Parts[1]))")
            return nil
        }
        if let PartZ = Double(String(Parts[2]))
        {
            Z = PartZ
        }
        else
        {
            Debug.Print("\(#function): Failed to parse 'Z' value: \(String(Parts[2]))")
            return nil
        }
        return SCNVector3(X, Y, Z)
    }
    
    public static func Degrees(_ X: Double, _ Y: Double, _ Z: Double) -> SCNVector3
    {
        let XRadians = X.Radians
        let YRadians = Y.Radians
        let ZRadians = Z.Radians
        return SCNVector3(XRadians, YRadians, ZRadians)
    }
}
