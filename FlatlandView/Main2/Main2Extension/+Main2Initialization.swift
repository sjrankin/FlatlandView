//
//  +Main2Initialization.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Main2Controller
{
    /// Get initialization data from the run-time environment.
    func InitializationFromEnvironment()
    {
        if let EnableNASATiles = ProcessInfo.processInfo.environment[EnvironmentVars.SatelliteMaps.rawValue]
        {
            let DoEnable = EnableNASATiles.lowercased() == "yes" ? true : false
            Settings.SetBool(.EnableNASATiles, DoEnable)
        }
        else
        {
            Settings.SetBool(.EnableNASATiles, true)
        }
    }
    
    /// Initialize program data.
    func ProgramInitialization()
    {
        #if false
        Stenciler.NotificationSubscriber(ID: UUID())
        {
            Stenciled in
            if let ReturnedStenciledImage = Stenciled
            {
                self.StenciledImage = ReturnedStenciledImage
                if let AboutCtl = self.AControl
                {
                    AboutCtl.ForceMap(self.StenciledImage!)
                }
            }
        }
        #endif
        FileIO.Initialize()
        Main2Controller.InitializeWorldHeritageSites()
        PrimaryMapList = ActualMapIO.LoadMapList()
        FontHelper.Initialize()
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
    }
    
    func LoadInitialMaps()
    {
        let VType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if VType == .Globe3D
        {
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
                    Earth.LoadMap(Maps[0], For: Earlier, Completed: EarthMapReceived)
                    return
                }
            }
        }
        
        if VType != .CubicWorld
        {
            if let InitialImage = MapManager.ImageFor(MapType: MapValue, ViewType: VType)
            {
                //FlatViewMainImage.image = FinalizeImage(InitialImage)
            }
            else
            {
                //Hopefully we will never get here, but in case we do, default to a known good map. If we do
                //get here, set the known map user settings and use it instead of the unknown map we seem to
                //have run into.
                if let StandardMap = MapManager.ImageFor(MapType: .Standard, ViewType: VType)
                {
                    //FlatViewMainImage.image = FinalizeImage(StandardMap)
                    Settings.SetEnum(.Standard, EnumType: MapTypes.self, ForKey: .MapType)
                }
            }
        }
        InitializeUpdateTimer()
        Started = true
        let IsFlat = VType == .FlatNorthCenter || VType == .FlatSouthCenter ? true : false
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
        //let _ = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(QuickTimer), userInfo: nil, repeats: true)
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
            Debug.Print("Calling GetEarthquakes")
            let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
            Earthquakes?.GetEarthquakes(Every: FetchInterval)
        }
        
        if Settings.GetBool(.PreloadNASATiles) && Settings.GetBool(.EnableNASATiles)
        {
            let Earlier = Date().HoursAgo(36)
            let Maps = EarthData.MakeSatelliteMapDefinitions()
            let Earth = EarthData()
            Earth.MainDelegate = self
            Earth.Delegate = self
            Debug.Print("Calling LoadMap")
            Earth.LoadMap(Maps[0], For: Earlier, Completed: EarthMapReceived)
        }
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
                    SunViewBottom.isHidden = true
                    SunViewTop.isHidden = true
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    
                case .FlatNorthCenter:
                    SunViewBottom.isHidden = false
                    SunViewTop.isHidden = true
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)
                    {
                        Main2DView.SetEarthMap(MapImage)
                    }
                    
                case .FlatSouthCenter:
                    SunViewBottom.isHidden = true
                    SunViewTop.isHidden = false
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatSouthCenter)
                    {
                        Main2DView.SetEarthMap(MapImage)
                    }
                    
                default:
                    break
            }
        }
        
        let ViewWindow = view.window?.windowController
        if let MainController = ViewWindow as? Main2Window
        {
            UptimeValue.stringValue = "0"
            switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self)!
            {
                case HourValueTypes.None:
                    (view.window?.windowController as? Main2Window)!.HourSegment.selectedSegment = 0
                    
                case .RelativeToLocation:
                    (view.window?.windowController as? Main2Window)!.HourSegment.selectedSegment = 3
                    
                case .RelativeToNoon:
                    (view.window?.windowController as? Main2Window)!.HourSegment.selectedSegment = 2
                    
                case .Solar:
                    (view.window?.windowController as? Main2Window)!.HourSegment.selectedSegment = 1
            }
            
            switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self)!
            {
                case .FlatNorthCenter:
                    (view.window?.windowController as? Main2Window)!.ViewSegment.selectedSegment = 0
                    
                case .FlatSouthCenter:
                    (view.window?.windowController as? Main2Window)!.ViewSegment.selectedSegment = 1
                    
                case .Globe3D:
                    (view.window?.windowController as? Main2Window)!.ViewSegment.selectedSegment = 2
                    
                case .CubicWorld:
                    (view.window?.windowController as? Main2Window)!.ViewSegment.selectedSegment = 3
            }
            
            let HaveLocalLocation = Settings.HaveLocalLocation()
            (view.window?.windowController as? Main2Window)!.HourSegment.setEnabled(HaveLocalLocation, forSegment: 3)
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
        let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
        UpdateScreenText(With: Opposite)
    }
}
