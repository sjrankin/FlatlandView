//
//  +FlatViewCities.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    /// Plot cities and user-cities.
    func PlotCities()
    {
        PlotCities(FlatConstants.FlatRadius.rawValue)
    }
    
    func PlotWorldHeritageSites()
    {
        
    }
    
    /// Remove cities and user-cities.
    func HideCities()
    {
        RemoveNodeWithName(NodeNames2D.CityNode.rawValue, FromParent: CityPlane)
    }
    
    /// Remove the home node.
    func HideHomeNode()
    {
        RemoveNodeWithName(NodeNames2D.HomeNode.rawValue, FromParent: CityPlane)
    }
    
    /// Remove user POIs.
    func HideUserPOIs()
    {
        RemoveNodeWithName(NodeNames2D.UserPOI.rawValue, FromParent: CityPlane)
    }
    
    /// Add the city layer. This layer is where all city-related objects are placed.
    func AddCityLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        CityPlane = SCNNode(geometry: Flat)
        CityPlane.categoryBitMask = LightMasks3D.Sun.rawValue
        CityPlane.name = NodeNames2D.LocationPlane.rawValue
        CityPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        CityPlane.geometry?.firstMaterial?.isDoubleSided = true
        CityPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        CityPlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        CityPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(CityPlane)
    }
    
    /// Plot cities and user cities.
    /// - Note: All existing nodes are removed prior to plotting new ones.
    /// - Parameter Radius: The radius of the flat view Earth.
    func PlotCities(_ Radius: Double)
    {
        NodesWithShadows.removeAll()
        RemoveNodeWithName(NodeNames2D.CityNode.rawValue, FromParent: CityPlane)
        RemoveNodeWithName(NodeNames2D.HomeNode.rawValue, FromParent: CityPlane)
        RemoveNodeWithName(NodeNames2D.UserPOI.rawValue, FromParent: CityPlane)
        let CityList = Cities()
        CitiesToPlot = CityList.FilteredCities()
        
        if Settings.GetBool(.ShowUserLocations)
        {
            let UserLocations = Settings.GetLocations()
            for (_, Location, Name, Color) in UserLocations
            {
                let UserCity = City(Continent: "NoName", Country: "No Name", Name: Name, Population: nil,
                                    MetroPopulation: nil, Latitude: Location.Latitude, Longitude: Location.Longitude)
                UserCity.CityColor = Color
                UserCity.IsUserCity = true
                CitiesToPlot.append(UserCity)
            }
        }
        
        let UseMetro = Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self, Default: .Metropolitan) == .Metropolitan
        let (Max, Min) = Cities.GetPopulationsIn(CityList: CitiesToPlot,
                                                 UseMetroPopulation: UseMetro)
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        for City in CitiesToPlot
        {
            if City.IsUserCity
            {
                let UserCity = PlotLocationAsCone(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                                  WithColor: City.CityColor)
                UserCity.name = NodeNames2D.UserPOI.rawValue
                CityPlane.addChildNode(UserCity)
                NodesWithShadows.append(UserCity)
            }
            else
            {
                if Settings.GetBool(.ShowCities)
                {
                    var CityColor = Cities.ColorForCity(City)
                    if Settings.GetBool(.ShowCapitalCities) && City.IsCapital
                    {
                        CityColor = Settings.GetColor(.CapitalCityColor, NSColor.systemYellow)
                    }
                    if Settings.GetBool(.ShowCitiesByPopulation)
                    {
                        CityColor = Settings.GetColor(.PopulationColor, NSColor.Sunglow)
                    }
                    var MinSize = FlatConstants.CitySphereRadius.rawValue
                    let Percent = Double(City.GetPopulation()) / Double(Max)
                    MinSize = MinSize + ((MinSize  * FlatConstants.RelativeCitySizeAdjustment.rawValue) * Percent)
                    let CityNode = PlotLocationAsSphere(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                                        WithColor: CityColor, RelativeSize: CGFloat(MinSize))
                    CityPlane.addChildNode(CityNode)
                    NodesWithShadows.append(CityNode)
                }
            }
        }
        
        if Settings.GetBool(.ShowHomeLocation)
        {
            if let HomeLatitude = Settings.GetDoubleNil(.LocalLatitude)
            {
                if let HomeLongitude = Settings.GetDoubleNil(.LocalLongitude)
                {
                    let HomeNode = PlotLocationAsExtrusion(Latitude: HomeLatitude, Longitude: HomeLongitude,
                                                           Radius: Radius,
                                                           Scale: FlatConstants.HomeSizeScale.rawValue,
                                                           WithColor: Settings.GetColor(.HomeColor, NSColor.green))
                    CityPlane.addChildNode(HomeNode)
                    NodesWithShadows.append(HomeNode)
                }
            }
        }
    }
    
    /// Plot a location on the flat Earth as a cone.
    /// - Note: The size of the cone is determined by the values in `FlatConstants`.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Radius: The radius of the flat Earth.
    /// - Parameter WithColor: The color to use as the texture for the cone.
    func PlotLocationAsCone(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor) -> SCNNode
    {
        let CityShape = SCNCone(topRadius: 0.0,
                                bottomRadius: CGFloat(FlatConstants.UserCityBaseSize.rawValue),
                                height: CGFloat(FlatConstants.UserCityHeight.rawValue))
        let CityNode = SCNNode(geometry: CityShape)
        CityNode.name = NodeNames2D.CityNode.rawValue
        CityNode.categoryBitMask = LightMasks2D.Polar.rawValue
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        if Settings.GetBool(.CityNodesGlow)
        {
            CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
        }
        CityNode.castsShadow = true
        
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        CityNode.position = SCNVector3(PointX, PointY, FlatConstants.UserCityHeight.rawValue * 0.5)
        CityNode.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
        
        return CityNode
    }
    
    /// Plot a location on the flat Earth as a sphere half embedded in the surface of the Earth.
    /// - Note: The size of the sphere is determined by the values in `FlatConstants`.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Radius: The radius of the flat Earth.
    /// - Parameter WithColor: The color to use as the texture for the sphere.
    func PlotLocationAsSphere(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor) -> SCNNode
    {
        let CitySize = CGFloat(FlatConstants.CitySphereRadius.rawValue)
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode(geometry: CityShape)
        CityNode.name = NodeNames2D.CityNode.rawValue
        CityNode.categoryBitMask = LightMasks2D.Polar.rawValue// | LightMasks2D.Sun.rawValue
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        if Settings.GetBool(.CityNodesGlow)
        {
            CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
        }
        CityNode.castsShadow = true
        
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        CityNode.position = SCNVector3(PointX, PointY, 0.0)
        
        return CityNode
    }
    
    /// Plot a location on the flat Earth as a sphere half embedded in the surface of the Earth.
    /// - Note: The size of the sphere is determined by the values in `FlatConstants`.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Radius: The radius of the flat Earth.
    /// - Parameter WithColor: The color to use as the texture for the sphere.
    /// - Parameter RelativeSize: The relative size of the city's sphere.
    func PlotLocationAsSphere(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor,
                              RelativeSize: CGFloat) -> SCNNode
    {
        let CitySize = RelativeSize
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode(geometry: CityShape)
        CityNode.name = NodeNames2D.CityNode.rawValue
        CityNode.categoryBitMask = LightMasks2D.Polar.rawValue// | LightMasks2D.Sun.rawValue
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        if Settings.GetBool(.CityNodesGlow)
        {
            CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
        }
        CityNode.castsShadow = true
        
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        CityNode.position = SCNVector3(PointX, PointY, 0.0)
        
        return CityNode
    }
    
    /// Plot a location as an extruded star.
    /// - Note: The size of the star is determined by the values in `FlatConstants`.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Radius: The radius of the flat Earth.
    /// - Parameter Scale: The scale of the shape.
    /// - Parameter WithColor: The color to use as the texture for the star.
    func PlotLocationAsExtrusion(Latitude: Double, Longitude: Double, Radius: Double, Scale: Double,
                                 WithColor: NSColor) -> SCNNode
    {
        let Star = SCNNode(geometry: SCNStar.Geometry(VertexCount: 5, Height: 7.0, Base: 3.5, ZHeight: 4.0))
        Star.scale = SCNVector3(Scale, Scale, Scale)
        Star.castsShadow = true
        Star.name = NodeNames2D.HomeNode.rawValue
        Star.categoryBitMask = LightMasks2D.Polar.rawValue// | LightMasks2D.Sun.rawValue
        Star.geometry?.firstMaterial?.diffuse.contents = WithColor
        if Settings.GetBool(.CityNodesGlow)
        {
            Star.geometry?.firstMaterial?.selfIllumination.contents = WithColor
        }
        let SmallStar = SCNNode(geometry: SCNStar.Geometry(VertexCount: 5, Height: 5.0, Base: 2.5, ZHeight: 5.5))
        SmallStar.castsShadow = true
        SmallStar.name = NodeNames2D.HomeNode.rawValue
        SmallStar.categoryBitMask = LightMasks2D.Polar.rawValue// | LightMasks2D.Sun.rawValue
        let Opposite = WithColor.OppositeColor()
        SmallStar.geometry?.firstMaterial?.diffuse.contents = Opposite
        if Settings.GetBool(.CityNodesGlow)
        {
            SmallStar.geometry?.firstMaterial?.selfIllumination.contents = Opposite
        }
        Star.addChildNode(SmallStar)
        SmallStar.position = SCNVector3(0.0, 0.0, 0.0)
        
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        Star.position = SCNVector3(PointX, PointY, 4.0 * Scale * 0.5)
        
        return Star
    }
}
