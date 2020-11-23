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
    public static var StartTime: Double = 0.0
    
    /// Initialize the main window and program.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MainController.StartTime = CACurrentMediaTime()
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
    /// - Note: Mouse location handling is done in the 2D and 3D view controllers (see `Main2DView`,
    ///         `Main3DView` and `Rect2DView`).
    /// - Note: See [Getting Mouse Coordinates in Swift](https://stackoverflow.com/questions/31931403/getting-mouse-coordinates-in-swift)
    func MonitorMouse()
    {
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp])
        {
            if self.Location.x >= 0 && self.Location.x < self.view.window!.frame.size.width
            {
                if self.Location.y >= 0 && self.Location.y < self.view.window!.frame.size.height
                {
                    let Point = CGPoint(x: self.Location.x, y: self.Location.y)
                    self.Rect2DView.MouseAt(Point: Point)
                    self.Main2DView.MouseAt(Point: Point)
                    self.Main3DView.MouseAt(Point: Point)
                }
            }
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved])
        {
            if self.Location.x >= 0 && self.Location.x < self.view.window!.frame.size.width
            {
                if self.Location.y >= 0 && self.Location.y < self.view.window!.frame.size.height
                {
                    let Point = CGPoint(x: self.Location.x, y: self.Location.y)
                    self.Main3DView.MouseMovedTo(Point: Point)
                    self.Main2DView.MouseMovedTo(Point: Point)
                    self.Rect2DView.MouseMovedTo(Point: Point)
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
                Debug.Print("Starting window point: \(UpperLeft)")
            }
            if let ContentsSize = Settings.GetNSSize(.PrimaryViewSize)
            {
                Debug.Print("ContentsSize=\(ContentsSize)")
                //MainWindow?.setContentSize(ContentsSize)
            }
        }
        
        if let AD = NSApplication.shared.delegate as? AppDelegate
        {
            MainApp = AD
            if MainApp == nil
            {
                Debug.Print("MainApp is nil")
            }
        }
        else
        {
            fatalError("Unable to get app delegate: \(#function)")
        }
        
        SetWorldLock(Settings.GetBool(.WorldIsLocked))
        SetMouseLocationVisibility(Visible: Settings.GetBool(.FollowMouse))
        
        //Make sure the proper segments in the toolbar segment controls are highlighted - macOS 11 does not
        //highlight selected segments with sufficient contrast so we have to do it ourself.
        if let WinCtrl = self.view.window?.windowController as? MainWindow
        {
            WinCtrl.ViewSegment.setImage(NSImage(named: "NorthCenterIcon"), forSegment: 0)
            WinCtrl.ViewSegment.setImage(NSImage(named: "SouthCenterIcon"), forSegment: 1)
            WinCtrl.ViewSegment.setImage(NSImage(named: "GlobeIcon"), forSegment: 2)
            WinCtrl.ViewSegment.setImage(NSImage(named: "RectangleIcon"), forSegment: 3)
            WinCtrl.ViewSegment.setImage(NSImage(named: "CubeIcon"), forSegment: 4)
            switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
            {
                case .CubicWorld:
                    WinCtrl.ViewSegment.setImage(NSImage(named: "CubeIconSelected"), forSegment: 4)
                    
                case .FlatNorthCenter:
                    WinCtrl.ViewSegment.setImage(NSImage(named: "NorthCenterIconSelected"), forSegment: 0)
                    
                case .FlatSouthCenter:
                    WinCtrl.ViewSegment.setImage(NSImage(named: "SouthCenterIconSelected"), forSegment: 1)
                    
                case .Globe3D:
                    WinCtrl.ViewSegment.setImage(NSImage(named: "GlobeIconSelected"), forSegment: 2)
                    
                case .Rectangular:
                    WinCtrl.ViewSegment.setImage(NSImage(named: "RectangleIconSelected"), forSegment: 3)
                    
            }
            
            WinCtrl.HourSegment.setImage(NSImage(named: "CircleIcon"), forSegment: 0)
            WinCtrl.HourSegment.setImage(NSImage(named: "ClockIcon"), forSegment: 1)
            WinCtrl.HourSegment.setImage(NSImage(named: "DeltaIcon"), forSegment: 2)
            WinCtrl.HourSegment.setImage(NSImage(named: "PinIcon"), forSegment: 3)
            switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .Solar)
            {
                case .None:
                    WinCtrl.HourSegment.setImage(NSImage(named: "CircleIconSelected"), forSegment: 0)
                    
                case .RelativeToLocation:
                    WinCtrl.HourSegment.setImage(NSImage(named: "PinIconSelected"), forSegment: 3)
                    
                case .RelativeToNoon:
                    WinCtrl.HourSegment.setImage(NSImage(named: "DeltaIconSelected"), forSegment: 2)
                    
                case .Solar:
                    WinCtrl.HourSegment.setImage(NSImage(named: "ClockIconSelected"), forSegment: 1)
            }
        }
    }
    
    public var MainApp: AppDelegate!
    
    /// Handle content view size changed events.
    /// - Parameter notification: The event notification.
    @objc func HandlePrimaryViewContentsSizeChange(_ notification: Notification)
    {
        if let ChangedView = notification.object as? ParentView
        {
            //print("Parent content view frame: \(ChangedView.frame)")
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
    /// Debugger window delegate.
    var DebugDelegate: WindowManagement? = nil
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
    /// - Note: If the settings window is already open, it will not open a second instance but return immediately.
    /// - Parameter sender: Not used.
    @IBAction func RunSettings(_ sender: Any)
    {
        if SettingsWindowOpen
        {
            return
        }
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "MainSettingsWindow") as? MainSettingsWindowsCode
        {
            let SettingWindow = WindowController.window
            let Controller = SettingWindow?.contentViewController as? MainSettingsBase
            Controller?.MainDelegate = self
            MainSettingsDelegate = Controller
            Controller?.LoadData(DataType: .Earthquakes, Raw: LatestEarthquakes as Any)
            WindowController.showWindow(nil)
            SettingsWindowOpen = true
        }
    }
    
    // Flag used to determine if the settings window is open.
    var SettingsWindowOpen = false
    
    @IBAction func RunPreferences(_ sender: Any)
    {
        if PreferencesWindowOpen
        {
            return
        }
        let Storyboard = NSStoryboard(name: "PreferencePanel", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "PreferencePanelWindow") as? PreferencePanelWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? PreferencePanelController
            Controller?.MainDelegate = self
            MainSettingsDelegate = Controller
            WindowController.showWindow(nil)
            PreferencesWindowOpen = true
        }
    }
    
    var PreferencesWindowOpen = false
    
    @IBAction func RunDebugger(_ sender: Any)
    {
        if DebuggerOpen
        {
            return
        }
        let Storyboard = NSStoryboard(name: "Debug", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "DebuggerWindow") as? DebuggerWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? DebuggerController
            Controller?.MainDelegate = self
            DebugDelegate = Controller
            WindowController.showWindow(nil)
            DebuggerOpen = false
        }
    }
    
    var DebuggerOpen = false
    
    /// Set the world lock status. This stops the user from moving the camera in all scenes.
    /// - Note: Prior to locking the scene, the camera is moved back to its default position.
    /// - Parameter Locked: If true, all scenes in 3D views are reset then locked. If false, the camera
    ///                     is allowed to be moved and no other action is taken.
    func SetWorldLock(_ Locked: Bool)
    {
        if let WindowController = self.view.window?.windowController as? MainWindow
        {
            WindowController.WorldLockButton.toolTip = Locked ? "Currently locked: Click to unlock world scenes" :
                                                                "Currently unlocked: Click to reset then lock world scenes"
            WindowController.WorldLockButton.image = Locked ? NSImage(named: "LockWorldIcon") : NSImage(named: "UnlockWorldIcon")
            let LockMenu = GetAppDelegate().LockUnlockMenuItem
            LockMenu?.state = Locked ? .off : .on
            Main3DView.SetCameraLock(Locked)
            Main2DView.SetCameraLock(Locked)
            Rect2DView.SetCameraLock(Locked)
        }
    }
    
    /// Responds to the lock/unlock world button and menu item.
    /// - Parameter sender: Not used.
    @IBAction func HandleLockUnlockWorldButton(_ sender: Any)
    {
        SetWorldLock(Settings.InvertBool(.WorldIsLocked))
    }
    
    /// Respond to the user command to take a snapshot of the current view.
    /// - Parameter sender: Not used.
    @IBAction func TakeSnapShot(_ sender: Any)
    {
        Snapshot.Take(From: PrimaryView, WindowID: WindowID(), Frame: view.window!.frame)
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
    
    #if false
    /// Respond to the user command to show the list of earthquakes.
    /// - Parameter sender: Not used.
    @IBAction func ShowEarthquakeListX(_ sender: Any)
    {
        #if false
        let Storyboard = NSStoryboard(name: "LiveData", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeWindow2") as? GroupedEarthquakeWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? GroupedEarthquakeController
            QuakeDelegate = Window?.contentView as? WindowManagement
            QuakeController = Controller
            Controller?.LoadData(DataType: .Earthquakes, Raw: PreviousEarthquakes as Any)
            WindowController.showWindow(nil)
        }
        #endif
    }
    #endif
    
    var QuakeController: EarthquakeViewerController? = nil
    var QuakeDelegate: WindowManagement? = nil
    
    @IBAction func ShowEarthquakeList(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "EarthquakeData", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeViewerWindow3") as? EarthquakeViewerWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? EarthquakeViewerController
            QuakeDelegate = Window?.contentView as? WindowManagement
            Controller?.MainDelegate = self
            QuakeController = Controller
            WindowController.showWindow(nil)
            Controller?.LoadData(DataType: .Earthquakes, Raw: PreviousEarthquakes as Any)
        }
    }
    
    /// Refresh earthquakes even if it's earlier than scheduled.
    @IBAction func RefreshEarthquakes(_ sender: Any)
    {
        Earthquakes?.GetNewEarthquakeData()
    }
    
    @IBAction func RunTestDialog(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "RoundTextTest", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "RoundTextTest") as? RoundTextTestWindow
        {
            //let Window = WindowController.window
            //let Controller = Window?.contentViewController as? RoundTextTestController
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
        Rect2DView.ResetCamera()
    }
    
    /// Set the night mask for the day.
    func SetNightMask()
    {
        if !Settings.GetBool(.ShowNight)
        {
            Main2DView.HideNightMask()
            Rect2DView.HideNightMask()
            return
        }
        let TheView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.FlatSouthCenter)
        switch TheView
        {
            case .FlatNorthCenter, .FlatSouthCenter:
                Main2DView.HideNightMask()
                if let Image = Utility.GetNightMask(ForDate: Date())
                {
                    Main2DView.AddNightMask(Image)
                }
                else
                {
                    print("No night mask for \(Date()) found.")
                }
                
            case .Rectangular:
                #if false
                Rect2DView.HideNightMask()
                if let Image = Utility.GetRectangularNightMask(ForDate: Date())
                {
                    Rect2DView.AddNightMask(Image)
                }
                else
                {
                    print("No rectangular night mask for \(Date()) found.")
                }
                #endif
                break
                
            default:
                return
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
    
    /// Resond to the user command to show the flat map in rectangular mode.
    /// - Parameter sender: Not used.
    @IBAction func ViewTypeRectangular(_ sender: Any)
    {
        Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
        let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .Rectangular)
        {
            Rect2DView.SetEarthMap(MapImage)
        }
        else
        {
            Debug.Print("Error getting image for north centered: \(MapValue)")
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
            Segment.setImage(NSImage(named: "CircleIcon"), forSegment: 0)
            Segment.setImage(NSImage(named: "ClockIcon"), forSegment: 1)
            Segment.setImage(NSImage(named: "DeltaIcon"), forSegment: 2)
            Segment.setImage(NSImage(named: "PinIcon"), forSegment: 3)
            switch Segment.selectedSegment
            {
                case 0:
                    ViewHoursHideAll(sender)
                    Segment.setImage(NSImage(named: "CircleIconSelected"), forSegment: 0)
                    
                case 1:
                    ViewHoursNoonCentered(sender)
                    Segment.setImage(NSImage(named: "ClockIconSelected"), forSegment: 1)
                    
                case 2:
                    ViewHoursNoonDelta(sender)
                    Segment.setImage(NSImage(named: "DeltaIconSelected"), forSegment: 2)
                    
                case 3:
                    ViewHoursLocationRelative(sender)
                    Segment.setImage(NSImage(named: "PinIconSelected"), forSegment: 3)
                    
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
            Segment.setImage(NSImage(named: "NorthCenterIcon"), forSegment: 0)
            Segment.setImage(NSImage(named: "SouthCenterIcon"), forSegment: 1)
            Segment.setImage(NSImage(named: "GlobeIcon"), forSegment: 2)
            Segment.setImage(NSImage(named: "RectangleIcon"), forSegment: 3)
            Segment.setImage(NSImage(named: "CubeIcon"), forSegment: 4)
            switch Segment.selectedSegment
            {
                case 0:
                    ViewTypeNorthCentered(sender)
                    Segment.setImage(NSImage(named: "NorthCenterIconSelected"), forSegment: 0)
                    
                case 1:
                    ViewTypeSouthCentered(sender)
                    Segment.setImage(NSImage(named: "SouthCenterIconSelected"), forSegment: 1)
                    
                case 2:
                    ViewTypeGlobal(sender)
                    Segment.setImage(NSImage(named: "GlobeIconSelected"), forSegment: 2)
                    
                case 3:
                    ViewTypeRectangular(sender)
                    Segment.setImage(NSImage(named: "RectangleIconSelected"), forSegment: 3)
                    
                case 4:
                    ViewTypeCubic(sender)
                    Segment.setImage(NSImage(named: "CubeIconSelected"), forSegment: 4)
                    
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
            Main3DView.isHidden = true
            switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
            {
                case .FlatSouthCenter:
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    Main2DView.isHidden = false
                    Rect2DView.isHidden = true
                    Main2DView.UpdateHours()
                    Main2DView.SunVisibility(IsShowing: true)
                    
                case .FlatNorthCenter:
                    MainTimeLabelTop.isHidden = false
                    MainTimeLabelBottom.isHidden = true
                    Main2DView.isHidden = false
                    Rect2DView.isHidden = true
                    Main2DView.UpdateHours()
                    Main2DView.SunVisibility(IsShowing: true)
                    
                case .Rectangular:
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    Main2DView.isHidden = true
                    Rect2DView.isHidden = false
                    Rect2DView.UpdateHours()
                    //Rect2DView.SunVisibility(IsShowing: true)
                    
                default:
                    break
            }
            SetNightMask()
        }
        else
        {
            Main2DView.SunVisibility(IsShowing: false)
            Main2DView.isHidden = true
            Main3DView.isHidden = false
            Rect2DView.isHidden = true
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
    /// Delegate to communicate with the mouse popover.
    var MouseInfoDelegate: MouseInfoProtocol? = nil
    /// Mouse infor view controller.
    var MouseInfoView: MouseInfoController? = nil

    // MARK: - Database handles/variables
    
    /// Location of the mappable database.
    var MappableURL: URL? = nil
    /// Flag that indicates whether the mappable database was initialized or not.
    static var MappableInitialized = false
    /// Handle to the mappable database.
    static var MappableHandle: OpaquePointer? = nil
    /// Array of World Heritage Sites.
    var WorldHeritageSites: [WorldHeritageSite2]? = nil
    /// Location of the POI database.
    var POIURL: URL? = nil
    /// Flag that indicates whether the POI database was initialized or not.
    static var POIInitialized = false
    /// Handle to the POI database.
    static var POIHandle: OpaquePointer? = nil
    /// User POIs from the POI database.
    static var UserPOIs = [POI2]()
    /// User homes from the POI database.
    static var UserHomes = [POI2]()
    
    // MARK: - Storyboard outlets
    
    @IBOutlet var PrimaryView: ParentView!
    @IBOutlet weak var Main2DView: FlatView!
    @IBOutlet weak var Rect2DView: RectangleView!
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
