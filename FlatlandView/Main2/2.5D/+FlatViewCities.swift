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
    func PlotCities()
    {
        PlotCities(FlatConstants.FlatRadius.rawValue)
    }
    
    func HideCities()
    {
        RemoveNodeWithName(NodeNames2D.LocationNode.rawValue, FromParent: CityPlane)
    }
    
    func AddCityLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        CityPlane = SCNNode(geometry: Flat)
        CityPlane.categoryBitMask = LightMasks.Sun.rawValue
        CityPlane.name = NodeNames2D.LocationPlane.rawValue
        CityPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        CityPlane.geometry?.firstMaterial?.isDoubleSided = true
        CityPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        CityPlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        CityPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(CityPlane)
    }
    
    func PlotCities(_ Radius: Double)
    {
        RemoveNodeWithName(NodeNames2D.LocationNode.rawValue, FromParent: CityPlane)
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
        
        for City in CitiesToPlot
        {
            if City.IsUserCity
            {
                let ShowEmission = Settings.GetBool(.ShowPOIEmission)
                PlotLocationAsCone(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                   WithColor: City.CityColor, EnableEmission: ShowEmission)
            }
            else
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
                PlotLocationAsSphere(Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                     WithColor: CityColor, EnableEmission: false)
            }
        }
    }
    
    func PlotLocationAsCone(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor,
                            EnableEmission: Bool)
    {
        
    }
    
    func PlotLocationAsSphere(Latitude: Double, Longitude: Double, Radius: Double, WithColor: NSColor,
                              EnableEmission: Bool)
    {
        var CitySize: CGFloat = 0.15
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode(geometry: CityShape)
        CityNode.name = NodeNames2D.LocationNode.rawValue
        CityNode.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        if Settings.GetBool(.CityNodesGlow)
        {
            CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
        }
        CityNode.castsShadow = true
        
        let BearingOffset = 180.0
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
        
        CityPlane.addChildNode(CityNode)
    }
}
