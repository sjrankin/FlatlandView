//
//  +Stenciling.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    // MARK: - Surface stenciling
    
    /// Apply stencils to `GlobalBaseMap` as needed. When the stenciled map is ready,
    /// `GotStenciledMap` is called.
    /// - Notes:
    ///    - Control returns almost immediately.
    ///    - The user can change settings such that no stenciling is applied. In that case,
    ///      the non-stenciled map will be available very quickly.
    /// - Parameter Caller: Name of the caller.
    /// - Parameter Final: Called after the stencil has been applied.
    func ApplyStencils(Caller: String? = nil, Final: (() -> ())? = nil)
    {
        #if DEBUG
        if let CallerName = Caller
        {
            Debug.Print("ApplyStencils called by \(CallerName)")
        }
        #endif
        if let Map = GlobalBaseMap
        {
            #if true
            var Quakes: [Earthquake]? = nil
            var Stages = [StencilStages]()
            if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            {
                Stages.append(.Earthquakes)
                Quakes = EarthquakeList
            }
            if Settings.GetBool(.ShowWorldHeritageSites) && Settings.GetBool(.PlotSitesAs2D)
            {
                Stages.append(.UNESCOSites)
            }
            if Settings.GetBool(.ShowEarthquakeRegions)
            {
                Stages.append(.EarthquakeRegions)
            }
            if Settings.GetBool(.CityNamesDrawnOnMap)
            {
                Stages.append(.CityNames)
            }
            if Settings.GetBool(.GridLinesDrawnOnMap)
            {
                Stages.append(.GridLines)
            }
            print("Stencil with \(Stages)")
            Stenciler.RunStencilPipeline(To: Map, Quakes: Quakes, Stages: Stages, Caller: self)
            #else
            let ShowEarthquakes = Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            var Quakes: [Earthquake]? = nil
            if ShowEarthquakes
            {
                if Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No) == .Stenciled
                {
                    Quakes = EarthquakeList
                }
            }
            let ShowUNESCO = Settings.GetBool(.ShowWorldHeritageSites) && Settings.GetBool(.PlotSitesAs2D)
            Stenciler.AddStencils(To: Map,
                                  Quakes: Quakes,
                                  ShowRegions: Settings.GetBool(.ShowEarthquakeRegions),
                                  PlotCities: Settings.GetBool(.CityNamesDrawnOnMap),
                                  GridLines: Settings.GetBool(.GridLinesDrawnOnMap),
                                  UNESCOSites: ShowUNESCO,
                                  CalledBy: Caller,
                                  FinalNotify: Final,
                                  Completed: GotStenciledMap)
            #endif
        }
    }
    
    /// Closure for receiving a stenciled map.
    /// - Parameter Image: The (potentially) stenciled map. Depending on user settings, it is very
    ///                    possible no stenciling will be done and the map will be made available
    ///                    very quickly.
    /// - Parameter Duration: The duration, in seconds, of the stenciling process. If no steciling
    ///                       was applied, this value will be 0.0.
    /// - Parameter CalledBy: The name of the caller. May be nil.
    func GotStenciledMap(_ Image: NSImage, _ Duration: Double, _ CalledBy: String?,
                         Notify: (() -> ())? = nil)
    {
        #if DEBUG
        let StackFrames = Debug.StackFrameContents(10)
        Debug.Print(Debug.PrettyStackTrace(StackFrames))
        if let Caller = CalledBy
        {
            Debug.Print("Stencil available: called by \(Caller), duration: \(Duration.RoundedTo(2))")
        }
        else
        {
            Debug.Print("Stenciling duration: \(Duration)")
        }
        #endif
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = Image
        Debug.Print("Applied stenciled map.")
        Notify?()
    }
}
