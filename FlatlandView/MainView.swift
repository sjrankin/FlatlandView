//
//  ViewController.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 5/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa
import Foundation
import SceneKit

class MainView: NSViewController, MainProtocol, AsynchronousDataProtocol
{
    // Start initialization of the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        StartupTask.insert(.Initialize)
        StartupTask.insert(.UIInitialize)
        StartupTask.insert(.LoadNASATiles)
        StartupTask.insert(.LoadUSGSQuakes)
        Settings.Initialize()
        Settings.AddSubscriber(self)
        
        SetIndicatorText("")
        if Settings.GetBool(.PreloadNASATiles)
        {
            let Earlier = Date().HoursAgo(36)
            let Maps = EarthData.MakeSatelliteMapDefinitions()
            let Earth = EarthData()
            Earth.MainDelegate = self
            Earth.Delegate = self
            Utility.Print("Calling LoadMap")
            Earth.LoadMap(Maps[0], For: Earlier, Completed: EarthMapReceived)
        }
        
        Earthquakes = USGS()
        Earthquakes?.Delegate = self
        if Settings.GetBool(.EnableEarthquakes)
        {
            Utility.Print("Calling GetEarthquakes")
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
            StatusMessage.append("\(Versioning.VerySimpleVersionString()), build \(Versioning.Build)")
            let ShowDuration = Settings.GetDouble(.SplashScreenDuration, 6.0)
            DisplayStatusText(StatusMessage, Hide: ShowDuration, ShowIfNotVisible: true)
            if Settings.GetBool(.EnableEarthquakes) || Settings.GetBool(.PreloadNASATiles)
            {
                DisplaySubText("Loading data from remote sources.")
            }
        }
        else
        {
            HideStatus()
        }
        
        #if DEBUG
        DebugGrid.wantsLayer = true
        DebugGrid.layer?.zPosition = CGFloat(LayerZLevels.DebugLayer.rawValue)
        DebugGrid.isHidden = false
        #else
        DebugGrid.removeFromSuperview()
        #endif
        
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        DebugTimeValue.textColor = NSColor.white
        DebugTimeValue.isHidden = true
        DebugTimeLabel.textColor = NSColor.white
        DebugTimeLabel.isHidden = true
        DebugRotationalLabel.textColor = NSColor.white
        DebugRotationalLabel.isHidden = true
        DebugRotationalValue.textColor = NSColor.white
        DebugRotationalValue.isHidden = true
        Utility.Print("Done with viewDidLoad")
    }
    
    /// Called when a new NASA map has been received and fully assembled.
    /// - Parameter Image: The NASA satellite image map.
    /// - Parameter Duration: The number of seconds from when images started to be received to the
    ///                       completion of the map.
    /// - Parameter ImageDate: The date of the map.
    func EarthMapReceived(Image: NSImage, Duration: Double, ImageDate: Date)
    {
        Utility.Print("Received earth map from NASA")
        SetIndicatorText("")
        SetIndicatorVisibility(false)
        //let Brightened = Image.SetImageBrightness(To: 0.1)
        Utility.Print("Map generation duration \(Duration), Date: \(ImageDate)")
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
            UptimeValueLabel.stringValue = "\(UptimeSeconds)"
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
        
        if Settings.GetBool(.ShowLocalData)
        {
            let Cal = Calendar.current
            if Settings.HaveLocalLocation()
            {
                var RiseAndSetAvailable = true
                var SunRiseTime = Date()
                var SunSetTime = Date()
                let LocalLat = Settings.GetDoubleNil(.LocalLatitude)
                let LocalLon = Settings.GetDoubleNil(.LocalLongitude)
                let Location = GeoPoint2(LocalLat!, LocalLon!)
                let SunTimes = Sun()
                if let SunriseTime = SunTimes.Sunrise(For: Date(), At: Location, TimeZoneOffset: 0)
                {
                    SunRiseTime = SunriseTime
                    LocalSunrise.stringValue = SunriseTime.PrettyTime()
                }
                else
                {
                    RiseAndSetAvailable = false
                    LocalSunrise.stringValue = "No sunrise"
                }
                if let SunsetTime = SunTimes.Sunset(For: Date(), At: Location, TimeZoneOffset: 0)
                {
                    SunSetTime = SunsetTime
                    LocalSunset.stringValue = SunsetTime.PrettyTime()
                }
                else
                {
                    RiseAndSetAvailable = false
                    LocalSunset.stringValue = "No sunset"
                }
                if RiseAndSetAvailable
                {
                    let RiseHour = Cal.component(.hour, from: SunRiseTime)
                    let RiseMinute = Cal.component(.minute, from: SunRiseTime)
                    let RiseSecond = Cal.component(.second, from: SunRiseTime)
                    let SetHour = Cal.component(.hour, from: SunSetTime)
                    let SetMinute = Cal.component(.minute, from: SunSetTime)
                    let SetSecond = Cal.component(.second, from: SunSetTime)
                    let RiseSeconds = RiseSecond + (RiseMinute * 60) + (RiseHour * 60 * 60)
                    let SetSeconds = SetSecond + (SetMinute * 60) + (SetHour * 60 * 60)
                    let SecondDelta = SetSeconds - RiseSeconds
                    let NoonTime = RiseSeconds + (SecondDelta / 2)
                    let (NoonHour, NoonMinute, NoonSecond) = Date.SecondsToTime(NoonTime)
                    let HourS = "\(NoonHour)"
                    let MinuteS = (NoonMinute < 10 ? "0" : "") + "\(NoonMinute)"
                    let SecondS = (NoonSecond < 10 ? "0" : "") + "\(NoonSecond)"
                    LocalNoon.stringValue = "\(HourS):\(MinuteS):\(SecondS)"
                }
                else
                {
                    LocalNoon.stringValue = ""
                }
            }
            else
            {
                LocalSunset.stringValue = "N/A"
                LocalSunrise.stringValue = "N/A"
                LocalNoon.stringValue = "N/A"
            }
            let DaysDeclination = Sun.Declination(For: Date())
            DeclinationLabel.stringValue = "\(DaysDeclination.RoundedTo(3))°"
            let H = Cal.component(.hour, from: Date())
            let M = Cal.component(.minute, from: Date())
            let S = Cal.component(.second, from: Date())
            let CurrentSeconds = S + (M * 60) + (H * 60 * 60)
            DailySeconds.stringValue = "\(CurrentSeconds)"
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
        Utility.Print("At viewDidAppear")
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
                if Category == .Satellite
                {
                    //Start loading the map here.
                    let Earlier = Date().HoursAgo(36)
                    let Maps = EarthData.MakeSatelliteMapDefinitions()
                    let Earth = EarthData()
                    Earth.MainDelegate = self
                    Earth.Delegate = self
                    Utility.Print("Calling LoadMap")
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
        LocalInfoGrid.wantsLayer = true
        LocalInfoGrid.layer?.zPosition = CGFloat(LayerZLevels.LocalInfoGridLayer.rawValue)
        LocalInfoGrid.isHidden = !Settings.GetBool(.ShowLocalData)
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
    
    /// Update the text on the 3D screen with the passed color.
    /// - Parameter With: The color to use to update the text.
    func UpdateScreenText(With Color: NSColor)
    {
        MainTimeLabelTop.textColor = Color
        MainTimeLabelBottom.textColor = Color
        UptimeValueLabel.textColor = Color
        DailySeconds.textColor = Color
        DeclinationLabel.textColor = Color
        LocalSunset.textColor = Color
        LocalSunrise.textColor = Color
        LocalNoon.textColor = Color
        UptimeLabel.textColor = Color
        LocalSunriseLabel.textColor = Color
        LocalNoonLabel.textColor = Color
        LocalSunsetLabel.textColor = Color
        DeclinationTextLabel.textColor = Color
        DailySecondsLabel.textColor = Color
        StatusLabel.textColor = Color
        SetStatusIndicatorColor(Color)
        SetStatusIndicatorLabel("")
        SetStatusIndicatorVisibility(IsVisible: true)
        SetStatusIndicatorValue(0.5)
    }
    
    /// Sets the text of the indicator label.
    /// - Note: There is not much room so keeping the text short is ideal.
    /// - Parameter NewText: The text to display. Set to an empty string to hide the text.
    func SetStatusIndicatorLabel(_ NewText: String)
    {
        OperationQueue.main.addOperation
        {
            self.StatusLabel.stringValue = NewText
        }
    }
    
    /// Show or hide the status indicator.
    /// - Parameter IsVisible: Set to true to show the indicator, false to hide it.
    func SetStatusIndicatorVisibility(IsVisible: Bool)
    {
        OperationQueue.main.addOperation
        {
            self.StatusIndicator.isHidden = !IsVisible
        }
    }
    
    /// Set the value of the indicator.
    /// - Parameter NewValue: The value to set the indicator to. Must be in the range 0.0 to 1.0.
    func SetStatusIndicatorValue(_ NewValue: Double)
    {
        OperationQueue.main.addOperation
        {
            self.StatusIndicator.CurrentPercent = CGFloat(NewValue)
        }
    }
    
    /// Set the color of the completed portion of the indicator.
    /// - Note: The incomplete portion is not set here and defaults to clear.
    /// - Parameter Color: The color of the completed part of the indicator.
    func SetStatusIndicatorColor(_ Color: NSColor)
    {
        OperationQueue.main.addOperation
        {
            self.StatusIndicator.Color = Color
        }
    }
    
    // MARK: - Menu/toolbar event handlers.
    
    /// Returns the ID of the window.
    /// - Returns: The ID of the main window.
    func WindowID() -> CGWindowID
    {
        return CGWindowID(view.window!.windowNumber)
    }
    
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
                    let WindowName = Window[kCGWindowName as String] as? String ?? ""
                    let Bounds = CGRect(dictionaryRepresentation: Window[kCGWindowBounds as String] as! CFDictionary)!
                    return Bounds
                }
            }
        }
        return nil
    }
    
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
        let CurrentView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
        switch CurrentView
        {
            case .CubicWorld, .Globe3D:
                perform(#selector(FinalSnapshot), with: nil, afterDelay: 0.1)
                
            case .FlatNorthCenter, .FlatSouthCenter:
                let Screen = NSImage(data: self.view.dataWithPDF(inside: self.view.bounds))
                let NewSize = Screen!.size
                
                let BlackImage = NSImage(size: NewSize)
                BlackImage.lockFocus()
                NSColor.black.drawSwatch(in: NSRect(origin: .zero, size: NewSize))
                BlackImage.unlockFocus()
                
                BlackImage.lockFocus()
                let SelfRect = NSRect(origin: CGPoint.zero, size: Screen!.size)
                Screen!.draw(at: NSPoint.zero, from: SelfRect, operation: .sourceAtop, fraction: 1.0)
                BlackImage.unlockFocus()
                SaveImage(BlackImage)
        }
    }
    
    /// The snapshot functionality (at least for 3D views) starts in `FileSnapshot` and finishes here.
    /// In order to work correctly, the background of the 3D view needs to be set to the background color,
    /// but that takes a little time. This function is called after a small delay to ensure the background
    /// has been updated correctly. Immediately upon being called, this function will get a snapshot (using
    /// built-in functionality) of the 3D view then reset the background color. Then, `SaveImage` will
    /// be called to finish things.
    /// - Note: In order to include the ancillary elements (eg, time, local data grid), a screen shot
    ///         is taken in 2D mode as well and composited with the 3D snapshot.
    @objc func FinalSnapshot()
    {
        SunViewTop.isHidden = true
        SunViewBottom.isHidden = true
        let Snapshot3D = World3DView.snapshot()
        
        let Screen = NSImage(data: self.view.dataWithPDF(inside: self.view.bounds))
        let NewSize = Screen!.size
        
        let BGColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
        let BGImage = NSImage(size: NewSize)
        BGImage.lockFocus()
        BGColor.drawSwatch(in: NSRect(origin: .zero, size: NewSize))
        BGImage.unlockFocus()
        
        BGImage.lockFocus()
        let SelfRect = NSRect(origin: CGPoint.zero, size: Screen!.size)
        Screen!.draw(at: NSPoint.zero, from: SelfRect, operation: .sourceAtop, fraction: 1.0)
        BGImage.unlockFocus()
        
        let Final3D = Utility.ResizeImage(Image: Snapshot3D, Longest: max(NewSize.width, NewSize.height))
        
        BGImage.lockFocus()
        Final3D.draw(at: NSPoint.zero, from: SelfRect, operation: .sourceAtop, fraction: 1.0)
        BGImage.unlockFocus()
        
        SaveImage(BGImage)
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
    
    func DebugTimeChanged(_ NewTime: Date)
    {
        #if DEBUG
        if Settings.GetBool(.DebugTime)
        {
            DebugTimeValue.textColor = NSColor.white
            DebugTimeValue.isHidden = false
            DebugTimeLabel.textColor = NSColor.white
            DebugTimeLabel.isHidden = false
            DebugTimeValue.stringValue = Utility.MakeTimeString(TheDate: NewTime)
        }
        #endif
    }
    
    func DebugRotationChanged(_ NewRotation: Double)
    {
        DebugRotationalLabel.textColor = NSColor.white
        DebugRotationalLabel.isHidden = false
        DebugRotationalValue.textColor = NSColor.white
        DebugRotationalValue.isHidden = false
        DebugRotationalValue.stringValue = "\((NewRotation * 100.0).RoundedTo(2))%"
    }
    
    /// Hide or show the info grid.
    /// - Note: For fun, the grid is shown or hidden using animation.
    /// - Parameter Show: Determines whether the info grid is hidden or shown.
    func UpdateInfoGridVisibility(Show: Bool)
    {
        let AlphaStart: Float = Show ? 0.0 : 1.0
        let AlphaEnd: Float = Show ? 1.0 : 0.0
        let Animate = CABasicAnimation(keyPath: "opacity")
        Animate.fromValue = AlphaStart
        Animate.toValue = AlphaEnd
        Animate.duration = 0.3
        Animate.autoreverses = false
        Animate.fillMode = .forwards
        Animate.isRemovedOnCompletion = false
        LocalInfoGrid.layer?.add(Animate, forKey: "fade")
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
    
    /// Sets the indicator value.
    /// - Parameter Percent: New indicator percent. Must be in the range 0.0 to 1.0.
    func SetIndicatorPercent(_ Percent: Double)
    {
        SetStatusIndicatorValue(Percent)
    }
    
    /// Sets the indicator text. Pass an empty string to clear the text.
    /// - Parameter NewText: The text to set the indicator label to.
    func SetIndicatorText(_ NewText: String)
    {
        SetStatusIndicatorLabel(NewText)
    }
    
    /// Sets the color of the completed portion of the indicator.
    /// - Parameter NewColor: The color to set the indicator to.
    func SetIndicatorColor(_ NewColor: NSColor)
    {
        SetStatusIndicatorColor(NewColor)
    }
    
    /// Sets the visibility of the indicator. Only affects the pie chart, not the text.
    /// - Parameter IsVisible: Determines the visibility.
    func SetIndicatorVisibility(_ IsVisible: Bool)
    {
        SetStatusIndicatorVisibility(IsVisible: IsVisible)
    }
    
    // MARK: - Asynchronous data protocol functions.
    
    func AsynchronousDataAvailable(DataType: AsynchronousDataTypes, Actual: Any?)
    {
        switch DataType
        {
            case .Earthquakes:
                if let NewEarthquakes = Actual as? [Earthquake]
                {
                    Utility.Print("Have new earthquakes")
                    World3DView.NewEarthquakeList(NewEarthquakes)
                    Plot2DEarthquakes(NewEarthquakes)
                    LatestEarthquakes = NewEarthquakes
                    (view.window?.windowController as? MainWindow)!.EarthquakeButton.isEnabled = true
                    Utility.Print("Done with new earthquakes")
                }
                
            default:
                break
        }
    }
    
    var LatestEarthquakes = [Earthquake]()
    
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
    
    var PreviousSunType = SunNames.None
    
    /// Previous percent drawn. Used to prevent constant updates when an update would not result
    /// in a visual change.
    var PreviousPercent: Double = -1.0
    
    let HalfCircumference: Double = 40075.0 / 2.0
    
    var CityLayer: CAShapeLayer? = nil
    var EarthquakeLayer: CAShapeLayer? = nil
    var PreviousEarthquakes = [Earthquake]()
    
    //Status display variables.
    var StatusDelegate: StatusProtocol? = nil
    var ShowingStatus: Bool = false
    
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
    
    @IBOutlet weak var DebugRotationalLabel: NSTextField!
    @IBOutlet weak var DebugRotationalValue: NSTextField!
    @IBOutlet weak var DebugTimeValue: NSTextField!
    @IBOutlet weak var DebugTimeLabel: NSTextField!
    @IBOutlet weak var StarView: Starfield!
    @IBOutlet weak var UptimeValueLabel: NSTextField!
    @IBOutlet weak var DebugGrid: NSGridView!
    @IBOutlet weak var DailySeconds: NSTextField!
    @IBOutlet weak var DeclinationLabel: NSTextField!
    @IBOutlet weak var LocalSunset: NSTextField!
    @IBOutlet weak var LocalNoon: NSTextField!
    @IBOutlet weak var LocalSunrise: NSTextField!
    @IBOutlet weak var LocalInfoGrid: NSGridView!
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
    @IBOutlet weak var UptimeLabel: NSTextField!
    @IBOutlet weak var LocalSunriseLabel: NSTextField!
    @IBOutlet weak var LocalNoonLabel: NSTextField!
    @IBOutlet weak var LocalSunsetLabel: NSTextField!
    @IBOutlet weak var DeclinationTextLabel: NSTextField!
    @IBOutlet weak var DailySecondsLabel: NSTextField!
    @IBOutlet weak var StatusLabel: NSTextField!
    @IBOutlet weak var StatusIndicator: PiePercent!
    @IBOutlet weak var StatusContainer: StatusContainerController!
}

