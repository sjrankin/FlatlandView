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

class MainView: NSViewController, MainProtocol, SettingChangedProtocol, AsynchronousDataProtocol
{
    // Start initialization of the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Settings.Initialize()
        Settings.AddSubscriber(self)
        
        Earthquakes = USGS()
        Earthquakes?.Delegate = self
        if Settings.GetBool(.EnableEarthquakes)
        {
            let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
            Earthquakes?.GetEarthquakes(Every: FetchInterval)
        }
        
        FileIO.Initialize()
        PrimaryMapList = ActualMapIO.LoadMapList()
        
        BackgroundView.wantsLayer = true
        let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
        BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
        let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
        UpdateScreenText(With: Opposite)
        
        World3DView.wantsLayer = true
        World3DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        
        InitializeFlatland()
        
        #if DEBUG
        DebugGrid.wantsLayer = true
        DebugGrid.layer?.zPosition = CGFloat(LayerZLevels.DebugLayer.rawValue)
        DebugGrid.isHidden = false
        #else
        DebugGrid.removeFromSuperview()
        #endif
        
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
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
        #if true
        StarView.wantsLayer = true
        StarView.layer?.zPosition = CGFloat(LayerZLevels.StarLayer.rawValue)
        var SpeedValue = 1.0
        let Speed = Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
        switch Speed
        {
            case .Slow:
                SpeedValue = 1.0
            
            case .Medium:
                SpeedValue = 3.0
            
            case .Fast:
                SpeedValue = 7.0
        }
        Settings.QueryBool(.ShowMovingStars)
        {
            DoShow in
            if DoShow
            {
                self.StarView.Show(SpeedMultiplier: SpeedValue)
            }
            else
            {
                self.StarView.Hide()
            }
        }
        #else
        if Settings.GetBool(.ShowMovingStars)
        {
            StarView.Show()
        }
        else
        {
            StarView.Hide()
        }
        #endif
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
        Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        FlatViewMainImage.image = FinalizeImage(MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)!)
        SetNightMask()
    }
    
    @IBAction func ViewTypeSouthCentered(_ sender: Any)
    {
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
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
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
            Controller?.LoadData(DataType: .Earthquakes, Raw: LatestEarthquakes as Any)
            Controller?.LoadData(DataType: .Earthquakes2, Raw: LatestEarthquakes2 as Any)
            WindowController.showWindow(nil)
        }
    }
    
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
    
    func WillClose()
    {
        print("Closing.")
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
    
    // MARK: - Settings changed required functions.
    
    /// ID of this class in relation to the settings changed protocol.
    func SubscriberID() -> UUID
    {
        return UUID(uuidString: "66629111-b430-4231-af5a-e39f35ae7883")!
    }
    
    /// Handle changed settings. Settings may be changed from anywhere at any time. This function
    /// will update the view when the setting change is reported.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before the change.
    /// - Parameter NewValue: The new value of the setting.
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .InAttractMode:
                let CurrentMode = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                if CurrentMode == .Globe3D || CurrentMode == .CubicWorld
                {
                    World3DView.SetAttractMode()
                }
            
            case .MapType:
                let NewMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                if let InterimImage: NSImage = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                {
                    FlatViewMainImage.image = FinalizeImage(InterimImage)
                    World3DView.AddEarth()
                }
                else
                {
                    print("Error loading map \(NewMap) for view \(MapViewType)")
                }
                if MapViewType == .Globe3D
                {
                    if Settings.GetBool(.EnableEarthquakes)
                    {
                        World3DView.PlotEarthquakes()
                    }
                    Plot2DEarthquakes(LatestEarthquakes, Replot: true)
            }
            
            case .ViewType:
                if let New = NewValue as? ViewTypes
                {
                    var IsFlat = false
                    switch New
                    {
                        case .FlatNorthCenter, .FlatSouthCenter:
                            IsFlat = true
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                Remove2DEarthquakes()
                                Plot2DEarthquakes(LatestEarthquakes, Replot: true)
                        }
                        
                        case .CubicWorld:
                            World3DView.AddEarth()
                            IsFlat = false
                        
                        case .Globe3D:
                            World3DView.AddEarth()
                            IsFlat = false
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                World3DView.PlotEarthquakes()
                        }
                    }
                    SetFlatlandVisibility(FlatIsVisible: IsFlat)
            }
            
            case .ShowNight:
                break
            
            case .NightDarkness:
                let NewMask = GetNightMask(ForDate: Date())
                NightMaskImageView.image = NewMask
            
            case .HourType:
                if let NewHourType = NewValue as? HourValueTypes
                {
                    World3DView.UpdateHourLabels(With: NewHourType)
            }
            
            case .SunType:
                UpdateSunLocations()
            
            case .CityShapes:
                World3DView.PlotCities()
            
            case .PopulationType:
                World3DView.PlotCities()
            
            case .ShowHomeLocation:
                World3DView.PlotCities()
            
            case .UserLocations:
                World3DView.PlotCities()
            
            case .ShowUserLocations:
                World3DView.PlotCities()
            
            case .HomeShape:
                World3DView.PlotHomeLocation()
            
            case .PolarShape:
                World3DView.PlotPolarShape()
            
            case .ShowWorldHeritageSites:
                World3DView.PlotWorldHeritageSites()
            
            case .WorldHeritageSiteType:
                World3DView.PlotWorldHeritageSites()
            
            case .Show3DEquator, .Show3DTropics, .Show3DMinorGrid, .Show3DPolarCircles, .Show3DPrimeMeridians,
                 .MinorGrid3DGap, .Show3DGridLines:
                World3DView.SetLineLayer()
            
            case .LocalLongitude, .LocalLatitude:
                (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(Settings.HaveLocalLocation(), forSegment: 3)
            
            case .ShowLocalData:
                UpdateInfoGridVisibility(Show: Settings.GetBool(.ShowLocalData))
            
            case .Script:
                World3DView.PlotPolarShape()
                World3DView.UpdateHours()
            
            case .StarSpeeds:
                var SpeedValue = 1.0
                let Speed = Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
                switch Speed
                {
                    case .Slow:
                        SpeedValue = 1.0
                    
                    case .Medium:
                        SpeedValue = 3.0
                    
                    case .Fast:
                        SpeedValue = 7.0
                }
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .CubicWorld || ViewType == .Globe3D
                {
                    if Settings.GetBool(.ShowMovingStars)
                    {
                        StarView.Show(SpeedMultiplier: SpeedValue)
                    }
            }
            
            case .ShowMovingStars:
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .CubicWorld || ViewType == .Globe3D
                {
                    Settings.QueryBool(.ShowMovingStars)
                    {
                        DoShow in
                        if DoShow
                        {
                            var SpeedValue = 1.0
                            let Speed = Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
                            switch Speed
                            {
                                case .Slow:
                                    SpeedValue = 1.0
                                
                                case .Medium:
                                    SpeedValue = 3.0
                                
                                case .Fast:
                                    SpeedValue = 7.0
                            }
                            self.StarView.Show(SpeedMultiplier: SpeedValue)
                        }
                        else
                        {
                            self.StarView.Hide()
                        }
                    }
            }
                
            case .ShowPOIEmission:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                {
                    World3DView.PlotCities()
                }
            
            case .EnableEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                    Earthquakes?.GetEarthquakes(Every: FetchInterval)
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
                }
                else
                {
                    Earthquakes?.StopReceivingEarthquakes()
                    World3DView.ClearEarthquakes()
            }
            
            case .EarthquakeFetchInterval:
                let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                Earthquakes?.StopReceivingEarthquakes()
                Earthquakes?.GetEarthquakes(Every: FetchInterval)
            
            case .MinimumMagnitude:
                World3DView.ClearEarthquakes()
                let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                Earthquakes?.StopReceivingEarthquakes()
                Earthquakes?.GetEarthquakes(Every: FetchInterval)
            
            case .BaseEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
            }
            
            case .EarthquakeAge:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
            }
            
            case .ColorDetermination:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
            }
            
            case .EarthquakeShapes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
            }
            
            case .BackgroundColor3D:
                let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
                BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
                let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
                UpdateScreenText(With: Opposite)
            
            case .UseAmbientLight:
                World3DView.SetupLights()
            
            #if DEBUG
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints:
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .Globe3D || ViewType == .CubicWorld
                {
                    var DebugTypes = [DebugOptions3D]()
                    Settings.QueryBool(.ShowSkeletons)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.Skeleton)
                        }
                    }
                    Settings.QueryBool(.ShowBoundingBoxes)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.BoundingBoxes)
                        }
                    }
                    Settings.QueryBool(.ShowWireframes)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.WireFrame)
                        }
                    }
                    Settings.QueryBool(.ShowLightInfluences)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.LightInfluences)
                        }
                    }
                    Settings.QueryBool(.ShowLightExtents)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.LightExtents)
                        }
                    }
                    Settings.QueryBool(.ShowConstraints)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.Constraints)
                        }
                    }
                    World3DView.SetDebugOption(DebugTypes)
            }
            #endif
            
            default:
                #if DEBUG
                print("Unhandled setting change: \(Setting)")
                #else
                //Don't be so verbose when not in debug mode.
                break
            #endif
        }
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
    
    // MARK: - Asynchronous data protocol functions.
    
    func AsynchronousDataAvailable(DataType: AsynchronousDataTypes, Actual: Any?)
    {
        switch DataType
        {
            case .Earthquakes:
                #if false
                break
                #else
                if let EarthquakeData = Actual as? [Earthquake]
                {
                    print("\(EarthquakeData.count) earthquakes returned")
                    World3DView.NewEarthquakeList(EarthquakeData)
                    Plot2DEarthquakes(EarthquakeData)
                    LatestEarthquakes = EarthquakeData
            }
                #endif
            
            case .Earthquakes2:
                #if false
                break
                #else
                if let EarthquakeData = Actual as? [Earthquake2]
                {
                    print("Have \(EarthquakeData.count) earthquakes")
                    World3DView.NewEarthquakeList2(EarthquakeData)
                    Plot2DEarthquakes2(EarthquakeData)
                    LatestEarthquakes2 = EarthquakeData
            }
                #endif
        }
    }
    
    var LatestEarthquakes = [Earthquake]()
    var LatestEarthquakes2 = [Earthquake2]()
    
    // MARK: - City variables.
    
    var CityTestList = [City]()
    let CityList = Cities()
    
    // MARK: - Variables for extensions.
    
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
    var PreviousEarthquakes2 = [Earthquake2]()
    
    // MARK: - Interface builder outlets.
    
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
    
}

