//
//  +2DCities.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainView
{
    /// Plot the cities in the passed list on to the 2D map.
    /// - Parameter InCityList: The list of cities to plot.
    /// - Parameter RadialTime: The current time (in UTC) expressed as radians.
    /// - Parameter CityListChanged: Notifies this function that the list of cities changed since
    ///                              the previous call.
    func PlotCities(InCityList: [City], RadialTime: Double, CityListChanged: Bool = false)
    {
        CityLayer?.removeFromSuperlayer()
        CityLayer = nil
        CityView2D.layer?.zPosition = CGFloat(LayerZLevels.CityLayer.rawValue)
        if CityLayer == nil
        {
            CityLayer = CAShapeLayer()
            CityLayer?.backgroundColor = NSColor.clear.cgColor
            CityLayer?.zPosition = CGFloat(LayerZLevels.CityLayer.rawValue)
            CityLayer?.name = "City Layer"
            CityLayer?.bounds = FlatViewMainImage.bounds
            CityLayer?.frame = FlatViewMainImage.bounds
            CityView2D.layer!.addSublayer(CityLayer!)
        }
        let Bezier = NSBezierPath()
        for SomeCity in InCityList
        {
            let CityPath = PlotCity(SomeCity, Diameter: (CityLayer?.bounds.width)!)
            Bezier.append(CityPath)
        }
        if Settings.GetBool(.ShowUserLocations)
        {
            if CityLayer?.sublayers != nil
            {
                for SomeLayer in CityLayer!.sublayers!
                {
                    if SomeLayer.name == "User Location"
                    {
                        SomeLayer.removeFromSuperlayer()
                    }
                }
            }
            let UserLocations = Settings.GetLocations()
            for (_, Location, Name, Color) in UserLocations
            {
                let LocationLayer = PlotLocation(Location, Name, Color, (CityLayer?.bounds.width)!)
                LocationLayer.name = "User Location"
                CityLayer?.addSublayer(LocationLayer)
            }
        }
        CityLayer?.fillColor = NSColor.red.cgColor
        CityLayer?.strokeColor = NSColor.black.cgColor
        CityLayer?.lineWidth = 1.0
        let FinalPath = Bezier.cgPath
        CityLayer?.path = FinalPath
        let Rotation = CATransform3DMakeRotation(CGFloat(-RadialTime), 0.0, 0.0, 1.0)
        CityLayer?.transform = Rotation
    }
    
    /// Draw the specified city on a 2D map.
    /// - Parameter PlotMe: The city to plot.
    /// - Parameter Diameter: The diamter of the map.
    /// - Returns: An `NSBezierPath` with size and location ready for plotting on the main layer.
    func PlotCity(_ PlotMe: City, Diameter: CGFloat) -> NSBezierPath
    {
        let Latitude = PlotMe.Latitude
        let Longitude = PlotMe.Longitude
        let Half = Double(Diameter / 2.0)
        let Ratio: Double = Half / HalfCircumference
        let CitySize: CGFloat = 10.0
        let CityDotSize = CGSize(width: CitySize, height: CitySize)
        let PointModifier = Double(CGFloat(Half) - (CitySize / 2.0))
        let BearingOffset = 180.0
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = DistanceFromContextPole(To: GeoPoint2(Latitude, Longitude))
        Distance = Distance * Ratio
        var CityBearing = Bearing(Start: GeoPoint2(90.0, 0.0), End: GeoPoint2(Latitude, Longitude * LongitudeAdjustment))
        CityBearing = (CityBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(CityBearing) + PointModifier
        let PointY = Distance * sin(CityBearing) + PointModifier
        let Origin = CGPoint(x: PointX, y: PointY)
        let City = NSBezierPath(ovalIn: CGRect(origin: Origin, size: CityDotSize))
        return City
    }
    
    /// Plot a point on the 2D map based on the passed point.
    /// - Parameter Location: The location where to plot.
    /// - Parameter Name: The name of the location.
    /// - Parameter Color: The color of the plotted point.
    /// - Parameter Diameter: The diameter of the 2D map.
    /// - Returns: A `CAShapeLayer` with the location plotted.
    func PlotLocation(_ Location: GeoPoint2, _ Name: String, _ Color: NSColor, _ Diameter: CGFloat) -> CAShapeLayer
    {
        let Latitude = Location.Latitude
        let Longitude = Location.Longitude
        let Half = Double(Diameter / 2.0)
        let Ratio: Double = Half / HalfCircumference
        let LocationSize: CGFloat = 10.0
        let LocationDotSize = CGSize(width: LocationSize, height: LocationSize)
        let PointModifier = Double(CGFloat(Half) - (LocationSize / 2.0))
        let BearingOffset = 180.0
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = DistanceFromContextPole(To: GeoPoint2(Latitude, Longitude))
        Distance = Distance * Ratio
        var LocationBearing = Bearing(Start: GeoPoint2(90.0, 0.0), End: GeoPoint2(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing) + PointModifier
        let PointY = Distance * sin(LocationBearing) + PointModifier
        let Origin = CGPoint(x: PointX, y: PointY)
        let Location = NSBezierPath(rect: CGRect(origin: Origin, size: LocationDotSize))
        let Layer = CAShapeLayer()
        Layer.frame = FlatViewMainImage.bounds
        Layer.bounds = FlatViewMainImage.bounds
        Layer.backgroundColor = NSColor.clear.cgColor
        Layer.fillColor = Color.cgColor
        Layer.strokeColor = NSColor.black.cgColor
        Layer.lineWidth = 1.0
        Layer.path = Location.cgPath
        return Layer
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public func Bearing(Start: GeoPoint2, End: GeoPoint2) -> Double
    {
        let StartLat = Start.Latitude.ToRadians()
        let StartLon = Start.Longitude.ToRadians()
        let EndLat = End.Latitude.ToRadians()
        let EndLon = End.Longitude.ToRadians()
        
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
        Angle = Angle.ToDegrees()
        Angle = Angle * 1000.0
        let IAngle = Int(Angle)
        Angle = Double(IAngle) / 1000.0
        return Angle
    }
    
    /// Implementation of the Spherical Law of Cosines. Used to calculate a distance between two
    /// points on a sphere, in our case, the surface of the Earth.
    /// - Parameter Point1: First location.
    /// - Parameter Point2: Second location.
    /// - Returns: Distance from `Point1` to `Point2` in kilometers.
    func LawOfCosines(Point1: GeoPoint2, Point2: GeoPoint2) -> Double
    {
        let Term1 = sin(Point1.Latitude.ToRadians()) * sin(Point2.Latitude.ToRadians())
        let Term2 = cos(Point1.Latitude.ToRadians()) * cos(Point2.Latitude.ToRadians())
        let Term3 = cos(Point2.Longitude.ToRadians() - Point1.Longitude.ToRadians())
        var V = acos(Term1 + (Term2 * Term3))
        V = V * 6367.4447
        return V
    }
    
    /// Returns the distance from the passed location to the North Pole.
    /// - Returns: Distance (in kilometers) from `To` to the North Pole.
    func DistanceFromNorthPole(To: GeoPoint2) -> Double
    {
        return LawOfCosines(Point1: GeoPoint2(90.0, 0.0), Point2: To)
    }
    
    /// Returns the distance from the passed location to the South Pole.
    /// - Returns: Distance (in kilometers) from `To` to the South Pole.
    func DistanceFromSouthPole(To: GeoPoint2) -> Double
    {
        return LawOfCosines(Point1: GeoPoint2(-90.0, 0.0), Point2: To)
    }
    
    /// Returns the distance from the passed location to the pole that is at the center of the image.
    /// - Parameter To: The point whose distance to the pole at the center of the image is returned.
    /// - Returns: The distance (in kilometers) from `To` to the pole at the center of the image.
    func DistanceFromContextPole(To: GeoPoint2) -> Double
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
        {
            return DistanceFromNorthPole(To: To)
        }
        else
        {
            return DistanceFromSouthPole(To: To)
        }
    }
    
    /// Converts polar coordintes into Cartesian coordinates, optionally adding an offset value.
    /// - Parameter Theta: The angle of the polar coordinate.
    /// - Parameter Radius: The radial value of the polar coordinate.
    /// - Parameter HOffset: Value added to the returned `x` value. Defaults to 0.0.
    /// - Parameter VOffset: Value added to the returned `y` value. Defaults to 0.0.
    /// - Returns: `CGPoint` with the converted polar coorindate.
    func PolarToCartesian(Theta: Double, Radius: Double, HOffset: Double = 0.0, VOffset: Double = 0.0) -> CGPoint
    {
        let Radial = Theta * Double.pi / 180.0
        let X = Radius * cos(Radial) + HOffset
        let Y = Radius * sin(Radial) + VOffset
        return CGPoint(x: X, y: Y)
    }
    
    /// Hide cities.
    func HideCities()
    {
        if CityLayer != nil
        {
            CityLayer?.removeFromSuperlayer()
            CityLayer = nil
        }
    }
}
