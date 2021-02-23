//
//  MainController.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Controller for the view for the main window in Flatland.
class MainController: NSViewController
{
    /// Initialize the main window and program.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MainController.StartTime = CACurrentMediaTime()
        Settings.Initialize()
        Settings.AddSubscriber(self)
        CityManager.Initialize()
        
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
        Internet.IsAvailable
        {
            Connected in
            self.CurrentlyConnected = Connected
        }
    }
    
    var CurrentlyConnected: Bool = false
    
    /// Set up event handling so we can monitor the mouse. This is used to notify the user when the mouse
    /// is over a location that has data.
    /// - Important:
    ///   Should be called only once.
    /// - Note:
    ///   - Mouse location handling is done in the 2D and 3D view controllers (see `Main2DView`,
    ///     `Main3DView` and `Rect2DView`).
    ///   - Mouse events are only processed for the main view. If the mouse is not over the main view, the various
    ///     map views are not informed of mouse activity.
    ///   - See [Getting Mouse Coordinates in Swift](https://stackoverflow.com/questions/31931403/getting-mouse-coordinates-in-swift)
    func MonitorMouse()
    {
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp])
        {
            event in
            if event.window == self.view.window
            {
                if self.Location.x >= 0 &&
                    self.Location.x < self.view.window!.frame.size.width &&
                    self.Location.y >= 0 &&
                    self.Location.y < self.view.window!.frame.size.height
                {
                    let Point = CGPoint(x: self.Location.x, y: self.Location.y)
                    self.Rect2DView.MouseClickedAt(Point: Point)
                    self.Main2DView.MouseClickedAt(Point: Point)
                    self.Main3DView.MouseClickedAt(Point: Point)
                }
            }
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved])
        {
            event in
            if event.window == self.view.window
            {
                if self.Location.x >= 0 &&
                    self.Location.x < self.view.window!.frame.size.width &&
                    self.Location.y >= 0 &&
                    self.Location.y < self.view.window!.frame.size.height
                {
                    let Point = CGPoint(x: self.Location.x, y: self.Location.y)
                    self.Main3DView.MouseMovedTo(Point: Point)
                    self.Main2DView.MouseMovedTo(Point: Point)
                    self.Rect2DView.MouseMovedTo(Point: Point)
                }
                else
                {
                    //The mouse is outside the window - if necessary, unhide the cursor.
                    if Settings.GetBool(.HideMouseOverEarth)
                    {
                        #if false
                        if !self.Main3DView.MouseIsVisible
                        {
                            self.Main3DView.MouseIsVisible = true
                            NSCursor.unhide()
                        }
                        #endif
                    }
                }
            }
            return event
        }
    }
    
    /// Handle the view will appear event.
    override func viewWillAppear()
    {
        super.viewWillAppear()
        self.view.window!.acceptsMouseMovedEvents = true
        SetWindowDelegate()
    }
    
    /// Initialize things that require a fully set-up window.
    override func viewDidLayout()
    {
        InterfaceInitialization()
        StatusBar.SetConstraints(Left: Status3DLeftConstraint, Right: Status3DRightConstraint)
        StatusBar.SetVisibility(Settings.GetBool(.ShowStatusBar))
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
        
        StatusBar.ShowStatusText("Flatland \(Versioning.VerySimpleVersionString()) (\(Versioning.BuildAsHex()))",
                       For: StatusBarConstants.InitialMessageDuration.rawValue)
        StatusBar.AddQueuedMessage("Getting earthquake data.", ExpiresIn: StatusBarConstants.EarthquakeWaitingDuration.rawValue,
                         ID: EQMessageID)
        
        InitializeWorldClock()
    }

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
    
    // MARK: - High-level mouse.
    

    
    // MARK: - Menu and toolbar event handlers
    
    var DoTrackMouse: Bool = true
    
    @IBAction func ToggleMouseTracking(_ sender: Any)
    {
        if DoTrackMouse
        {
            DoTrackMouse = false
        }
        else
        {
            DoTrackMouse = true
        }
        Settings.SetBool(.FollowMouse, DoTrackMouse)
    }
    
    // Flag used to determine if the settings window is open.
    var SettingsWindowOpen = false
    
    @IBAction func RunPreferences(_ sender: Any)
    {
        if PreferencesWindowOpen
        {
            if let TheWindow = PreferenceWindow?.window
            {
                TheWindow.orderFront(self)
            }
            return
        }
        let Storyboard = NSStoryboard(name: "PreferencePanel", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "PreferencePanelWindow") as? PreferencePanelWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? PreferencePanelController
            Controller?.MainDelegate = self
            PreferenceWindow = WindowController
            MainSettingsDelegate = Controller
            WindowController.showWindow(nil)
            PreferencesWindowOpen = true
            MakeMouseVisible()
        }
    }
    
    var PreferenceWindow: PreferencePanelWindow? = nil
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
            MakeMouseVisible()
        }
    }
    
    var DebuggerOpen = false
    
    /// Set the world lock status. This stops the user from moving the camera in all scenes.
    /// - Note: Prior to locking the scene, the camera is moved back to its default position. This behavior
    ///         can be overridden by setting `ResetPosition` to false.
    /// - Parameter Locked: If true, all scenes in 3D views are reset then locked. If false, the camera
    ///                     is allowed to be moved and no other action is taken.
    /// - Parameter ResetPosition: If true, the position of the world will be reset. Otherwise, it will not
    ///                            change.
    func SetWorldLock(_ Locked: Bool, ResetPosition: Bool = false)
    {
        if let WindowController = self.view.window?.windowController as? MainWindow
        {
            let TooltipText = Locked ? "Currently locked: Click to unlock world scenes" :
                                       "Currently unlocked: Click to reset then lock world scenes"
            WindowController.WorldLockButton.toolTip = TooltipText
            let NewImage = Locked ? NSImage(systemSymbolName: "arrow.triangle.2.circlepath.circle.fill", accessibilityDescription: nil) :
                                    NSImage(systemSymbolName: "arrow.triangle.2.circlepath.circle", accessibilityDescription: nil)
            WindowController.WorldLockToolbarItem.image = NewImage
            WindowController.WorldLockToolbarItem.label = Locked ? "Locked" : "Unlocked"
            WindowController.WorldLockButton.contentTintColor = Locked ? NSColor(named: "ControlRed") : NSColor(named: "ControlGreen")
            let LockMenu = GetAppDelegate().LockUnlockMenuItem
            LockMenu?.state = Locked ? .off : .on
            Main3DView.SetCameraLock(Locked, ResetPosition: ResetPosition)
            Main2DView.SetCameraLock(Locked)
            Rect2DView.SetCameraLock(Locked)
        }
    }
    
    /// Responds to the lock/unlock world button and menu item.
    /// - Parameter sender: Not used.
    @IBAction func HandleLockUnlockWorldButton(_ sender: Any)
    {
        SetWorldLock(Settings.InvertBool(.WorldIsLocked), ResetPosition: true)
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
            MakeMouseVisible()
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
        if !CurrentlyConnected
        {
            let Storyboard = NSStoryboard(name: "ErrorDialogs", bundle: nil)
            if let WindowController = Storyboard.instantiateController(withIdentifier: "ErrorWindow") as? ErrorReporterWindow
            {
                MakeMouseVisible()
                let Window = WindowController.window
                if let Controller = Window?.contentViewController as? ErrorReporter
                {
                    Controller.SetText("Not currently connected to the internet - unable to show today times.")
                    self.view.window?.beginSheet(Window!)
                    {
                        _ in
                        return
                    }
                }
            }
            return
        }
        let Storyboard = NSStoryboard(name: "Today", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "TodayWindow") as? TodayWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? TodayCode
            Controller?.Main = self
            TodayDelegate = Controller
            WindowController.showWindow(nil)
        }
    }
    
    /// Reference to the today viewer. Used to close the viewer if the main window is closed first.
    var TodayDelegate: WindowManagement? = nil
    
    var QuakeController: EarthquakeViewerController? = nil
    var QuakeDelegate: WindowManagement? = nil
    var LiveStatusController: WindowManagement? = nil
    
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
    
    @IBAction func TestSomething(_ sender: Any)
    {
        #if DEBUG
        SoundManager.Play(ForEvent: .Debug)
        Main3DView.FlashAllHours(Count: 5)
        //        Main3DView.FlashHoursInSequence(Count: 3)
        //        Main3DView.RotateCameraTo(Latitude: 43.0, Longitude: 141)
        #endif
    }
    
    @IBAction func RunTestDialog(_ sender: Any)
    {
        #if DEBUG
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ColorChipDebugWindow") as? ColorChipDebugWindow
        {
            WindowController.showWindow(nil)
        }
        #endif
    }
    
    @IBAction func TestCaptiveDialog(_ sender: Any)
    {
        if ShowingCaptiveDialog
        {
            #if true
            HideCaptiveDialog()
            #else
            print("Hiding captive dialog")
            ShowingCaptiveDialog = false
            CaptiveDialogPanel.wantsLayer = true
            CaptiveDialogPanel.layer?.zPosition = CGFloat(-LayerZLevels.CaptiveDialogLayer.rawValue)
            CaptiveDialogPanel.isHidden = true
            ContentTop.constant = CGFloat(0.0)
            #endif
        }
        else
        {
            #if true
            ShowCaptiveDialog(.RegionCreation)
            #else
            print("Showing captive dialog")
            ShowingCaptiveDialog = true
            CaptiveDialogPanel.wantsLayer = true
            CaptiveDialogPanel.layer?.zPosition = CGFloat(LayerZLevels.CaptiveDialogLayer.rawValue)
            CaptiveDialogPanel.isHidden = false
            ContentTop.constant = CGFloat(100.0)
            #endif
        }
    }
    
    var CaptiveDialogList = [CaptiveDialogTypes: CaptiveDialogPanelProtocol]()
    var ShowingCaptiveDialog = false
    var CurrentCaptiveDialog: CaptiveDialogPanelProtocol? = nil
    
    /// Array of previous earthquakes (used in a cache-like fashion).
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
    
    /// Respond to the user command to show live data status.
    /// - Parameter sender: Not used.
    @IBAction func HandleLiveStatusButton(_ sender: Any)
    {
        if LiveStatusWindowOpen
        {
            return
        }
        let Storyboard = NSStoryboard(name: "LiveDataStatus", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "LiveDataStatusWindow") as? LiveDataStatusWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? LiveDataStatusController
            LiveStatusController = Window?.contentView as? WindowManagement
            Controller?.MainDelegate = self
            WindowController.showWindow(nil)
            LiveStatusWindowOpen = true
        }
    }
    
    var LiveStatusWindowOpen = false
    
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
                    print("Setting FlatSouthCenter")
                    MainTimeLabelTop.isHidden = true
                    MainTimeLabelBottom.isHidden = false
                    Main2DView.isHidden = false
                    Rect2DView.isHidden = true
                    Main2DView.UpdateHours()
                    Main2DView.SunVisibility(IsShowing: true)
                    
                case .FlatNorthCenter:
                    print("Setting FlatNorthCenter")
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
    
    let EQMessageID = UUID()
    
    public static var StartTime: Double = 0.0
    public var MainApp: AppDelegate!
    
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
    
    /// Holds the location of the mouse pointer in the window.
    var Location: NSPoint {self.view.window!.mouseLocationOutsideOfEventStream}
    
    /// Holds the most recent stenciled image.
    var StenciledImage: NSImage? = nil
    
    #if DEBUG
    /// Time stamp for when the program started.
    var StartDebugCount: Double = 0.0
    /// Number of seconds running in the current instantiation.
    var UptimeSeconds: Int = 0
    #endif
    /// Previous second count.
    var OldSeconds: Double = 0.0
    
    var MouseLocationController: MouseInfoController? = nil
    
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
    var WorldHeritageSites: [WorldHeritageSite]? = nil
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
    /// Additional cities defined by the user.
    static var OtherCities = [City2]()
    /// Built-in POIs.
    static var BuiltInPOIs = [POI2]()
    
    // MARK: - World clock variables.
    var WorldClockTimer: Timer? = nil
    var WorldClockTimeMultiplier: Double = 1.0
    var CurrentWorldTime: Double = 0.0
    var WorldClockStartTime: Date? = nil
    
    var HourSoundTriggered: Bool = false
    
    // MARK: - Windowing variables
    var ParentWindow: NSWindow? = nil
    
    // MARK: - Storyboard outlets
    @IBOutlet var PrimaryView: ParentView!
    @IBOutlet weak var Main2DView: FlatView!
    @IBOutlet weak var Rect2DView: RectangleView!
    @IBOutlet var Main3DView: GlobeView!
    @IBOutlet weak var MainTimeLabelTop: NSTextField!
    @IBOutlet weak var MainTimeLabelBottom: NSTextField!
    @IBOutlet weak var BackgroundView: NSView!
    @IBOutlet weak var ContentView: NSView!
    @IBOutlet weak var StatusBar: StatusBar3D!
    @IBOutlet weak var Status3DLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var Status3DRightConstraint: NSLayoutConstraint!
    
    // MARK: - Debug UI elements
    @IBOutlet weak var WorldClockLabel: NSTextField!
    @IBOutlet weak var WorldClockTickCount: NSTextField!
    @IBOutlet weak var VersionLabel: NSTextField!
    @IBOutlet weak var VersionValue: NSTextField!
    @IBOutlet weak var BuildLabel: NSTextField!
    @IBOutlet weak var BuildValue: NSTextField!
    @IBOutlet weak var BuildDateLabel: NSTextField!
    @IBOutlet weak var BuildDateValue: NSTextField!
    @IBOutlet weak var DebugTextGrid: NSGridView!
    @IBOutlet weak var UptimeLabel: NSTextFieldCell!
    @IBOutlet weak var UptimeValue: NSTextField!
    
    // MARK: - Captive dialog elements
    @IBOutlet weak var ContentTop: NSLayoutConstraint!
    @IBOutlet weak var CaptiveDialogContainer: NSView!
    @IBOutlet weak var CaptiveDialogPanel: NSView!
}
