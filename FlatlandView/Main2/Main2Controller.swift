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
        
        //https://stackoverflow.com/questions/31931403/getting-mouse-coordinates-in-swift
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved])
        {
            if self.Location.x >= 0 && self.Location.x < self.view.window!.frame.size.width
            {
                if self.Location.y >= 0 && self.Location.y < self.view.window!.frame.size.height
                {
                    self.Main2DView.MouseAt(Point: CGPoint(x: self.Location.x, y: self.Location.y))
                    self.Main3DView.MouseAt(Point: CGPoint(x: self.Location.x, y: self.Location.y))
                }
            }
            return $0
        }
    }
    
    var Location: NSPoint {self.view.window!.mouseLocationOutsideOfEventStream}
    
    var StenciledImage: NSImage? = nil
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        self.view.window!.acceptsMouseMovedEvents = true
    }
    
    /// Initialize things that require a fully set-up window.
    override func viewDidLayout()
    {
        InterfaceInitialization()
        InitializeFlatland()
        NotificationCenter.default.addObserver(self, selector: #selector(HandlePrimaryViewContentsSizeChange),
                                               name: NSView.frameDidChangeNotification, object: PrimaryView)
        if !InitialWindowPositionSet
        {
            InitialWindowPositionSet = true
            let MainWindow = self.view.window
            if let UpperLeft = Settings.GetCGPoint(.WindowOrigin)
            {
                MainWindow?.setFrameTopLeftPoint(UpperLeft)
                print("Starting window point: \(UpperLeft)")
            }
            if let ContentsSize = Settings.GetNSSize(.PrimaryViewSize)
            {
                print("ContentsSize=\(ContentsSize)")
                //MainWindow?.setContentSize(ContentsSize)
            }
        }
    }
    
    @objc func HandlePrimaryViewContentsSizeChange(_ notification: Notification)
    {
        if let ChangedView = notification.object as? ParentView
        {
            print("Parent content view frame: \(ChangedView.frame)")
            Settings.SetNSSize(.PrimaryViewSize, NSSize(width: ChangedView.frame.size.width,
                                                        height: ChangedView.frame.size.height))
        }
    }
    
    var InitialWindowPositionSet = false
    
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
    
    @IBAction func ShowItemViewer(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "ItemViewer", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ItemViewer") as? ItemViewerWindow
        {
            let ItemWindow = WindowController.window
            let Controller = ItemWindow?.contentViewController as? ItemViewerController
            Controller?.MainDelegate = self
            ItemViewerDelegate = Controller
            ItemViewerWindowDelegate = Controller
            WindowController.showWindow(nil)
        }
    }
    
    var ItemViewerDelegate: ItemViewerProtocol? = nil
    var ItemViewerWindowDelegate: WindowManagement? = nil
    
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
            if let SomeController = Window?.contentViewController as? AboutController
            {
                AControl = SomeController
            }
            if let AlreadyStenciled = StenciledImage
            {
                AControl?.ForceMap(AlreadyStenciled)
            }
            self.view.window?.beginSheet(Window!)
            {
                _ in
                self.AboutDelegate = nil
                self.AControl = nil
            }
        }
    }
    
    var AControl: AboutController? = nil
    
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
        Main2DView.ResetCamera()
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
        if let Image = Utility.GetNightMask(ForDate: Date())
        {
            Main2DView.AddNightMask(Image)
        }
        else
        {
            print("No night mask for \(Date()) found.")
        }
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
    
    /// Set flat mode. This will switch views if necessary.
    /// - Parameter IsFlat: If true, flat mode will be turned on. If false, 3D mode will be turned on.
    func SetFlatMode(_ IsFlat: Bool)
    {
        if IsFlat
        {
            Main2DView.isHidden = false
            Main3DView.isHidden = true
            switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
            {
                case .FlatSouthCenter:
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    Main2DView.MoveSun(ToNorth: true)
                    
                case .FlatNorthCenter:
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    Main2DView.MoveSun(ToNorth: false)
                    
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
    var UnescoURL: URL? = nil
    static var UnescoInitialized = false
    static var UnescoHandle: OpaquePointer? = nil
    var WorldHeritageSites: [WorldHeritageSite]? = nil
    
    // MARK: - Storyboard outlets
    
    @IBOutlet var PrimaryView: ParentView!
    @IBOutlet weak var Main2DView: FlatView!
    @IBOutlet var Main3DView: GlobeView!
    @IBOutlet weak var MainTimeLabelTop: NSTextField!
    @IBOutlet weak var MainTimeLabelBottom: NSTextField!
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
