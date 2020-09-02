//
//  ViewController.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 5/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import AppKit
import Foundation
import SceneKit
import CoreGraphics
import CoreImage

class MainView: NSViewController, MainProtocol, AsynchronousDataProtocol
{
    /// Start initialization of the UI.
    /// - Note: See [Environment Variables in Xcode](https://medium.com/flawless-app-stories/environment-variables-in-xcode-a78e07d223ed)
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let EnableNASATiles = ProcessInfo.processInfo.environment[EnvironmentVars.SatelliteMaps.rawValue]
        {
            let DoEnable = EnableNASATiles.lowercased() == "yes" ? true : false
            Settings.SetBool(.EnableNASATiles, DoEnable)
        }
        else
        {
            Settings.SetBool(.EnableNASATiles, true)
        }
        
        StartupTask.insert(.Initialize)
        StartupTask.insert(.UIInitialize)
        StartupTask.insert(.LoadNASATiles)
        StartupTask.insert(.LoadUSGSQuakes)
        Settings.Initialize()
        Settings.AddSubscriber(self)
        
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
        
        Earthquakes = USGS()
        Earthquakes?.Delegate = self
        if Settings.GetBool(.EnableEarthquakes)
        {
            Debug.Print("Calling GetEarthquakes")
            let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
            Earthquakes?.GetEarthquakes(Every: FetchInterval)
        }
        
        FileIO.Initialize()
        PrimaryMapList = ActualMapIO.LoadMapList()
        
        FontHelper.Initialize()
        
        BackgroundView.wantsLayer = true
        let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
        BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
        let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
        UpdateScreenText(With: Opposite)
        
        World3DView.wantsLayer = true
        World3DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        World3DView.MainDelegate = self
        
        InitializeFlatland()
        
        InitializeStatusView()
        if Settings.GetBool(.ShowSplashScreen)
        {
            var StatusMessage = "Flatland initializing - please wait."
            StatusMessage.append("\n")
            StatusMessage.append("\(Versioning.VerySimpleVersionString()), Build \(Versioning.Build), \(Versioning.BuildDate)")
            #if true
            let ShowDuration = Settings.GetDouble(.SplashScreenDuration, 5.0)
            DisplayStatusText(StatusMessage, Hide: ShowDuration, ShowIfNotVisible: true)
            #else
            DisplayStatusText(StatusMessage, ShowIfNotVisible: true)
            #endif
        }
        else
        {
            HideStatus()
        }
        
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        
        let DoubleClickRecognizer = NSClickGestureRecognizer(target: self,
                                                             action: #selector(HandleDoubleClick))
        DoubleClickRecognizer.numberOfClicksRequired = 2
        self.view.addGestureRecognizer(DoubleClickRecognizer)
        
        #if DEBUG
        VersionValue.stringValue = Versioning.VerySimpleVersionString()
        BuildValue.stringValue = "\(Versioning.Build)"
        BuildDateValue.stringValue = Versioning.BuildDate
        #else
        DebugTextGrid.removeFromSuperview()
        #endif
        
        Debug.Print("Done with viewDidLoad")
    }
    
    func DoneWithStenciling()
    {
        HideStatus()
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
        //let Brightened = Image.SetImageBrightness(To: 0.1)
        Debug.Print("Map generation duration \(Duration), Date: \(ImageDate)")
        //        World3DView.AddEarth(WithMap: Brightened)
        let Maps = EarthData.MakeSatelliteMapDefinitions()
        Maps[0].CachedMap = Image
        World3DView.ChangeEarthBaseMap(To: Image)
        //        World3DView.AddEarth(WithMap: Image)
    }
    
    var Earthquakes: USGS? = nil
    
    var PrimaryMapList: ActualMapList? = nil
    
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
    
    var UpdateTimer: Timer? = nil
    var Started = false
    
    @objc func QuickTimer()
    {
        RotateImageTo(TestPercent)
        TestPercent = TestPercent + 0.01
        if TestPercent > 1.0
        {
            TestPercent = 0.0
        }
    }
    
    var TestPercent: Double = 0.0
    
    #if DEBUG
    @objc func DebugTimerHandler()
    {
        if Date.timeIntervalSinceReferenceDate - StartDebugCount >= 1.0
        {
            StartDebugCount = Date.timeIntervalSinceReferenceDate
            UptimeSeconds = UptimeSeconds + 1
            (view.window?.windowController as? MainWindow)!.UpTimeLabel.stringValue = "\(UptimeSeconds)"
        }
    }
    
    var StartDebugCount: Double = 0.0
    var UptimeSeconds: Int = 0
    #endif
    
    @objc func MainTimerHandler()
    {
        UpdateSunLocations()
        let CurrentMapType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        switch CurrentMapType
        {
            case .Globe3D, .CubicWorld:
                SunViewBottom.isHidden = false
                SunViewTop.isHidden = false
                MainTimeLabelTop.isHidden = false
                MainTimeLabelBottom.isHidden = true
                
            case .FlatNorthCenter:
                SunViewBottom.isHidden = false
                SunViewTop.isHidden = true
                MainTimeLabelTop.isHidden = false
                MainTimeLabelBottom.isHidden = true
                
            case .FlatSouthCenter:
                SunViewBottom.isHidden = true
                SunViewTop.isHidden = false
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = false
        }
        
        let LabelType = Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .None)
        let Now = GetUTC()
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        var TimeZoneAbbreviation = ""
        if LabelType == .UTC
        {
            TimeZoneAbbreviation = "UTC"
        }
        else
        {
            TimeZoneAbbreviation = GetLocalTimeZoneID() ?? "UTC"
        }
        let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
        Formatter.timeZone = TZ
        var Final = Formatter.string(from: Now)
        if !Settings.GetBool(.TimeLabelSeconds)
        {
            let Parts = Final.split(separator: ":")
            Final = "\(Parts[0]):\(Parts[1])"
        }
        let FinalText = Final + " " + TimeZoneAbbreviation
        if LabelType == .None
        {
            MainTimeLabelTop.stringValue = ""
            MainTimeLabelBottom.stringValue = ""
        }
        else
        {
            MainTimeLabelTop.stringValue = FinalText
            MainTimeLabelBottom.stringValue = FinalText
        }
        
        let CurrentSeconds = Now.timeIntervalSince1970
        var ElapsedSeconds = 0
        if CurrentSeconds != OldSeconds
        {
            OldSeconds = CurrentSeconds
            var Cal = Calendar(identifier: .gregorian)
            //Use UTC time zone for rotational calculations, not the local time zone (if the user
            //is using the local zone). All calculations are based on UTC and so if local time zones
            //are used, the map wil be rotated incorrectly.
            Cal.timeZone = TimeZone(abbreviation: "UTC")!
            let Hour = Cal.component(.hour, from: Now)
            let Minute = Cal.component(.minute, from: Now)
            let Second = Cal.component(.second, from: Now)
            ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
            let Percent = Double(ElapsedSeconds) / Double(24 * 60 * 60)
            let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
            RotateImageTo(PrettyPercent)
        }
    }
    
    var OldSeconds: Double = 0.0
    
    func GetUTC() -> Date
    {
        return Date()
    }
    
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    override var representedObject: Any?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    /// Some tasks need to have a fully prepared view and window. Initialize the UI from here.
    override func viewDidAppear()
    {
        //Debug.Print("At viewDidAppear")
        InitializeUI()
    }
    
    /// After the view is laid out, wait a certain amount of time before finalizing the UI and
    /// displays.
    /// - Note: After finalizing 3D code, it appears this mechanism is not needed. The delay has been
    ///         commented out for now and will be removed later if nothing untoward pops up.
    override func viewDidLayout()
    {
        #if true
        LateStart()
        #else
        perform(#selector(LateStart), with: nil, afterDelay: 0.25)
        #endif
    }
    
    /// Initialize maps and other items after a delay.
    @objc func LateStart()
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
                    Debug.Print("Calling LoadMap")
                    Earth.LoadMap(Maps[0], For: Earlier, Completed: EarthMapReceived)
                    return
                }
            }
        }

        if VType != .CubicWorld
        {
            FlatViewMainImage.image = FinalizeImage(MapManager.ImageFor(MapType: MapValue, ViewType: VType)!)
        }
        InitializeUpdateTimer()
        Started = true
        let IsFlat = VType == .FlatNorthCenter || VType == .FlatSouthCenter ? true : false
        SetFlatlandVisibility(FlatIsVisible: IsFlat)
        StarView.wantsLayer = true
        StarView.layer?.zPosition = CGFloat(LayerZLevels.StarLayer.rawValue)
        let Speed = Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
        switch Speed 
        {
            case .Off:
                self.StarView.Hide()
                
            case .Slow:
                self.StarView.Show(SpeedMultiplier: 1.0)
                
            case .Medium:
                self.StarView.Show(SpeedMultiplier: 3.0)
                
            case .Fast:
                self.StarView.Show(SpeedMultiplier: 7.0)
        }
    }
    
    /// Initialize the UI, reflecting the current user settings.
    func InitializeUI()
    {
        (view.window?.windowController as? MainWindow)!.UpTimeLabel.stringValue = "0"
        switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self)!
        {
            case HourValueTypes.None:
                (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 0
                
            case .RelativeToLocation:
                (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 3
                
            case .RelativeToNoon:
                (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 2
                
            case .Solar:
                (view.window?.windowController as? MainWindow)!.HourSegment.selectedSegment = 1
        }
        
        switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self)!
        {
            case .FlatNorthCenter:
                (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 0
                
            case .FlatSouthCenter:
                (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 1
                
            case .Globe3D:
                (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 2
                
            case .CubicWorld:
                (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 3
        }
        
        MainTimeLabelBottom.wantsLayer = true
        MainTimeLabelBottom.layer?.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelBottom.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        MainTimeLabelTop.wantsLayer = true
        MainTimeLabelTop.layer?.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelTop.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        
        FlatViewMainImage.wantsLayer = true
        
        let HaveLocalLocation = Settings.HaveLocalLocation()
        (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(HaveLocalLocation, forSegment: 3)
    }
    
    /// Update the text on the screen with the passed color.
    /// - Parameter With: The color to use to update the text.
    func UpdateScreenText(With Color: NSColor)
    {
        MainTimeLabelTop.textColor = Color
        MainTimeLabelBottom.textColor = Color
        #if DEBUG
        VersionLabel.textColor = Color
        VersionValue.textColor = Color
        BuildLabel.textColor = Color
        BuildValue.textColor = Color
        BuildDateValue.textColor = Color
        BuildDateLabel.textColor = Color
        #endif
    }
    
    // MARK: - Menu/toolbar event handlers.
    
    /// Returns the ID of the window.
    /// - Returns: The ID of the main window.
    func WindowID() -> CGWindowID
    {
        return CGWindowID(view.window!.windowNumber)
    }
    
    #if true
    /// Returns the coordinates of the main window.
    /// - Parameter WindowID: The ID of the main window.
    /// - Returns: The coordinates of the main window.
    func GetWindowCoordinates(WindowID: CGWindowID) -> CGRect?
    {
        if let WindowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]]
        {
            for Window in WindowList
            {
                let WID = Window[kCGWindowNumber as String]!
                let FinalWID = WID as! Int32
                if FinalWID == WindowID
                {
                    let _ = Window[kCGWindowName as String] as? String ?? ""
                    let Bounds = CGRect(dictionaryRepresentation: Window[kCGWindowBounds as String] as! CFDictionary)!
                    return Bounds
                }
            }
        }
        return nil
    }
    #endif
    
    @IBAction func ShowTodaysTimes(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Today", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "TodayWindow") as? TodayWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? TodayCode
            TodayDelegate = Controller
            WindowController.showWindow(nil)
        }
    }
    
    var TodayDelegate: WindowManagement? = nil
    
    @IBAction func ShowEarthquakeList(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "LiveData", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeWindow") as? EarthquakeWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? EarthquakeController
            Controller?.LoadData(DataType: .Earthquakes, Raw: PreviousEarthquakes as Any)
            WindowController.showWindow(nil)
        }
    }
    
    /// Handle the snapshot command.
    @IBAction func FileSnapshot(_ sender: Any)
    {
        CreateClientSnapshot()
    }
    
    /// Get a snapshot of the client window and save it.
    /// - Notes:
    ///   - The method used to create the snapshot initially saves the entire window, non-client as well
    ///     as the client area. This function crops the non-client area from the initial image.
    ///   - This function uses the scaling factor of the screen to determine the final resolution of the
    ///     snapshot image.
    ///      - This function works at the resolution of the user's montior. If there are multiple monitors
    ///        with different pixel densities, it is possible the saved image will be low resolution.
    ///   - This function will work equally on 3D content and 2D content.
    func CreateClientSnapshot()
    {
        let Multiplier = NSScreen.main!.backingScaleFactor
        var ImageOptions = CGWindowImageOption()
        if Multiplier == 2.0
        {
            ImageOptions = [CGWindowImageOption.boundsIgnoreFraming, CGWindowImageOption.bestResolution]
        }
        else
        {
            ImageOptions = [CGWindowImageOption.boundsIgnoreFraming, CGWindowImageOption.nominalResolution]
        }
        if let Ref = CGWindowListCreateImage(CGRect.zero, CGWindowListOption.optionIncludingWindow, WindowID(),
                                             ImageOptions)
        {
            let ViewHeight = PrimaryView.bounds.height
            let WindowFrame = view.window?.frame
            let Delta = abs(ViewHeight - WindowFrame!.height) * Multiplier
            let PrimarySize = NSSize(width: PrimaryView.bounds.size.width * Multiplier,
                                     height: PrimaryView.bounds.size.height * Multiplier)
            let ClientRect = NSRect(origin: NSPoint(x: 0, y: Delta), size: PrimarySize)
            let ClientAreaImage = Ref.cropping(to: ClientRect)
            let ScreenImage = NSImage(cgImage: ClientAreaImage!, size: PrimarySize)
            SaveImage(ScreenImage)
        }
    }
    
    /// Save the specified image to a file.
    /// - Note: Images are saved as .png files.
    /// - Parameter Image: The image to save.
    func SaveImage(_ Image: NSImage)
    {
        if let SaveWhere = GetSaveLocation()
        {
            let OK = Image.WritePNG(ToURL: SaveWhere)
            if OK
            {
                return
            }
        }
    }
    
    /// Get the URL where to save an image file.
    /// - Note: Only `.png` files are supported.
    /// - Returns: The URL of the target location on success, nil on error or user cancellation.
    func GetSaveLocation() -> URL?
    {
        let SavePanel = NSSavePanel()
        SavePanel.showsTagField = true
        SavePanel.title = "Save Image"
        SavePanel.allowedFileTypes = ["png"]
        SavePanel.canCreateDirectories = true
        SavePanel.nameFieldStringValue = "Flatland Snapshot.png"
        SavePanel.level = .modalPanel
        if SavePanel.runModal() == .OK
        {
            return SavePanel.url
        }
        else
        {
            return nil
        }
    }
    
    @IBAction func FileMapManager(_ sender: Any)
    {
    }
    
    @IBAction func ResetCurrentView(_ sender: Any)
    {
        if [ViewTypes.Globe3D, ViewTypes.CubicWorld].contains(Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D))
        {
            World3DView.ResetCamera()
        }
    }
    
    @IBAction func ViewHoursHideAll(_ sender: Any)
    {
        Settings.SetEnum(.None, EnumType: HourValueTypes.self, ForKey: .HourType)
        Show2DHours()
    }
    
    @IBAction func ViewHoursNoonCentered(_ sender: Any)
    {
        Settings.SetEnum(.Solar, EnumType: HourValueTypes.self, ForKey: .HourType)
        Show2DHours()
    }
    
    @IBAction func ViewHoursNoonDelta(_ sender: Any)
    {
        Settings.SetEnum(.RelativeToNoon, EnumType: HourValueTypes.self, ForKey: .HourType)
        Show2DHours()
    }
    
    @IBAction func ViewHoursLocationRelative(_ sender: Any)
    {
        if Settings.HaveLocalLocation()
        {
            Settings.SetEnum(.RelativeToLocation, EnumType: HourValueTypes.self, ForKey: .HourType)
            Show2DHours()
        }
    }
    
    @IBAction func ViewTypeNorthCentered(_ sender: Any)
    {
        World3DView.ClearEarthquakes()
        Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        FlatViewMainImage.image = FinalizeImage(MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)!)
        SetNightMask()
    }
    
    @IBAction func ViewTypeSouthCentered(_ sender: Any)
    {
        World3DView.ClearEarthquakes()
        Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        FlatViewMainImage.image = FinalizeImage(MapManager.ImageFor(MapType: MapValue, ViewType: .FlatSouthCenter)!)
        SetNightMask()
    }
    
    @IBAction func ViewTypeGlobal(_ sender: Any)
    {
        Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
    }
    
    @IBAction func ViewTypeCubic(_ sender: Any)
    {
        Settings.SetEnum(.CubicWorld, EnumType: ViewTypes.self, ForKey: .ViewType)
    }
    
    @IBAction func HelpAbout(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "About", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "AboutWindow") as? AboutWindow
        {
            let Window = WindowController.window
            AboutDelegate = Window?.contentView as? WindowManagement
            self.view.window?.beginSheet(Window!)
            {
                _ in
                self.AboutDelegate = nil
            }
        }
    }
    
    var AboutDelegate: WindowManagement? = nil
    
    @IBAction func DebugShow(_ sender: Any)
    {
    }
    
    @IBAction func DebugResetSettings(_ sender: Any)
    {
        Settings.Initialize(true)
    }
    
    @IBAction func ShowMainSettings(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "MainSettingsWindow") as? MainSettingsWindowsCode
        {
            let SettingWindow = WindowController.window
            let Controller = SettingWindow?.contentViewController as? MainSettingsBase
            Controller?.MainDelegate = self
            MainSettingsDelegate = Controller
            Controller?.LoadData(DataType: .Earthquakes, Raw: LatestEarthquakes as Any)
            WindowController.showWindow(nil)
        }
    }
    
    var MainSettingsDelegate: WindowManagement? = nil
    
    @IBAction func HandleHourTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    ViewHoursHideAll(sender)
                    
                case 1:
                    ViewHoursNoonCentered(sender)
                    
                case 2:
                    ViewHoursNoonDelta(sender)
                    
                case 3:
                    ViewHoursLocationRelative(sender)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleViewTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    ViewTypeNorthCentered(sender)
                    
                case 1:
                    ViewTypeSouthCentered(sender)
                    
                case 2:
                    ViewTypeGlobal(sender)
                    
                case 3:
                    ViewTypeCubic(sender)
                    
                default:
                    return
            }
        }
    }
    
    /// Handle closing events.
    func WillClose()
    {
        MainSettingsDelegate?.MainClosing()
        AboutDelegate?.MainClosing()
        TodayDelegate?.MainClosing()
        
        print("Flatland closing.")
    }
    
    func WindowResized(To: NSSize)
    {
        if !Started
        {
            return
        }
        Show2DHours()
    }
    
    // MARK: - MainProtocol required functions.
    
    /// Refresh called from someone who changed something. Provides alternative method for setting
    /// changes.
    /// - Parameter From: The caller's label.
    func Refresh(_ From: String)
    {
    }
    
    func DidClose(_ WhatClosed: String)
    {
        switch WhatClosed
        {
            case "MainSettings":
                MainSettingsDelegate = nil
                
            default:
                break
        }
    }
    
    /// Insert debug earthquake at the specified location.
    func InsertEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    {
        #if DEBUG
        Earthquakes?.InsertDebugEarthquake(Latitude: Latitude, Longitude: Longitude, Magnitude: Magnitude)
        #endif
    }
    
    /// Insert debug earthquake at a random location.
    func InsertEarthquake(Magnitude: Double)
    {
        #if DEBUG
        let Latitude = Double.random(in: -90.0 ... 90.0)
        let Longitude = Double.random(in: -180.0 ... 180.0)
        Earthquakes?.InsertDebugEarthquake(Latitude: Latitude, Longitude: Longitude, Magnitude: Magnitude)
        #endif
    }
    
    /// Force fetch earthquakes.
    func ForceFetchEarthquakes()
    {
        #if DEBUG
        Earthquakes?.ForceFetch()
        #endif
    }
    
    /// Insert a cluster of earthquakes for debugging.
    /// - Parameter Count: Number of earthquakes to insert.
    func InsertEarthquakeCluster(_ Count: Int)
    {
        #if DEBUG
        Earthquakes?.InsertEarthquakeCluster(Count)
        #endif
    }
    
    // MARK: - Asynchronous data protocol functions.
    
    func AsynchronousDataAvailable(DataType: AsynchronousDataTypes, Actual: Any?)
    {
        switch DataType
        {
            case .Earthquakes:
                if let NewEarthquakes = Actual as? [Earthquake]
                {
                    //Debug.Print("Have new earthquakes")
                    World3DView.NewEarthquakeList(NewEarthquakes, Final: DoneWithStenciling)
                    Plot2DEarthquakes(NewEarthquakes)
                    LatestEarthquakes = NewEarthquakes
                    (view.window?.windowController as? MainWindow)!.EarthquakeButton.isEnabled = true
                    //Debug.Print("Done with new earthquakes")
                }
                
            default:
                break
        }
    }
    
    var LatestEarthquakes = [Earthquake]()
    
    // MARK: - Code to intercept certain mouse actions to provide for our own camera control.
    
    override var acceptsFirstResponder: Bool
    {
        return true
    }
    
    override func scrollWheel(with event: NSEvent)
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        let WithOption = event.modifierFlags.contains(.option)
        let DeltaX = Int(event.deltaX)
        let DeltaY = Int(event.deltaY)
        if DeltaX == 0 && DeltaY == 0
        {
            return
        }
        World3DView.HandleMouseScrollWheelChanged(DeltaX: DeltaX, DeltaY: DeltaY, Option: WithOption)
        #endif
    }
    
    override func mouseDragged(with event: NSEvent)
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        let DeltaX = Int(event.deltaX)
        let DeltaY = Int(event.deltaY)
        if DeltaX == 0 && DeltaY == 0
        {
            return
        }
        World3DView.HandleMouseDragged(DeltaX: DeltaX, DeltaY: DeltaY)
        #endif
    }
    
    @objc func HandleDoubleClick()
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        World3DView.ResetFlatlandCamera()
        #else
        World3DView.ResetCamera()
        #endif
    }
    
    // MARK: - City variables.
    
    var CityTestList = [City]()
    let CityList = Cities()
    
    // MARK: - Variables for extensions.
    
    var QuakeURL: URL? = nil
    static var QuakeHandle: OpaquePointer? = nil
    static var HistoricalQuakesInitialized = false
    var QuakeIDCache: [String] = [String]()
    
    var UnescoURL: URL? = nil
    static var UnescoInitialized = false
    static var UnescoHandle: OpaquePointer? = nil
    var WorldHeritageSites: [WorldHeritageSite]? = nil
    
    var ShowingStatus = false
    
    var PreviousSunType = SunNames.None
    
    /// Previous percent drawn. Used to prevent constant updates when an update would not result
    /// in a visual change.
    var PreviousPercent: Double = -1.0
    
    let HalfCircumference: Double = 40075.0 / 2.0
    
    var CityLayer: CAShapeLayer? = nil
    var EarthquakeLayer: CAShapeLayer? = nil
    var PreviousEarthquakes = [Earthquake]()
    
    var StartupTask = Set<StartupTasks>()
    
    // MARK: - 2D view variables.
    
    var Quakes2D = [Earthquake]()
    let RecentMap: [EarthquakeRecents: Double] =
        [
            .Day05: 12.0 * 60.0 * 60.0,
            .Day1: 24.0 * 60.0 * 60.0,
            .Day2: 2.0 * 24.0 * 60.0 * 60.0,
            .Day3: 3.0 * 24.0 * 60.0 * 60.0,
            .Day7: 7.0 * 24.0 * 60.0 * 60.0,
            .Day10: 10.0 * 24.0 * 60.0 * 60.0,
        ]
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet var PrimaryView: NSView!
    @IBOutlet weak var StarView: Starfield!
    @IBOutlet weak var MainTimeLabelBottom: NSTextField!
    @IBOutlet weak var MainTimeLabelTop: NSTextField!
    @IBOutlet weak var SunViewBottom: NSImageView!
    @IBOutlet weak var SunViewTop: NSImageView!
    @IBOutlet weak var HourLayer2D: NSView!
    @IBOutlet weak var GridOverlay: NSView!
    @IBOutlet weak var CityView2D: NSView!
    @IBOutlet weak var NightMaskImageView: NSImageView!
    @IBOutlet weak var FlatViewMainImage: NSImageView!
    @IBOutlet weak var BackgroundView: NSView!
    @IBOutlet weak var FlatView: NSView!
    @IBOutlet weak var World3DView: GlobeView!
    @IBOutlet weak var StatusContainer: StatusUIView!
    @IBOutlet weak var StatusViewText: NSTextField!
    @IBOutlet weak var StatusViewIndicator: GeneralIndicator!
    //Debug elements
    @IBOutlet weak var VersionLabel: NSTextField!
    @IBOutlet weak var VersionValue: NSTextField!
    @IBOutlet weak var BuildLabel: NSTextField!
    @IBOutlet weak var BuildValue: NSTextField!
    @IBOutlet weak var BuildDateLabel: NSTextField!
    @IBOutlet weak var BuildDateValue: NSTextField!
    @IBOutlet weak var DebugTextGrid: NSGridView!
}

