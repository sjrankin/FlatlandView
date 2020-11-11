//
//  PreferencePanelController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class PreferencePanelController: NSViewController, WindowManagement
{
    public weak var MainDelegate: MainProtocol? = nil
    
    var ParentWindow: PreferencePanelWindow? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayout()
    {
        ParentWindow = self.view.window?.windowController as? PreferencePanelWindow
        CreatePreferencePanels()
        LoadPanel(.General)
    }
    
    override func viewWillDisappear()
    {
        MainDelegate?.ChildWindowClosed(.PreferenceWindow)
    }
    
    func CreatePreferencePanels()
    {
        Panels[.General] = PreferencePanelBase(CreatePanelDialog("GeneralPreferences"))
        Panels[.Maps] = PreferencePanelBase(CreatePanelDialog("MapPreferences"))
        Panels[.POIs] = PreferencePanelBase(CreatePanelDialog("POIPreferences"))
        Panels[.Satellites] = PreferencePanelBase(CreatePanelDialog("SatellitePreferences"))
        Panels[.Earthquakes] = PreferencePanelBase(CreatePanelDialog("EarthquakePreferences"))
        Panels[.LiveData] = PreferencePanelBase(CreatePanelDialog("LiveDataPreferences"))
        Panels[.MapAttributes] = PreferencePanelBase(CreatePanelDialog("MapAttributesPreferences"))
    }
    
    var Panels = [PreferencePanelTypes: PreferencePanelBase]()
    
    func CreatePanelDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "PreferencePanel", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            return Controller
        }
        fatalError("Error creating \(IDName)")
    }
    
    @IBAction func HandleGeneralButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("General button pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.General)
        }
    }
    
    @IBAction func HandlePOIButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("POI button pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.POIs)
        }
    }
    
    @IBAction func HandleMapButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("Map button pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.Maps)
        }
    }
    
    @IBAction func HandleLiveDataButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("Live data button pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.LiveData)
        }
    }
    
    @IBAction func HandleSatelliteButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("Satellite button pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.Satellites)
        }
    }
    
    @IBAction func HandleEarthquakeButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("Earthquake button pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.Earthquakes)
        }
    }
    
    @IBAction func HandleMapAttributesButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            print("Map Attributes pressed")
            ParentWindow?.Highlight(Button)
            LoadPanel(.MapAttributes)
        }
    }
    
    func LoadPanel(_ Panel: PreferencePanelTypes)
    {
        for SomeView in PreferenceContainer.subviews
        {
            SomeView.removeFromSuperview()
        }
        Panels[Panel]!.Controller?.view.frame = PreferenceContainer.bounds
        PreferenceContainer.addSubview(Panels[Panel]!.Controller!.view)
    }
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var PreferenceContainer: PreferencePanelView!
}

enum PreferencePanelTypes: String, CaseIterable
{
    case General
    case Maps
    case POIs
    case Earthquakes
    case Satellites
    case LiveData
    case MapAttributes
}
