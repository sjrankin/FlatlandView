//
//  +MainInitialization.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    /// Get initialization data from the run-time environment.
    func InitializationFromEnvironment()
    {
        #if false
        if let EnableNASATiles = ProcessInfo.processInfo.environment[EnvironmentVars.SatelliteMaps.rawValue]
        {
            let DoEnable = EnableNASATiles.lowercased() == "yes" ? true : false
            Settings.SetBool(.EnableNASATiles, DoEnable)
        }
        else
        {
            Settings.SetBool(.EnableNASATiles, true)
        }
        #endif
    }
    
    /// Initialize program data.
    func ProgramInitialization()
    {
        PrimaryMapList = ActualMapIO.LoadMapList()
        FontHelper.Initialize()
        InitializeCaptiveDialog()
        Main2DView.InitializeLocations()
        Rect2DView.InitializeLocations()
        Main3DView.PlotCities()
    }
    
    /// Initialize the captive dialog UI.
    func InitializeCaptiveDialog()
    {
        CaptiveDialogPanel.wantsLayer = true
        CaptiveDialogPanel.layer?.zPosition = CGFloat(-LayerZLevels.CaptiveDialogLayer.rawValue)
        CaptiveDialogPanel.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        CaptiveDialogPanel.isHidden = true
        CaptiveDialogContainer.wantsLayer = true
        CaptiveDialogContainer.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    /// Load the current view with the initial map.
    /// - Warning: If the initial map cannot be found and the backup-standard map cannot be found, a
    ///            fatal error is thrown.
    func LoadInitialMaps()
    {
        let VType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
       var IsFlat = false
        
        switch VType
        {
            case .Globe3D:
                IsFlat = false
                if let Category = MapManager.CategoryFor(Map: MapValue)
                {
                    if Category == .Satellite && Settings.GetBool(.EnableNASATiles)
                    {
                        //Start loading the map here.
                        let Earlier = Date().HoursAgo(36)
                        let Maps = EarthData.MakeSatelliteMapDefinitions()
                        let Earth = EarthData()
                        Earth.MainDelegate = self
                        Earth.Delegate = self
                        Debug.Print("Calling LoadMap in \(#function)")
                        if let SatMapData = EarthData.MapFromMaps(For: MapValue, From: Maps)
                        {
                            Earth.LoadMap(SatMapData, For: Earlier, Completed: EarthMapReceived)
                        }
                        SetFlatMode(false)
                        return
                    }
                }
                
            case .FlatNorthCenter, .FlatSouthCenter, .Rectangular:
                IsFlat = true
                if let InitialImage = MapManager.ImageFor(MapType: MapValue, ViewType: VType)
                {
                    Main2DView.SetEarthMap(InitialImage)
                }
                else
                {
                    if let StandardMap = MapManager.ImageFor(MapType: .Standard, ViewType: VType)
                    {
                        Main2DView.SetEarthMap(StandardMap)
                        Settings.SetEnum(.Standard, EnumType: MapTypes.self, ForKey: .MapType)
                    }
                    else
                    {
                        Debug.FatalError("Unable to get specified and standard maps for view type \(VType).")
                    }
                }
                
            case .CubicWorld:
                IsFlat = false
                return
        }
        
        InitializeUpdateTimer()
        Started = true
        //let IsFlat = [ViewTypes.FlatNorthCenter, ViewTypes.FlatSouthCenter, ViewTypes.Rectangular].contains(VType)
        SetFlatMode(IsFlat)
    }
    
    /// Initialized Flatland as a whole.
    func InitializeFlatland()
    {
        LoadInitialMaps()
        InitializeUpdateTimer()
    }
    
    /// Start the update timer.
    func InitializeUpdateTimer()
    {
        UpdateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(MainTimerHandler),
                                           userInfo: nil,
                                           repeats: true)
        RunLoop.current.add(UpdateTimer!, forMode: .common)
        MainTimerHandler()
        #if DEBUG
        StartDebugCount = Date.timeIntervalSinceReferenceDate
        let DebugTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DebugTimerHandler), userInfo: nil, repeats: true)
        RunLoop.current.add(DebugTimer, forMode: .common)
        DebugTimerHandler()
        #endif
    }
    
    /// Initialize asynchronous data helpers.
    func AsynchronousInitialization()
    {
        Earthquakes = USGS()
        Earthquakes?.Delegate = self
        if Settings.GetBool(.EnableEarthquakes)
        {
            let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0 * 5.0)
            Earthquakes?.GetEarthquakes(Every: FetchInterval)
            let Cached = Settings.GetCachedEarthquakes()
            PlotCachedQuakes(Cached)
        }
        
        if Settings.GetBool(.PreloadNASATiles) && Settings.GetBool(.EnableNASATiles)
        {
            let Earlier = Date().HoursAgo(36)
            let Maps = EarthData.MakeSatelliteMapDefinitions()
            let Earth = EarthData()
            Earth.MainDelegate = self
            Earth.Delegate = self
            Debug.Print(">>>> **** Calling LoadMap")
            let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
            if let SatMapData = EarthData.MapFromMaps(For: MapValue, From: Maps)
            {
                Earth.LoadMap(SatMapData, For: Earlier, Completed: EarthMapReceived)
            }
        }
    }
    
    /// Plot cached quakes from the last run. This is used to show the user something rather than
    /// nothing when Flatland first starts.
    /// - Parameter Quakes: Set of earthquakes to plot.
    func PlotCachedQuakes(_ Quakes: [Earthquake])
    {
        if Quakes.count < 1
        {
            return
        }
        Main3DView.NewEarthquakeList(Quakes, FromCache: true)
        Main2DView.PlotEarthquakes(Quakes, Replot: true)
        Rect2DView.PlotEarthquakes(Quakes, Replot: true)
    }
    
    /// Initialize the user interface.
    func InterfaceInitialization()
    {
        BackgroundView.wantsLayer = true
        #if true
        BackgroundView.layer?.backgroundColor = NSColor.black.cgColor
        #else
        let Stops = AnimatedGradientLayer.CreateColorStops(Colors: [NSColor.Maroon, NSColor.orange, NSColor.Sunglow],
                                                           Locations: [0.0, 0.5, 1.0])
        let ALayer = AnimatedGradientLayer(LayerSize: BackgroundView.frame.size,
                                           IsHorizontal: false,
                                           Stops: Stops)
        BackgroundView.layer?.addSublayer(ALayer)
        ALayer.StartGradient()
        #endif
        
        Main3DView.wantsLayer = true
        Main3DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        Main3DView.MainDelegate = self
        
        Main2DView.wantsLayer = true
        Main2DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        Main2DView.MainDelegate = self
        
        Rect2DView.wantsLayer = true
        Rect2DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        Rect2DView.MainDelegate = self
        
        let DoubleClickRecognizer = NSClickGestureRecognizer(target: self,
                                                             action: #selector(HandleDoubleClick))
        DoubleClickRecognizer.numberOfClicksRequired = 2
        self.view.addGestureRecognizer(DoubleClickRecognizer)
        
        Settings.QueryEnum(.ViewType, EnumType: ViewTypes.self)
        {
            Value in
            switch Value
            {
                case .Globe3D, .CubicWorld:
                    Main2DView.SunVisibility(IsShowing: false)
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    Main3DView.play(self)
                    Main2DView.pause(self)
                    Rect2DView.pause(self)
                    
                case .FlatNorthCenter, .FlatSouthCenter:
                    Main2DView.SunVisibility(IsShowing: true)
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)
                    {
                        Main2DView.SetEarthMap(MapImage)
                    }
                    Main3DView.pause(self)
                    Main2DView.play(self)
                    Rect2DView.pause(self)
                    
                case .Rectangular:
                    //Rect2DView.SunVisibility(IsShowing: true)
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .Rectangular)
                    {
                        Rect2DView.SetEarthMap(MapImage)
                    }
                    Main3DView.pause(self)
                    Main2DView.pause(self)
                    Rect2DView.play(self)
                    
                default:
                    break
            }
        }
        
        let ViewWindow = view.window?.windowController
        if let MainController = ViewWindow as? MainWindow
        {
            #if DEBUG
            UptimeValue.stringValue = ""
            #endif
            #if false
            switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .Solar)
            {
                case .None:
                    (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 0
                    
                case .RelativeToLocation:
                    (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 3
                    
                case .RelativeToNoon:
                    (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 2
                    
                case .Solar:
                    (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 1
            }
            
            switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
            {
                case .FlatNorthCenter:
                    (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 0
                    
                case .FlatSouthCenter:
                    (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 1
                    
                case .Globe3D:
                    (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 2
                    
                case .CubicWorld:
                    (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 4
                    
                case .Rectangular:
                    (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 3
            }
            
            let HaveLocalLocation = Settings.HaveLocalLocation()
            (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(HaveLocalLocation, forSegment: 3)
            #endif
        }
        
        MainTimeLabelBottom.wantsLayer = true
        MainTimeLabelBottom.layer?.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelBottom.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        MainTimeLabelTop.wantsLayer = true
        MainTimeLabelTop.layer?.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelTop.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        
        PrimaryView.wantsLayer = true
        let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
        PrimaryView.layer?.backgroundColor = NewBackgroundColor.cgColor
        BackgroundView.wantsLayer = true
        BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
        let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
        UpdateScreenText(With: Opposite)
    }
}
