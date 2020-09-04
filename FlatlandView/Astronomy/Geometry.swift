//
//  Geometry.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Geometry-related functions.
class Geometry
{
    /// Convert the passed number of degrees to its radial equivalent.
    ///
    /// - Parameter Degrees: Degrees to convert.
    /// - Returns: Radians equivalent to the passed number of degrees.
    public static func ToRadians(_ Degrees: Double) -> Double
    {
        return Degrees * Double.pi / 180.0
    }
    
    /// Convert the passed number of radians to its degree equivalent.
    ///
    /// - Parameter Radians: Radians to convert.
    /// - Returns: Degrees equivalent to the passed number of Radians.
    public static func ToDegrees(_ Radians: Double) -> Double
    {
        return Radians * 180.0 / Double.pi
    }
    
    #if false
    /// Implementation of the Haversine formula to calculate great circle distances.
    /// https://www.movable-type.co.uk/scripts/latlong.html
    /// https://www.codeguru.com/cpp/cpp/algorithms/article.php/c5115/Geographic-Distance-and-Azimuth-Calculations.htm
    ///
    /// - Parameters:
    ///   - Point1: First point on surface of sphere.
    ///   - Point2: Second point on surface of sphere.
    /// - Returns: Distance (in km) between Point1 and Point2. If both points have the same location, 0.0 is returned.
    public static func Haversine(Point1: GeoPoint, Point2: GeoPoint) -> Double
    {
        let EquitorialRadius: Double = 6378.137     //WGS84
        
        if Point1.Latitude == Point2.Latitude && Point1.Longitude == Point2.Longitude
        {
            return 0.0
        }
        let Phi1 = ToRadians(Point1.Latitude)
        let Phi2 = ToRadians(Point2.Latitude)
        let DeltaPhi = ToRadians(Point2.Latitude - Point1.Latitude)
        let DeltaGamma = ToRadians(Point2.Longitude - Point1.Longitude)
        var a = sin(DeltaPhi / 2.0) * sin(DeltaPhi / 2.0)
        a = a + cos(Phi1) * cos(Phi2) * sin(DeltaGamma / 2.0) * sin(DeltaGamma / 2.0)
        let C = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
        let Distance = EquitorialRadius * C
        return Distance
    }
    
    /// Return the initial bearing from the start point to the end point. Uses forward azimuth to calculate bearing.
    /// https://www.movable-type.co.uk/scripts/latlong.html
    /// https://www.codeguru.com/cpp/cpp/algorithms/article.php/c5115/Geographic-Distance-and-Azimuth-Calculations.htm
    ///
    /// - Parameters:
    ///   - Start: Start point.
    ///   - End: End point.
    /// - Returns: Initial bearing from the start point to the end point.
    public static func Bearing(Start: GeoPoint, End: GeoPoint) -> Double
    {
        if Start.Latitude == End.Latitude && Start.Longitude == End.Longitude
        {
            return 0.0
        }
        let Phi1 = ToRadians(Start.Latitude)
        let Phi2 = ToRadians(End.Latitude)
        let Gamma1 = ToRadians(Start.Longitude)
        let Gamma2 = ToRadians(End.Longitude)
        let y = sin(Gamma2 - Gamma1) * cos(Phi2)
        let x = (cos(Phi1) * sin(Phi2)) - cos(Gamma2 - Gamma1)
        var Final = atan2(y,x)
        Final = ToDegrees(Final)
        var IFinal = Int(Final)
        IFinal = (IFinal + 360) % 360
        return Double(IFinal)
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    ///
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public static func Bearing2(Start: GeoPoint, End: GeoPoint) -> Int
    {
        let StartLat = ToRadians(Start.Latitude)
        let StartLon = ToRadians(Start.Longitude)
        let EndLat = ToRadians(End.Latitude)
        let EndLon = ToRadians(End.Longitude)
        
        if cos(EndLat) * sin(EndLon - StartLon) == 0
        {
            if EndLat > StartLat
            {
                return 0
            }
            else
            {
                return 180
            }
        }
        var Angle = atan2(cos(EndLat) * sin(EndLon - StartLon),
                          sin(EndLat) * cos(StartLat) - sin(StartLat) * cos(EndLat) * cos(EndLon - StartLon))
        Angle = ToDegrees(Angle)
        var IAngle = Int(Angle)
        IAngle = IAngle + 360
        IAngle = IAngle % 360
        return IAngle
    }
    
    /// Calculate the bearing to the End point using flat map style calculations.
    ///
    /// - Parameters:
    ///   - Start: Start point.
    ///   - End: End point.
    /// - Returns: Bearing to the end point using flat map calculations. (Bearing will not change.)
    public static func Bearing3(Start: GeoPoint, End: GeoPoint) -> Int
    {
        if Start.Latitude == End.Latitude && Start.Longitude == End.Longitude
        {
            return 0
        }
        var Theta: Double = atan2(End.Y, End.X)
        if Theta < 0.0
        {
            Theta = Theta + (Double.pi * 2.0)
        }
        let Degrees = ToDegrees(Theta)
        var IDegrees = Int(Degrees)
        IDegrees = (IDegrees - 90 + 360) % 360
        return IDegrees
    }
    
    /// Return the bearing from Start to End.
    ///
    /// - Parameters:
    ///   - Start: The starting point.
    ///   - End: The ending point.
    ///   - UseGreatCircle: If true, the forward azimuth (eg, Great Circle) algorithm will be used. Otherwise, flat map bearings will be calculated.
    /// - Returns: Bearing from Start to End. If UseGreatCircle is true, the bearing will vary over the course of the arc.
    public static func Bearing(Start: GeoPoint, End: GeoPoint, UseGreatCircle: Bool = true) -> Int
    {
        if UseGreatCircle
        {
            return Bearing2(Start: Start, End: End)
        }
        else
        {
            return Bearing3(Start: Start, End: End)
        }
    }
    #endif
    
    /// Uses the spherical law of cosines to calculate the distance between two points on a
    /// sphere (presumably a idealized Earth).
    /// - Notes: The value returned is unitless. The caller must multiply the returned value
    ///          by the desired number of units.
    /// - See: [Haversine and Law of Cosines in Excel](https://notunreasonable.com/2011/09/19/latlon-distance-formula-in-excel-haversine-and-spherical-law-of-cosines/)
    /// - See: `LawOfCosines(GeoPoint2,GeoPoint2,Radius)`
    /// - Parameter Point1: First point.
    /// - Parameter Point2: Second point.
    /// - Returns: Unitless distance between the two points. The caller must multiply the
    ///            value by whatever units are appropriate to get the final distance.
    public static func LawOfCosines(Point1: GeoPoint, Point2: GeoPoint) -> Double
    {
        //Convert to radians.
        let P1Lat = Point1.Latitude * Double.pi / 180.0
        let P2Lat = Point2.Latitude * Double.pi / 180.0
        let P1Lon = Point1.Longitude * Double.pi / 180.0
        let P2Lon = Point2.Longitude * Double.pi / 180.0
        //Law of spherical cosines.
        let Distance: Double = acos(sin(P1Lat) * sin(P2Lat) +
            cos(P1Lat) * cos(P2Lat) * cos(P1Lon - P2Lon))
        return Distance
    }
    
    /// Uses the spherical law of cosines to calculate the distance between two points on a
    /// sphere (presumably a idealized Earth).
    /// - See: [Haversine and Law of Cosines in Excel](https://notunreasonable.com/2011/09/19/latlon-distance-formula-in-excel-haversine-and-spherical-law-of-cosines/)
    /// - Parameter Point1: First point.
    /// - Parameter Point2: Second point.
    /// - Parameter Radius: The radius of the sphere upon which the two points reside, in the
    ///                     units appropriate to the application.
    /// - Returns: Distance between the two points.
    public static func LawOfCosines(Point1: GeoPoint, Point2: GeoPoint, Radius: Double) -> Double
    {
        let Distance = LawOfCosines(Point1: Point1, Point2: Point2)
        return Distance * Radius
    }
    
    /// Uses the spherical law of cosines to calculate the distance between two points on a
    /// sphere (presumably a idealized Earth).
    /// - See: [Haversine and Law of Cosines in Excel](https://notunreasonable.com/2011/09/19/latlon-distance-formula-in-excel-haversine-and-spherical-law-of-cosines/)
    /// - Parameter Point1: First point.
    /// - Parameter Point2: Second point.
    /// - Parameter Radius: The radius of the sphere upon which the two points reside, in the
    ///                     units appropriate to the application.
    /// - Returns: Distance between the two points.
    public static func LawOfCosines(Point1: CGPoint, Point2: CGPoint, Radius: Double) -> Double
    {
        let P1 = GeoPoint(Double(Point1.x), Double(Point1.y))
        let P2 = GeoPoint(Double(Point2.x), Double(Point2.y))
        let Distance = LawOfCosines(Point1: P1, Point2: P2, Radius: Radius)
        return Distance
    }
    
    /// Implementation of the Haversine formula to calculate great circle distances.
    /// https://www.movable-type.co.uk/scripts/latlong.html
    /// https://www.codeguru.com/cpp/cpp/algorithms/article.php/c5115/Geographic-Distance-and-Azimuth-Calculations.htm
    /// - Parameters:
    ///   - Point1: First point on surface of sphere.
    ///   - Point2: Second point on surface of sphere.
    /// - Returns: Distance (in km) between Point1 and Point2. If both points have the same location, 0.0 is returned.
    public static func Haversine(Point1: GeoPoint, Point2: GeoPoint) -> Double
    {
        let EquitorialRadius: Double = 6378.137     //WGS84
        
        if Point1.Latitude == Point2.Latitude && Point1.Longitude == Point2.Longitude
        {
            return 0.0
        }
        let Phi1 = ToRadians(Point1.Latitude)
        let Phi2 = ToRadians(Point2.Latitude)
        let DeltaPhi = ToRadians(Point2.Latitude - Point1.Latitude)
        let DeltaGamma = ToRadians(Point2.Longitude - Point1.Longitude)
        var a = sin(DeltaPhi / 2.0) * sin(DeltaPhi / 2.0)
        a = a + cos(Phi1) * cos(Phi2) * sin(DeltaGamma / 2.0) * sin(DeltaGamma / 2.0)
        let C = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))
        let Distance = EquitorialRadius * C
        return Distance
    }
    
    /// Return the initial bearing from the start point to the end point. Uses forward azimuth to calculate bearing.
    /// https://www.movable-type.co.uk/scripts/latlong.html
    /// https://www.codeguru.com/cpp/cpp/algorithms/article.php/c5115/Geographic-Distance-and-Azimuth-Calculations.htm
    /// - Parameters:
    ///   - Start: Start point.
    ///   - End: End point.
    /// - Returns: Initial bearing from the start point to the end point.
    public static func Bearing(Start: GeoPoint, End: GeoPoint) -> Double
    {
        if Start.Latitude == End.Latitude && Start.Longitude == End.Longitude
        {
            return 0.0
        }
        let Phi1 = ToRadians(Start.Latitude)
        let Phi2 = ToRadians(End.Latitude)
        let Gamma1 = ToRadians(Start.Longitude)
        let Gamma2 = ToRadians(End.Longitude)
        let y = sin(Gamma2 - Gamma1) * cos(Phi2)
        let x = (cos(Phi1) * sin(Phi2)) - cos(Gamma2 - Gamma1)
        var Final = atan2(y,x)
        Final = ToDegrees(Final)
        var IFinal = Int(Final)
        IFinal = (IFinal + 360) % 360
        return Double(IFinal)
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public static func Bearing2I(Start: GeoPoint, End: GeoPoint) -> Int
    {
        let StartLat = ToRadians(Start.Latitude)
        let StartLon = ToRadians(Start.Longitude)
        let EndLat = ToRadians(End.Latitude)
        let EndLon = ToRadians(End.Longitude)
        
        if cos(EndLat) * sin(EndLon - StartLon) == 0
        {
            if EndLat > StartLat
            {
                return 0
            }
            else
            {
                return 180
            }
        }
        var Angle = atan2(cos(EndLat) * sin(EndLon - StartLon),
                          sin(EndLat) * cos(StartLat) - sin(StartLat) * cos(EndLat) * cos(EndLon - StartLon))
        Angle = ToDegrees(Angle)
        var IAngle = Int(Angle)
        IAngle = IAngle + 360
        IAngle = IAngle % 360
        return IAngle
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public static func Bearing2(Start: GeoPoint, End: GeoPoint) -> Double
    {
        let StartLat = ToRadians(Start.Latitude)
        let StartLon = ToRadians(Start.Longitude)
        let EndLat = ToRadians(End.Latitude)
        let EndLon = ToRadians(End.Longitude)
        
        if cos(EndLat) * sin(EndLon - StartLon) == 0
        {
            if EndLat > StartLat
            {
                return 0
            }
            else
            {
                return 180
            }
        }
        var Angle = atan2(cos(EndLat) * sin(EndLon - StartLon),
                          sin(EndLat) * cos(StartLat) - sin(StartLat) * cos(EndLat) * cos(EndLon - StartLon))
        Angle = ToDegrees(Angle)
        Angle = Angle * 1000.0
        let IAngle = Int(Angle)
        Angle = Double(IAngle) / 1000.0
        return Angle
    }
    
    /// Calculate the bearing to the End point using flat map style calculations.
    ///
    /// - Parameters:
    ///   - Start: Start point.
    ///   - End: End point.
    /// - Returns: Bearing to the end point using flat map calculations. (Bearing will not change.)
    public static func Bearing3(Start: GeoPoint, End: GeoPoint) -> Int
    {
        if Start.Latitude == End.Latitude && Start.Longitude == End.Longitude
        {
            return 0
        }
        var Theta: Double = atan2(End.Y, End.X)
        if Theta < 0.0
        {
            Theta = Theta + (Double.pi * 2.0)
        }
        let Degrees = ToDegrees(Theta)
        var IDegrees = Int(Degrees)
        IDegrees = (IDegrees - 90 + 360) % 360
        return IDegrees
    }
    
    /// Return the bearing from Start to End.
    ///
    /// - Parameters:
    ///   - Start: The starting point.
    ///   - End: The ending point.
    ///   - UseGreatCircle: If true, the forward azimuth (eg, Great Circle) algorithm will be used. Otherwise, flat map bearings will be calculated.
    /// - Returns: Bearing from Start to End. If UseGreatCircle is true, the bearing will vary over the course of the arc.
    public static func Bearing(Start: GeoPoint, End: GeoPoint, UseGreatCircle: Bool = true) -> Int
    {
        if UseGreatCircle
        {
            return Bearing2I(Start: Start, End: End)
        }
        else
        {
            return Bearing3(Start: Start, End: End)
        }
    }
    
}
