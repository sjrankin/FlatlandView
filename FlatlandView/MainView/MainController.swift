//
//  MainController.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Controller for the view for the main window in Flatland.
class MainController: NSViewController
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
        
       MonitorMouse()
    }
    
    /// Set up event handling so we can monitor the mouse. This is used to notify the user when the mouse
    /// is over a location that has data.
    /// - Note: Mouse location handling is done in the 2D and 3D view controllers (see `Main2DView` and
    ///         `Main3DView`).
    /// - Note: See [Getting Mouse Coordinates in Swift](https://stackoverflow.com/questions/31931403/getting-mouse-coordinates-in-swift)
    func MonitorMouse()
    {
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
    
    /// Holds the location of the mouse pointer in the window.
    var Location: NSPoint {self.view.window!.mouseLocationOutsideOfEventStream}
    
    /// Holds the most recent stenciled image.
    var StenciledImage: NSImage? = nil
    
    /// Handle the view will appear event.
    override func viewWillAppear()
    {
        super.viewWillAppear()
        self.view.window!.acceptsMouseMovedEvents = true
        //POIView.isHidden = true
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
    
    /// Handle content view size changed events.
    /// - Parameter notification: The event notification.
    @objc func HandlePrimaryViewContentsSizeChange(_ notification: Notification)
    {
        if let ChangedView = notification.object as? ParentView
        {
            print("Parent content view frame: \(ChangedView.frame)")
            Settings.SetNSSize(.PrimaryViewSize, NSSize(width: ChangedView.frame.size.width,
                                                        height: ChangedView.frame.size.height))
        }
    }
    
    /// Initial window position set flag.
    var InitialWindowPositionSet = false
    
    /// Called when a stenciling operation has completed.
    func DoneWithStenciling()
    {
        Debug.Print("Stenciling completed.")
    }
    
    /// Main settings delegate. Used for communication and closing when the main window closes.
    var MainSettingsDelegate: WindowManagement? = nil
    /// About delegate. Used for communication and closing when the main window closes.
    var AboutDelegate: WindowManagement? = nil
    /// Update timer.
    var UpdateTimer: Timer? = nil
    /// Program started flag.
    var Started = false
    
    #if DEBUG
    /// Time stamp for when the program started.
    var StartDebugCount: Double = 0.0
    /// Number of seconds running in the current instantiation.
    var UptimeSeconds: Int = 0
    #endif
    /// Previous second count.
    var OldSeconds: Double = 0.0
    
    // MARK: Menu and toolbar event handlers
    
    /// Respond to the user command to run settings.
    /// - Parameter sender: Not used.
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
    
    /// Respond to the user command to show or hide item data.
    /// - Parameter sender: Not used.
    @IBAction func ShowItemViewer(_ sender: Any)
    {
        let NewShow = Settings.InvertBool(.ShowDetailedInformation, SendNotification: false)
        POIView.isHidden = !NewShow
        if let Window = self.view.window?.windowController as? MainWindow
        {
            let NewImageName = NewShow ? "BinocularsIconShowing" : "Binoculars"
            Window.ChangeShowInfoImage(To: NSImage(named: NewImageName)!)
        }
    }
    
    /// Respond to the user command to take a snapshot of the current view.
    /// - Parameter sender: Not used.
    @IBAction func TakeSnapShot(_ sender: Any)
    {
        CreateClientSnapshot()
    }
    
    /// Respond to the user command to show the about dialog.
    /// - Parameter sender: Not used.
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
    
    /// Reference to the about dialog.
    var AControl: AboutController? = nil
    
    /// Respond to the user command to show current time events.
    /// - Parameter sender: Not used.
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
    
    /// Reference to the today viewer. Used to close the viewer if the main window is closed first.
    var TodayDelegate: WindowManagement? = nil
    
    /// Respond to the user command to show the list of earthquakes.
    /// - Parameter sender: Not used.
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
    
    /// Array of previous earthquakes (used in a cache-like fasion).
    var PreviousEarthquakes = [Earthquake]()
    
    /// Respond to the user command to reset the view. Works with both 2D and 3D views.
    /// - Parameter sender: Not used.
    @IBAction func Reset3DView(_ sender: Any)
    {
        Main3DView.ResetCamera()
        Main2DView.ResetCamera()
    }
    
    /// Set the night mask for the day.
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
    
    /// Resond to the user command to show the flat map in north-centered mode.
    /// - Parameter sender: Not used.
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
    
    /// Resond to the user command to show the flat map in south-centered mode.
    /// - Parameter sender: Not used.
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
    
    /// Respond to the user command to show the map in 3D globe mode.
    /// - Parameter sender: Not used.
    @IBAction func ViewTypeGlobal(_ sender: Any)
    {
        Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
    }
    
    /// Respond to the user command to show the map in 3D cubic mode.
    /// - Parameter sender: Not used.
    @IBAction func ViewTypeCubic(_ sender: Any)
    {
        Settings.SetEnum(.CubicWorld, EnumType: ViewTypes.self, ForKey: .ViewType)
    }
    
    /// Respond to the user command to hide all of the hour digits.
    /// Parameter sender: Not used.
    @IBAction func ViewHoursHideAll(_ sender: Any)
    {
        Settings.SetEnum(.None, EnumType: HourValueTypes.self, ForKey: .HourType)
    }
    
    /// Respond to the user command to show hours as noon-centered.
    /// Parameter sender: Not used.
    @IBAction func ViewHoursNoonCentered(_ sender: Any)
    {
        Settings.SetEnum(.Solar, EnumType: HourValueTypes.self, ForKey: .HourType)
    }
    
    /// Respond to the user command to show hours as noon-delta.
    /// Parameter sender: Not used.
    @IBAction func ViewHoursNoonDelta(_ sender: Any)
    {
        Settings.SetEnum(.RelativeToNoon, EnumType: HourValueTypes.self, ForKey: .HourType)
    }
    
    /// Respond to the user command to show hours as location-delta.
    /// Parameter sender: Not used.
    @IBAction func ViewHoursLocationRelative(_ sender: Any)
    {
        if Settings.HaveLocalLocation()
        {
            Settings.SetEnum(.RelativeToLocation, EnumType: HourValueTypes.self, ForKey: .HourType)
        }
    }
    
    /// Respond to the user command to change how hours are displayed.
    /// - Parameter sender: Not used.
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
    
    /// Respond to the user command to change the map type.
    /// - Parameter sender: Not used.
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
    
    /// Not currently implemented.
    @IBAction func DebugShow(_ sender: Any)
    {
    }
    
    /// Initialize the settings to factory values.
    /// - Note: Intended for debug use only.
    /// - Parameter sender: Not used.
    @IBAction func DebugResetSettings(_ sender: Any)
    {
        Settings.Initialize(true)
    }
    
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
            Main2DView.SunVisibility(IsShowing: true)
            SetNightMask()
        }
        else
        {
            Main2DView.SunVisibility(IsShowing: false)
            Main2DView.isHidden = true
            Main3DView.isHidden = false
        }
    }
    
    // MARK: - Extension variables
    
    /// ID used for settings subscriptions.
    var ClassID = UUID()
    /// Earthquake source (asynchronous data from the USGS).
    var Earthquakes: USGS? = nil
    /// Primary map list.
    var PrimaryMapList: ActualMapList? = nil
    /// The latest earthquakes from the USGS.
    var LatestEarthquakes = [Earthquake]()
    /// Location of the mappable database.
    var MappableURL: URL? = nil
    /// Flag that indicates whether the mappable database was initialized or not.
    static var MappableInitialized = false
    /// Handle to the mappable database.
    static var MappableHandle: OpaquePointer? = nil
    /// Array of World Heritage Sites.
    var WorldHeritageSites: [WorldHeritageSite2]? = nil
    
    // MARK: - Storyboard outlets
    
    @IBOutlet var PrimaryView: ParentView!
    @IBOutlet weak var Main2DView: FlatView!
    @IBOutlet var Main3DView: GlobeView!
    @IBOutlet weak var MainTimeLabelTop: NSTextField!
    @IBOutlet weak var MainTimeLabelBottom: NSTextField!
    @IBOutlet weak var BackgroundView: NSView!
    // Item view elements
    @IBOutlet weak var POIView: NSView!
    @IBOutlet weak var DescriptionValue: NSTextField!
    @IBOutlet weak var LocationValue: NSTextField!
    @IBOutlet weak var LocationLabel: NSTextField!
    @IBOutlet weak var NumericValue: NSTextField!
    @IBOutlet weak var NumericLabel: NSTextField!
    @IBOutlet weak var NameValue: NSTextField!
    @IBOutlet weak var NameLabel: NSTextField!
    @IBOutlet weak var TypeValue: NSTextField!
    @IBOutlet weak var TypeLabel: NSTextField!
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
