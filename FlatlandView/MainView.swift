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
        
        BackgroundView.wantsLayer = true
        BackgroundView.layer?.backgroundColor = NSColor.black.cgColor
        
        CityTestList = CityList.TopNCities(N: 50, UseMetroPopulation: true)
    }
    
    override var representedObject: Any?
        {
        didSet
        {
            // Update the view, if already loaded.
        }
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
        print("selected north centered")
    }
    
    @IBAction func ViewTypeSouthCentered(_ sender: Any)
    {
        print("selected south centered")
    }
    
    @IBAction func ViewTypeGlobal(_ sender: Any)
    {
        print("selected global centered")
    }
    
    @IBAction func ViewSelectMap(_ sender: Any)
    {
        
        let Storyboard = NSStoryboard(name: "MapSelector", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "MapPickerWindow") as? MapPickerWindow
        {
            #if true
            let MapSelector = WindowController.window
            self.view.window?.beginSheet(MapSelector!, completionHandler: nil)
            #else
            WindowController.showWindow(nil)
            #endif
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
    
    // MARK: - Protocol-required functions
    
    // MARK: - MainProtocol required functions.
    
    func Refresh(_ From: String)
    {
        
    }
    
    // MARK: - Settings changed required functions.
    
    func SubscriberID() -> UUID
    {
        return UUID(uuidString: "66629111-b430-4231-af5a-e39f35ae7883")!
    }
    
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        print("\(Setting.rawValue) changed from \(OldValue) to \(NewValue)")
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

