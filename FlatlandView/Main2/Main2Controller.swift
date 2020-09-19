//
//  Main2Controller.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Main2Controller: NSViewController
{
    /// Initialize the main window and program.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.Initialize()
        Settings.AddSubscriber(self)
        
        InitializationFromEnvironment()
        ProgramInitialization()
        AsynchronousInitialization()
        
        #if DEBUG
        VersionValue.stringValue = Versioning.VerySimpleVersionString()
        BuildValue.stringValue = "\(Versioning.Build)"
        BuildDateValue.stringValue = Versioning.BuildDate
        #else
        DebugTextGrid.removeFromSuperview()
        #endif
        
        let ATran = AdjustTransparency()
        let TestImage = GetNightMask(ForDate: Date())
        let Fixed = ATran.Adjust(Source: TestImage!, Threshold: 0.5)
        
        /*
        let GMake = MetalGradient()
        let Color1 = NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let Color2 = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let NewColor = NSColor.BlendColors(Color1: Color1, Color2: Color2, Percent: 0.25)
        
        let Test1 = GMake.CreateHorizontal(Size: NSSize(width: 200, height: 200), Colors: [NSColor.yellow],
                                             Locations: [CGPoint(x: 1.0, y: 0.5)])
        let Test1a = GMake.CreateHorizontal(Size: NSSize(width: 200, height: 200), Colors: [NSColor.yellow],
                                           Locations: [CGPoint(x: 1.0, y: 0.25)])
        let Test1b = GMake.CreateHorizontal(Size: NSSize(width: 400, height: 400),
                                            Colors: [NSColor.systemGreen],
                                            TerminalColors: [NSColor.systemTeal],
                                            Locations: [CGPoint(x: 1.0, y: 0.33)])
        let Test2 = GMake.CreateVertical(Size: NSSize(width: 200, height: 200), Colors: [NSColor.systemYellow],
                                         Locations: [CGPoint(x: 0.25, y: 1.0)])
        let Test3 = GMake.CreateRadial(Size: NSSize(width: 200, height: 200), Colors: [NSColor.white],
                                       TerminalColors: [NSColor.red],
                                       Locations: [CGPoint(x: 0.5, y: 0.5)])
        print("Gradients created.")
 */
    }
    
    /// Initialize things that require a fully set-up window.
    override func viewDidLayout()
    {
        InterfaceInitialization()
        InitializeFlatland()
    }
    
    func DoneWithStenciling()
    {
        Debug.Print("Stenciling completed.")
    }
    
    var MainSettingsDelegate: WindowManagement? = nil
    var AboutDelegate: WindowManagement? = nil
    
    var UpdateTimer: Timer? = nil
    var Started = false
    
    #if DEBUG
    var StartDebugCount: Double = 0.0
    var UptimeSeconds: Int = 0
    #endif
    
    var OldSeconds: Double = 0.0
    
    // MARK: Menu and toolbar event handlers
    
    @IBAction func RunSettings(_ sender: Any)
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
    
    @IBAction func TakeSnapShot(_ sender: Any)
    {
        CreateClientSnapshot()
    }
    
    @IBAction func ShowAbout(_ sender: Any)
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
    
    var PreviousEarthquakes = [Earthquake]()
    
    @IBAction func Reset3DView(_ sender: Any)
    {
        Main3DView.ResetCamera()
    }
    
    func SetNightMask()
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.FlatSouthCenter) == .Globe3D
        {
            return
        }

        if !Settings.GetBool(.ShowNight)
        {
            Main2DView.HideNightMask()
            return
        }
        if let Image = GetNightMask(ForDate: Date())
        {
            Main2DView.AddNightMask(Image)
        }
        else
        {
            print("No night mask for \(Date()) found.")
        }
    }
    
    /// Given a date, return a mask image for a flat map.
    /// - Parameter From: The date for the night mask.
    /// - Returns: Name of the night mask image file.
    func MakeNightMaskName(From: Date) -> String
    {
        let Day = Calendar.current.component(.day, from: From)
        let Month = Calendar.current.component(.month, from: From) - 1
        let MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month]
        var Prefix = ""
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
        {
            Prefix = ""
        }
        else
        {
            Prefix = "South_"
        }
        return "\(Prefix)\(Day)_\(MonthName)"
    }
    
    /// Get a night mask image for a flat map for the specified date.
    /// - Parameter ForDate: The date of the night mask.
    /// - Returns: Image for the passed date (and flat map orientation). Nil returned on error.
    func GetNightMask(ForDate: Date) -> NSImage?
    {
        let AlphaLevels: [NightDarknesses: CGFloat] =
            [
                .VeryLight: 0.25,
                .Light: 0.4,
                .Dark: 0.6,
                .VeryDark: 0.75
            ]
        let ImageName = MakeNightMaskName(From: ForDate)
        let DarkLevel = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Light)
        let MaskAlpha = AlphaLevels[DarkLevel]!
        let MaskImage = NSImage(named: ImageName)!
        let Final = MaskImage.Alpha(CGFloat(MaskAlpha))
        return Final
    }
    
    @IBAction func ViewTypeNorthCentered(_ sender: Any)
    {
        Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)
        {
            Main2DView.SetEarthMap(MapImage)
        }
        else
        {
            Debug.Print("Error getting image for north centered: \(MapValue)")
        }
    }
    
    @IBAction func ViewTypeSouthCentered(_ sender: Any)
    {
        Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatSouthCenter)
        {
        Main2DView.SetEarthMap(MapImage)
        }
        else
        {
            Debug.Print("Error getting image for south centered: \(MapValue)")
        }
    }
    
    @IBAction func ViewTypeGlobal(_ sender: Any)
    {
        Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
    }
    
    @IBAction func ViewTypeCubic(_ sender: Any)
    {
        Settings.SetEnum(.CubicWorld, EnumType: ViewTypes.self, ForKey: .ViewType)
    }
    
    @IBAction func ViewHoursHideAll(_ sender: Any)
    {
        Settings.SetEnum(.None, EnumType: HourValueTypes.self, ForKey: .HourType)
    }
    
    @IBAction func ViewHoursNoonCentered(_ sender: Any)
    {
        Settings.SetEnum(.Solar, EnumType: HourValueTypes.self, ForKey: .HourType)
    }
    
    @IBAction func ViewHoursNoonDelta(_ sender: Any)
    {
        Settings.SetEnum(.RelativeToNoon, EnumType: HourValueTypes.self, ForKey: .HourType)
    }
    
    @IBAction func ViewHoursLocationRelative(_ sender: Any)
    {
        if Settings.HaveLocalLocation()
        {
            Settings.SetEnum(.RelativeToLocation, EnumType: HourValueTypes.self, ForKey: .HourType)
        }
    }
    
    @IBAction func HandleHourTypeChange(_ sender: Any)
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
    
    @IBAction func HandleViewTypeChange(_ sender: Any)
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
    
    @IBAction func DebugShow(_ sender: Any)
    {
    }
    
    @IBAction func DebugResetSettings(_ sender: Any)
    {
        Settings.Initialize(true)
    }
    
    var PreviousSunType = SunNames.PlaceHolder
    
    
    func SetFlatMode(_ IsFlat: Bool)
    {
        if IsFlat
        {
            Main2DView.isHidden = false
            Main3DView.isHidden = true
            switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
            {
                case .FlatSouthCenter:
                    SunViewTop.isHidden = false
                    SunViewBottom.isHidden = true
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    
                case .FlatNorthCenter:
                    SunViewTop.isHidden = true
                    SunViewBottom.isHidden = false
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    
                default:
                    break
            }
            Main2DView.UpdateHours()
            SetNightMask()
        }
        else
        {
            Main2DView.isHidden = true
            Main3DView.isHidden = false
        }
    }
    
    // MARK: - Extension variables
    
    var ClassID = UUID()
    var Earthquakes: USGS? = nil
    var PrimaryMapList: ActualMapList? = nil
    var LatestEarthquakes = [Earthquake]()
    var CityTestList = [City]()
    let CityList = Cities()
    
    // MARK: - Storyboard outlets
    
    @IBOutlet var PrimaryView: NSView!
    @IBOutlet weak var Main2DView: FlatView!
    @IBOutlet var Main3DView: GlobeView!
    @IBOutlet weak var MainTimeLabelTop: NSTextField!
    @IBOutlet weak var MainTimeLabelBottom: NSTextField!
    @IBOutlet weak var SunViewTop: NSImageView!
    @IBOutlet weak var SunViewBottom: NSImageView!
    @IBOutlet weak var BackgroundView: NSView!
    //Debug elements
    @IBOutlet weak var VersionLabel: NSTextField!
    @IBOutlet weak var VersionValue: NSTextField!
    @IBOutlet weak var BuildLabel: NSTextField!
    @IBOutlet weak var BuildValue: NSTextField!
    @IBOutlet weak var BuildDateLabel: NSTextField!
    @IBOutlet weak var BuildDateValue: NSTextField!
    @IBOutlet weak var DebugTextGrid: NSGridView!
    @IBOutlet weak var UptimeLabel: NSTextFieldCell!
    @IBOutlet weak var UptimeValue: NSTextField!
}
