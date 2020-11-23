//
//  MapSceneProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

protocol MapSceneProtocol: class
{
    /// Hides the scene.
    /// - Parameter Duration: Number of seconds to hide the scene.
    func Hide(_ Duration: Double)
    
    /// Shows the scene.
    /// - Parameter Duration: Number of seconds to show the scene.
    func Show(_ Duration: Double)
    
    /// Sets the map time (for orientation).
    /// - Parameter Percent: Percent of the day past for UTC.
    func SetMapTime(_ Percent: Double)
    
    /// Sets the map image.
    /// - Parameter Image: The new map image.
    func SetMapImage(_ Image: NSImage)
    
    /// Plot an object on the map.
    /// - Parameter Object: The shape to plot.
    /// - Parameter Latitude: The latitude of where to plot the shape.
    /// - Parameter Longitude: The longitude of where to plot the shape.
    func PlotObject(_ Object: SCNNode2, Latitude: Double, Longitude: Double)
    
    /// Plot an object on the map.
    /// - Parameter Object: The shape to plot.
    /// - Parameter X: The horizontal location on the map where to plot the shape.
    /// - Parameter Y: The vertical location on the map where to plot the shape.
    func PlotObject(_ Object: SCNNode2, X: Double, Y: Double)
    
    /// Removes the object with the specified ID.
    /// - Parameter ID: The object to remove.
    func RemoveObject(ID: UUID)
    
    /// Removes all objects of the specified class.
    /// - Parameter ID: The ID of the class of objects to remove.
    func RemoveObjectClass(ID: UUID)
    
    /// Returns all objects plotted via the `PlotObject` functions.
    /// - Returns: Array of all shapes plotted. Deleting objects in this array
    ///            has no effect on what is plotted.
    func PlottedObjects() -> [SCNNode2]
}
