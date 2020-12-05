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
        CitiesToPlot = CityManager.FilteredCities()
        
        if Settings.GetBool(.ShowUserLocations)
        {
            let POIList = POIManager.GetPOIs(By: .UserPOI)
            for SomePOI in POIList
            {
                if SomePOI.POIType == POITypes.UserPOI.rawValue
                {
                    NodeTables.AddUserPOI(ID: SomePOI.POIID, Name: SomePOI.Name, Location: GeoPoint(SomePOI.Latitude, SomePOI.Longitude))
                    let ToPlot = City2()
                    ToPlot.Name = SomePOI.Name
                    ToPlot.CityID = SomePOI.POIID
                    ToPlot.Latitude = SomePOI.Latitude
                    ToPlot.Longitude = SomePOI.Longitude
                    ToPlot.CityColor = SomePOI.POIColor
                    ToPlot.IsUserCity = true
                    let UserCity = PlotLocationAsCone(Latitude: ToPlot.Latitude, Longitude: ToPlot.Longitude, Radius: Radius,
                                                      WithColor: ToPlot.CityColor)
                    UserCity.name = NodeNames2D.UserPOI.rawValue
                    UserCity.NodeID = SomePOI.POIID
                    UserCity.NodeClass = UUID(uuidString: NodeClasses.UserPOI.rawValue)!
                    CityPlane.addChildNode(UserCity)
                    NodesWithShadows.append(UserCity)
                }
            }
        }
        
        let UseMetro = Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self, Default: .Metropolitan) == .Metropolitan
        let (Max, Min) = CityManager.GetPopulationsIn(CityList: CitiesToPlot, UseMetroPopulation: UseMetro)
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        for City in CitiesToPlot
        {
            if Settings.GetBool(.ShowCities)
            {
                var CityColor = CityManager.ColorForCity(City)
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
                CityNode.NodeID = City.CityID
                CityNode.NodeClass = UUID(uuidString: NodeClasses.City.rawValue)!
                CityPlane.addChildNode(CityNode)
                NodesWithShadows.append(CityNode)
            }
        }
        
        if Settings.GetBool(.ShowHomeLocation)
        {
            NodeTables.RemoveUserHome()
            let Homes = POIManager.GetPOIs(By: .Home)
            for Home in Homes
            {
                NodeTables.AddHome(ID: Home.POIID, Name: "Home location", Location: GeoPoint(Home.Latitude, Home.Longitude))
                let HomeNode = PlotLocationAsExtrusion(Latitude: Home.Latitude, Longitude: Home.Longitude,
                                                       Radius: Radius, Scale: FlatConstants.HomeSizeScale.rawValue,
                                                       WithColor: Settings.GetColor(.HomeColor, NSColor.green))
                HomeNode.NodeID = Home.POIID
                HomeNode.NodeClass = UUID(uuidString: NodeClasses.HomeLocation.rawValue)!
                CityPlane.addChildNode(HomeNode)
                NodesWithShadows.append(HomeNode)
            }
        }
    }
    
    /// Plot a location on the flat Earth as a cone.
    /// - Note: The size of the cone is determined by the values in `FlatConstants`.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Radius: The radius of the flat Earth.
    /// - Parameter WithColor: The color to use as the texture for the cone.
    func PlotLocationAsCone(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor) -> SCNNode2
    {
        let CityShape = SCNCone(topRadius: 0.0,
                                bottomRadius: CGFloat(FlatConstants.UserCityBaseSize.rawValue),
                                height: CGFloat(FlatConstants.UserCityHeight.rawValue))
        let CityNode = SCNNode2(geometry: CityShape)
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
        var Distance = Geometry.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Geometry.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
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
    func PlotLocationAsSphere(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor) -> SCNNode2
    {
        let CitySize = CGFloat(FlatConstants.CitySphereRadius.rawValue)
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode2(geometry: CityShape)
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
        var Distance = Geometry.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Geometry.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
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
                              RelativeSize: CGFloat) -> SCNNode2
    {
        let CitySize = RelativeSize
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode2(geometry: CityShape)
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
        var Distance = Geometry.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Geometry.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
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
                                 WithColor: NSColor) -> SCNNode2
    {
        let Star = SCNNode2(geometry: SCNStar.Geometry(VertexCount: Int(FlatConstants.HomeStarVertexCount.rawValue),
                                                       Height: FlatConstants.HomeStarHeight.rawValue,
                                                       Base: FlatConstants.HomeStarBase.rawValue,
                                                       ZHeight: FlatConstants.HomeStarZ.rawValue))
        Star.castsShadow = true
        Star.name = NodeNames2D.HomeNode.rawValue
        Star.categoryBitMask = LightMasks2D.Polar.rawValue
        Star.geometry?.firstMaterial?.diffuse.contents = WithColor
        if Settings.GetBool(.CityNodesGlow)
        {
            Star.geometry?.firstMaterial?.emission.contents = WithColor
        }
        
        let SmallStar = SCNNode2(geometry: SCNStar.Geometry(VertexCount: Int(FlatConstants.HomeStarVertexCount.rawValue),
                                                            Height: FlatConstants.SmallStarHeight.rawValue,
                                                            Base: FlatConstants.SmallStarBase.rawValue,
                                                            ZHeight: FlatConstants.SmallStarZ.rawValue))
        SmallStar.castsShadow = true
        SmallStar.name = NodeNames2D.HomeNode.rawValue
        SmallStar.categoryBitMask = LightMasks2D.Polar.rawValue
        let Opposite = WithColor.OppositeColor()
        SmallStar.geometry?.firstMaterial?.diffuse.contents = Opposite
        if Settings.GetBool(.CityNodesGlow)
        {
            SmallStar.geometry?.firstMaterial?.emission.contents = Opposite
        }
        Star.addChildNode(SmallStar)
        SmallStar.position = SCNVector3(0.0, 0.0, 0.0)
        
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Geometry.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Geometry.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        Star.position = SCNVector3(PointX, PointY, FlatConstants.HomeStarOverallZ.rawValue)
        
        return Star
    }
}
