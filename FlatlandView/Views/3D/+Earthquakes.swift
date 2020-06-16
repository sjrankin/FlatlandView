//
//  +Earthquakes.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    func PlotEarthquakes()
    {
        if let Earth = EarthNode
        {
            PlotEarthquakes(EarthquakeList, On: Earth)
        }
    }
    
    func ClearEarthquakes()
    {
        if let Earth = EarthNode
        {
            for Node in Earth.childNodes
            {
                if Node.name == "EarthquakeNode"
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
            }
        }
    }
    
    func NewEarthquakeList(_ NewList: [Earthquake])
    {
        EarthquakeList.removeAll()
        EarthquakeList = NewList
        PlotEarthquakes()
    }
    
    func PlotEarthquakes(_ List: [Earthquake], On Surface: SCNNode)
    {
        if !Settings.GetBool(.EnableEarthquakes)
        {
            return
        }
        let Oldest = OldestEarthquakeOccurence(List)
        let Biggest = Cities.MostPopulatedCityPopulation(In: CitiesToPlot, UseMetroPopulation: true)
        var MaxSignificance = 0
        for Quake in List
        {
            if Quake.Significance > MaxSignificance
            {
                MaxSignificance = Quake.Significance
            }
        }
        for Quake in List
        {
            let QuakeRadius = 6371.0 - Quake.Depth
            let Percent = QuakeRadius / 6371.0
            let FinalRadius = Double(GlobeRadius.Primary.rawValue) * Percent
            let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: FinalRadius)
            var ERadius = Quake.Magnitude * 0.1
            let QSphere = SCNSphere(radius: CGFloat(ERadius))
            let QNode = SCNNode(geometry: QSphere)
            QNode.name = "EarthquakeNode"
            QNode.categoryBitMask = SunMask | MoonMask
            var BaseColor = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
            switch Settings.GetEnum(ForKey: .ColorDetermination, EnumType: EarthquakeColorMethods.self, Default: .Magnitude)
            {
                case .Age:
                    let QuakeAge = Quake.GetAge()
                    let Percent = CGFloat(QuakeAge / Oldest)
                    let (H, S, B) = BaseColor.HSB
                    BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                
                case .Magnitude:
                    let (H, S, B) = BaseColor.HSB
                    let Percent = CGFloat(Quake.Magnitude) / 10.0
                    BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                
                case .MagnitudeRange:
                    let MagRange = GetMagnitudeRange(For: Quake.Magnitude)
                    BaseColor = MagnitudeColors[MagRange.rawValue]!
                
                case .Population:
                    let ClosestPopulation = PopulationOfClosestCity(To: Quake)
                    if ClosestPopulation == 0 || Biggest == 0
                    {
                        BaseColor = BaseColor.withAlphaComponent(0.5)
                    }
                    else
                    {
                        if Biggest > 0
                        {
                            let Percent = ClosestPopulation / Biggest
                            let (H, S, B) = BaseColor.HSB
                            BaseColor = NSColor(hue: H, saturation: S, brightness: B * CGFloat(Percent), alpha: 0.5)
                        }
                }
                
                case .Significance:
                    let Significance = Quake.Significance
                    if Significance <= 0
                    {
                        let (H, S, B) = BaseColor.HSB
                        let Percent = CGFloat(Quake.Magnitude) / 10.0
                        BaseColor = NSColor(hue: H, saturation: S, brightness: B * Percent, alpha: 0.5)
                    }
                    else
                    {
                        let Percent = Significance / MaxSignificance
                        let (H, S, B) = NSColor.red.HSB
                        BaseColor = NSColor(hue: H, saturation: CGFloat(Percent) * S, brightness: B, alpha: 0.8)
                }
            }
            QNode.geometry?.firstMaterial?.diffuse.contents = BaseColor
            QNode.position = SCNVector3(X, Y, Z)
            Surface.addChildNode(QNode)
        }
    }
    
    func GetMagnitudeRange(For: Double) -> EarthquakeMagnitudes
    {
        let InitialValue = EarthquakeMagnitudes.allCases[0].rawValue
        let Modified = For - InitialValue
        if Modified < 0.0
        {
            return EarthquakeMagnitudes.allCases[0]
        }
        let IModified = Int(Modified)
        if IModified > EarthquakeMagnitudes.allCases.count - 1
        {
            return EarthquakeMagnitudes.allCases.last!
        }
        return EarthquakeMagnitudes.allCases[IModified]
    }
    
    /// Returns the ages in seconds of the oldest earthquake in the list.
    /// - Parameter InList: The list of earthquakes to seach.
    /// - Returns: The age of the oldest earthquake in seconds.
    func OldestEarthquakeOccurence(_ InList: [Earthquake]) -> Double
    {
        let Now = Date()
        var Oldest = Now
        for Quake in InList
        {
            if Quake.Time < Oldest
            {
                Oldest = Quake.Time
            }
        }
        return Now.timeIntervalSinceReferenceDate - Oldest.timeIntervalSinceReferenceDate
    }
    
    /// Returns the population of the closest city to the passed earthquake.
    /// - Parameter To: The earthquake whose closest city's population will be returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is returned.
    /// - Returns: The population of the closest earthquake to the passed city. If no population is
    ///            available (eg, the city does not have a listed population or there are no cities
    ///            being plotted), `0` is returned.
    func PopulationOfClosestCity(To Quake: Earthquake, UseMetroPopulation: Bool = true) -> Int
    {
        var ClosestCity: City? = nil
        var Distance: Double = Double.greatestFiniteMagnitude
        for SomeCity in CitiesToPlot
        {
            let (QX, QY, QZ) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let (CX, CY, CZ) = ToECEF(SomeCity.Latitude, SomeCity.Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
            let PDistance = Utility.Distance3D(X1: QX, Y1: QY, Z1: QZ, X2: CX, Y2: CY, Z2: CZ)
            if PDistance < Distance
            {
                Distance = PDistance
                ClosestCity = SomeCity
            }
        }
        if let CloseCity = ClosestCity
        {
            return CloseCity.GetPopulation(UseMetroPopulation)
        }
        return 0
    }
}
