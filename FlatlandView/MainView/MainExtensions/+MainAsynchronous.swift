//
//  +MainAsynchronous.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController: AsynchronousDataProtocol
{
    // MARK: - Asynchronous data protocol functions
    
    /// Asynchornous data has become available.
    /// - Parameter CategoryType: The type of asynchronous data.
    /// - Parameter Actual: The asynchronous data.
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?)
    {
        switch CategoryType
        {
            case .Earthquakes:
                if let NewEarthquakes = Actual as? [Earthquake]
                {
                    HideStatusText(ForID: EQMessageID, ClearQueue: false)
                    Main3DView.NewEarthquakeList(NewEarthquakes, Final: DoneWithStenciling)
                    Main2DView.PlotEarthquakes(NewEarthquakes, Replot: true)
                    Rect2DView.PlotEarthquakes(NewEarthquakes, Replot: true)
                    LatestEarthquakes = NewEarthquakes
                }
                
            default:
                break
        }
    }
    
    /// Called when a new NASA map has been received and fully assembled.
    /// - Parameter Image: The NASA satellite image map.
    /// - Parameter Duration: The number of seconds from when images started to be received to the
    ///                       completion of the map.
    /// - Parameter ImageDate: The date of the map.
    /// - Parameter Successful: If true, the map was downloaded successfully. If false, the map was not
    ///                         downloaded successfully and all other parameters are undefined.
    func EarthMapReceived(Image: NSImage, Duration: Double, ImageDate: Date, Successful: Bool)
    {
        if !Successful
        {
            #if DEBUG
            Debug.Print("Unable to download earth map from NASA.")
            #endif
            return
        }
        Debug.Print("Received earth map from NASA")
        Debug.Print("Map generation duration \(Duration), Date: \(ImageDate)")
        let Maps = EarthData.MakeSatelliteMapDefinitions()
        Maps[0].CachedMap = Image
        Main3DView.ChangeEarthBaseMap(To: Image)
    }
}
