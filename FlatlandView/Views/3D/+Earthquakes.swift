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
        for Quake in List
        {
            let QuakeRadius = 6371.0 - Quake.Depth
            let Percent = QuakeRadius / 6371.0
            let FinalRadius = Double(GlobeRadius.Primary.rawValue) * Percent
            let (X, Y, Z) = ToECEF(Quake.Latitude, Quake.Longitude, Radius: FinalRadius)
            //print("Mag: \(Quake.Magnitude), \(Quake.Latitude),\(Quake.Longitude)")
            var ERadius = Quake.Magnitude * 0.1
            let QSphere = SCNSphere(radius: CGFloat(ERadius))
            let QNode = SCNNode(geometry: QSphere)
            QNode.categoryBitMask = SunMask | MoonMask
            QNode.geometry?.firstMaterial?.diffuse.contents = NSColor.red.withAlphaComponent(0.5)
            QNode.position = SCNVector3(X, Y, Z)
            Surface.addChildNode(QNode)
        }
    }
}
