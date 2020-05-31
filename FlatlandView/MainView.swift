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
        
        GlobeView.wantsLayer = true
        GlobeView.layer?.zPosition = 0
        
        InitializeFlatland()
        
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
        
        SetFlatlandVisibility(FlatIsVisible: true)
        FlatViewMainImage.image = FinalizeImage(MapManager.ImageFor(MapType: .Simple, ViewType: .FlatNorthCenter)!)
        InitializeUpdateTimer()
        Started = true
    }
    
    var MasterMapList: ActualMapList? = nil
    
    func InitializeUpdateTimer()
    {
        UpdateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(MasterTimerHandler),
                                           userInfo: nil,
                                           repeats: true)
        RunLoop.current.add(UpdateTimer!, forMode: .common)
        MasterTimerHandler()
    }
    
    var UpdateTimer: Timer? = nil
    var Started = false
    
    @objc func MasterTimerHandler()
    {
        UpdateSunLocations()
        let CurrentMapType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        switch CurrentMapType
        {
            case .CubicWorld:
                break
            
            case .Globe3D:
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
        
        let Now = GetUTC()
        let Formatter = DateFormatter()
        Formatter.dateFormat = "HH:mm:ss"
        var TimeZoneAbbreviation = ""
        if Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self) == .UTC
        {
            TimeZoneAbbreviation = "UTC"
        }
        else
        {
            TimeZoneAbbreviation = GetLocalTimeZoneID() ?? "UTC"
        }
        let TZ = TimeZone(abbreviation: TimeZoneAbbreviation)
        Formatter.timeZone = TZ
        let Final = Formatter.string(from: Now)
        let FinalText = Final + " " + TimeZoneAbbreviation
        MainTimeLabelTop.stringValue = FinalText
        MainTimeLabelBottom.stringValue = FinalText
        
        let CurrentSeconds = Now.timeIntervalSince1970
        if CurrentSeconds != OldSeconds
        {
            OldSeconds = CurrentSeconds
            var Cal = Calendar(identifier: .gregorian)
            Cal.timeZone = TZ!
            let Hour = Cal.component(.hour, from: Now)
            let Minute = Cal.component(.minute, from: Now)
            let Second = Cal.component(.second, from: Now)
            let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
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
        InitializeUI()
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
            
            default:
                (view.window?.windowController as? MainWindow)!.ViewSegment.selectedSegment = 0
        }
        
        MainTimeLabelBottom.wantsLayer = true
        MainTimeLabelBottom.layer?.zPosition = 100000
        MainTimeLabelBottom.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        MainTimeLabelBottom.textColor = NSColor.white
        MainTimeLabelTop.wantsLayer = true
        MainTimeLabelTop.layer?.zPosition = 100000
        MainTimeLabelTop.font = NSFont.monospacedSystemFont(ofSize: 30.0, weight: .semibold)
        MainTimeLabelTop.textColor = NSColor.white
        
        FlatViewMainImage.wantsLayer = true
    }
    
    // MARK: - Menu/toolbar event handlers.
    
    @IBAction func FileSnapshot(_ sender: Any)
    {
    }
    
    @IBAction func FileMapManager(_ sender: Any)
    {
    }
    
    @IBAction func ViewHoursHideAll(_ sender: Any)
    {
    }
    
    @IBAction func ViewHoursNoonCentered(_ sender: Any)
    {
    }
    
    @IBAction func ViewHoursNoonDelta(_ sender: Any)
    {
    }
    
    @IBAction func ViewHoursLocationRelative(_ sender: Any)
    {
    }
    
    @IBAction func ViewTypeNorthCentered(_ sender: Any)
    {
        Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        print("selected north centered")
    }
    
    @IBAction func ViewTypeSouthCentered(_ sender: Any)
    {
        Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        print("selected south centered")
    }
    
    @IBAction func ViewTypeGlobal(_ sender: Any)
    {
        Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
        print("selected global centered")
    }
    
    @IBAction func ViewSelectMap(_ sender: Any)
    {
        
        let Storyboard = NSStoryboard(name: "MapSelector", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "MapPickerWindow") as? MapPickerWindow
        {
            let MapSelector = WindowController.window
            self.view.window?.beginSheet(MapSelector!, completionHandler: nil)
            SelectMapWindow = WindowController
        }
    }
    
    var SelectMapWindow: MapPickerWindow? = nil
    
    @IBAction func HelpAbout(_ sender: Any)
    {
        print("At help about")
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
        //print("Resized to \(To)")
        Show2DHours()
    }
    
    // MARK: - Protocol-required functions
    
    // MARK: - MainProtocol required functions.
    
    func Refresh(_ From: String)
    {
        
    }
    
    // MARK: - Settings changed required functions.
    
    /// ID of this class in relation to the settings changed protocol.
    func SubscriberID() -> UUID
    {
        return UUID(uuidString: "66629111-b430-4231-af5a-e39f35ae7883")!
    }
    
    /// Handle changed settings. Settings may be changed from anywhere at any time.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before the change.
    /// - Parameter NewValue: The new value of the setting.
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .MapType:
                if let New = NewValue as? MapTypes
                {
                    print("New map selected: \(New.rawValue)")
            }
            
            case .ViewType:
                if let New = NewValue as? ViewTypes
                {
                    if New == .CubicWorld
                    {
                        return
                    }
                    var IsFlat = false
                    if New == .FlatNorthCenter || New == .FlatSouthCenter
                    {
                        IsFlat = true
                    }
                    SetFlatlandVisibility(FlatIsVisible: IsFlat)
            }
            
            case .ShowNight:
                break
            
            case .HourType:
                if let NewHourType = NewValue as? HourValueTypes
                {
                    switch NewHourType
                    {
                        case .None:
                            break
                        
                        case .RelativeToLocation:
                            break
                        
                        case .RelativeToNoon:
                            break
                        
                        case .Solar:
                            break
                    }
            }
            
            case .TimeLabel:
                break
            
            default:
                break
        }
    }
    
    // MARK: - City variables.
    
    var CityTestList = [City]()
    let CityList = Cities()
    
    // MARK: - Variables for extensions.
    
    var UnescoURL: URL? = nil
    static var UnescoInitialized = false
    static var UnescoHandle: OpaquePointer? = nil
    var WorldHeritageSites: [WorldHeritageSite]? = nil
    
    /// Previous percent drawn. Used to prevent constant updates when an update would not result
    /// in a visual change.
    var PreviousPercent: Double = -1.0
    
    let HalfCircumference: Double = 40075.0 / 2.0
    
    var CityLayer: CAShapeLayer? = nil
    
    // MARK: - Interface builder outlets.
    
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
    @IBOutlet weak var GlobeView: SCNView!
}

