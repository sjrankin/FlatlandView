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

class MainView: NSViewController, MainProtocol, SettingChangedProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Settings.Initialize()
        Settings.AddSubscriber(self)
        
        FileIO.Initialize()
        MasterMapList = ActualMapIO.LoadMapList()
        
        BackgroundView.wantsLayer = true
        BackgroundView.layer?.backgroundColor = NSColor.black.cgColor
        
        World3DView.wantsLayer = true
        World3DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
        
        InitializeFlatland()
        
        #if DEBUG
        DebugGrid.wantsLayer = true
        DebugGrid.layer?.zPosition = 19000
        DebugGrid.isHidden = false
        #else
        DebugGrid.removeFromSuperview()
        #endif
        
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
    }
    
    var MasterMapList: ActualMapList? = nil
    
    /// Start the update timer.
    func InitializeUpdateTimer()
    {
        UpdateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(MasterTimerHandler),
                                           userInfo: nil,
                                           repeats: true)
        RunLoop.current.add(UpdateTimer!, forMode: .common)
        MasterTimerHandler()
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
    
    @objc func MasterTimerHandler()
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
                if let SunriseTime = SunTimes.Sunrise(For: Date(), At: Location,
                                                      TimeZoneOffset: 0)
                {
                    SunRiseTime = SunriseTime
                    LocalSunrise.stringValue = SunriseTime.PrettyTime()
                }
                else
                {
                    RiseAndSetAvailable = false
                    LocalSunrise.stringValue = "No sunrise"
                }
                if let SunsetTime = SunTimes.Sunset(For: Date(), At: Location,
                                                    TimeZoneOffset: 0)
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
    
    override func viewDidLayout()
    {
        perform(#selector(LateStart), with: nil, afterDelay: 1.0)
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
        LocalInfoGrid.layer?.zPosition = 19000
        LocalInfoGrid.isHidden = !Settings.GetBool(.ShowLocalData)
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
        MainTimeLabelBottom.textColor = NSColor.white
        MainTimeLabelTop.wantsLayer = true
        MainTimeLabelTop.layer?.zPosition = CGFloat(LayerZLevels.TimeLabels.rawValue)
        MainTimeLabelTop.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        MainTimeLabelTop.textColor = NSColor.white
        
        FlatViewMainImage.wantsLayer = true
        
        let HaveLocalLocation = Settings.HaveLocalLocation()
        (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(HaveLocalLocation, forSegment: 3)
    }
    
    // MARK: - Menu/toolbar event handlers.
    
    /// Handle the snapshot command.
    @IBAction func FileSnapshot(_ sender: Any)
    {
        let CurrentView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
        switch CurrentView
        {
            case .CubicWorld, .Globe3D:
                World3DView.backgroundColor = NSColor.black
                perform(#selector(FinalSnapshot), with: nil, afterDelay: 0.1)
            
            case .FlatNorthCenter, .FlatSouthCenter:
                break
        }
    }
    
    /// The snapshot functionality (at least for 3D views) starts in `FileSnapshot` and finishes here.
    /// In order to work correctly, the background of the 3D view needs to be set to black, but that
    /// takes a little time. This function is called after a small delay to ensure the background has
    /// been updated correctly. Immediately upon being called, this function will get a snapshot (using
    /// built-in functionality) of the 3D view then reset the background color. Then, `SaveImage` will
    /// be called to finish things.
    @objc func FinalSnapshot()
    {
        let Snapshot3D = World3DView.snapshot()
        World3DView.backgroundColor = NSColor.clear
        SaveImage(Snapshot3D)
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
    /// - Returns: The URL of the target location on success, nil on error or user cancellation.
    func GetSaveLocation() -> URL?
    {
        let SavePanel = NSSavePanel()
        SavePanel.showsTagField = true
        SavePanel.title = "Save Image"
        SavePanel.allowedFileTypes = ["jpg", "jpeg", "png", "tiff"]
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
    
    @IBAction func ViewSelectMap(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "MapSelector", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "MapPickerWindow") as? MapPickerWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? MapPickerController
            {
                Controller.MainDelegate = self
                self.view.window?.beginSheet(Window!, completionHandler: nil)
            }
        }
    }
    
    var SelectMapWindow: MapPickerWindow? = nil
    
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
            let Controller = SettingWindow?.contentViewController as? MainSettings
            Controller?.MainDelegate = self
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
    
    // MARK: - Protocol-required functions
    
    // MARK: - MainProtocol required functions.
    
    func Refresh(_ From: String)
    {
        print("Refresh called from \(From)")
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
            case .MapType:
                let NewMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                FlatViewMainImage.image = FinalizeImage(MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)!)
                World3DView.AddEarth()
            
            case .ViewType:
                if let New = NewValue as? ViewTypes
                {
                    var IsFlat = false
                    switch New
                    {
                        case .FlatNorthCenter, .FlatSouthCenter:
                            IsFlat = true
                        
                        case .CubicWorld:
                            World3DView.AddEarth()
                            IsFlat = false
                        
                        case .Globe3D:
                            World3DView.AddEarth()
                            IsFlat = false
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
            
            default:
                print("Unhandled setting change: \(Setting)")
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
    
    // MARK: - Interface builder outlets.
    
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
}

