//
//  PreferencePanelController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

// https://stackoverflow.com/questions/51672124/how-can-dark-mode-be-detected-on-macos-10-14
class PreferencePanelController: NSViewController, WindowManagement, PreferencePanelControllerProtocol,
                                  SettingChangedProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    var ParentWindow: PreferencePanelWindow? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //let CurrentAppearance = self.view.effectiveAppearance
        Settings.AddSubscriber(self)
    }
    
    override func viewDidLayout()
    {
        if !HandledInitial
        {
            ParentWindow = self.view.window?.windowController as? PreferencePanelWindow
            CreatePreferencePanels()
            LoadPanel(.General)
            HandledInitial = true
        }
        let CurrentAppearance = self.view.effectiveAppearance
        let IsDark = DarkThemes.contains(CurrentAppearance.name)
        ParentWindow?.HandleThemeChanged(IsDark)
        for (_, Panel) in Panels
        {
            if let Controller = Panel.Controller as? PreferencePanelProtocol
            {
                Controller.SetDarkMode(To: IsDark)
            }
        }
    }
    
    var DarkThemes: [NSAppearance.Name] =
    [
        .accessibilityHighContrastDarkAqua,
        .accessibilityHighContrastVibrantDark,
        .darkAqua,
        .vibrantDark
    ]
    
    var HandledInitial = false
    
    override func viewWillDisappear()
    {
        Settings.RemoveSubscriber(self)
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
        Panels[.Cities] = PreferencePanelBase(CreatePanelDialog("CityPreferences"))
        Panels[.Sounds] = PreferencePanelBase(CreatePanelDialog("SoundPreferences"))
    }
    
    var Panels = [PreferencePanelTypes: PreferencePanelBase]()
    
    func CreatePanelDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "PreferencePanel", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            guard let AController = Controller as? PreferencePanelProtocol else
            {
                Debug.FatalError("Error casting preference panel to PreferencePanelProtocol")
            }
            AController.Parent = self
            AController.MainDelegate = MainDelegate
            return Controller
        }
        fatalError("Error creating \(IDName)")
    }
    
    @IBAction func HandleGeneralButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.General)
        }
    }
    
    @IBAction func HandlePOIButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.POIs)
        }
    }
    
    @IBAction func HandleMapButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.Maps)
        }
    }
    
    @IBAction func HandleLiveDataButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.LiveData)
        }
    }
    
    @IBAction func HandleSatelliteButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.Satellites)
        }
    }
    
    @IBAction func HandleEarthquakeButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.Earthquakes)
        }
    }
    
    @IBAction func HandleMapAttributesButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.MapAttributes)
        }
    }
    
    @IBAction func HandleCitiesButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.Cities)
        }
    }
    
    @IBAction func HandleSoundsButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            LoadPanel(.Sounds)
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
        Pop?.close()
    }
    
    override func viewDidDisappear()
    {
        DistributedNotificationCenter.default().removeObserver(self)
        CloseColorPanel()
    }
    
    /// Close the color panel if it is visible.
    func CloseColorPanel()
    {
        if NSColorPanel.sharedColorPanelExists
        {
            if NSColorPanel.shared.isVisible
            {
                NSColorPanel.shared.close()
            }
        }
    }
    
    func ShowHelp(For: PreferenceHelp, Where: NSRect, What: NSView)
    {
        if let PopController = NSStoryboard(name: "PreferenceHelpViewer", bundle: nil).instantiateController(withIdentifier: "PreferenceHelpViewer") as? PreferenceHelpPopover
        {
//            guard let HelpController = PopController as? PreferenceHelpProtocol else
//            {
//                return
//            }
            let HelpController = PopController as PreferenceHelpProtocol
            Pop = NSPopover()
            Pop?.contentSize = NSSize(width: 427, height: 237)
            Pop?.behavior = .semitransient
            Pop?.animates = true
            Pop?.contentViewController = PopController
            var Message = ""
            switch For
            {
                // MARK: - General help.
                case .InterfaceStyle:
                    Message = """
Specify the interface level. This determines how comples the objects drawn are.
• |font type=bold|Minimal|font type=system| is for low-powered systems or power-constrained computers.
• |font type=bold|Normal|font type=system| is for most systems.
• |font type=bold|Maximum|font type=system| is for when you want to see all of the extra interface decorations.
"""
                    
                case .InputUnits:
                    Message = """
Sets the expected input units.
• |font type=bold|Kilometers|font type=system|: values for distance are in kilometers.
• |font type=bold|Miles|font type=system|: values for distance are in miles.
You can override this on an individual basis by using |font type=bold|km|font type=system| for kilometers or |font type=bold|mi|font type=system| for miles.
"""
                    
                case .MainDateFormat:
                    Message = """
Lets you set the main time format.
• |font type=bold|None|font type=system| hides the time.
• |font type=bold|UTC|font type=system| shows the time in UTC (Universal Time Coordinated) - also known as GMT.
• |font type=bold|Local|font type=system| uses your computer's local time as the clock.
"""
                    
                case .ShowSeconds:
                    Message = """
Show or hide seconds in the main time display. Ignored if the clock format is None.
"""
                    
                case .HourTypes:
                    Message = """
Determines the type of hours to show. Can be none, relative to the sun (eg, the sun is always over the noon location), relative to a location, relative to current noon, or wall-clock time (based on the sun, not time-zones).
"""
                    
                case .MapTypes:
                    Message = """
The basic map type to use - can be rectangular, circular north-centered, circular south-centered, or 3D globe.
"""
                    
                case .HourScale:
                    Message = """
Determines the scale of the floating hours over the globe.
"""
                    
                case .ShowStatusBar:
                    Message = """
Hides or shows the status bar. Status messages are always sent so if you show a status bar, the most recent message will be shown.
"""
                    
                case .UIHelp:
                    Message = """
Hides or shows the UI help buttons (􀁝) in the interface.
"""
                    
                case .HourEventHelp:
                    Message = """
Enable or disable sounds and visual effects at the top of each hour.
"""
                    
                //MARK: - Map help.
                case .MapSample:
                    Message = """
Lets you change the sample view of the map you are looking at.
"""
                    
                case .SaveImageHelp:
                    Message = """
Click to save the satellite map image in rectangular format. If the Save button is disabled, the image is not available to save. You may only save satellite map images.
"""
                    
                case .ChangingMapsHelp:
                    Message = """
Maps are grouped into categories and you can see a sample of each map by clicking on it. However, the main view's map will not change until you close the Preferences window or click the |font type=bold|Update Now|font type=system| button.
Satellite maps are dependent on a remote source and may or may not be available due to uncontrollable circumstances. If available, the most recently used satellite map wil be shown as an example.
"""
                    
                case .UpdateNowHelp:
                    Message = """
Clicking the |font type=bold|Update Now|font type=system| will update the main view's map with the currently selected map. Flatland may take a few seconds to regenerate its view.
"""
                    
                //MARK: - Earthquake help.
                case .QuakeRegions:
                    Message = """
Click the Set Regions button to edit regions. Ignored if regions are disabled.
"""
                    
                case .EnableQuakeRegions:
                    Message = """
Enable or disable earthquake regions. If enabled, you can specify regions on the earth with different parameters for earthquake displays.
"""
                    
                case .DisplayQuakes:
                    Message = """
Enables the fetching of earthquake data from the USGS. Requires an active internet connection. Will incur
data charges where relevant. Set the fetch frequency to lower the amount of data received.
"""
                    
                case .QuakeShape:
                    Message = """
You can select the shape of the earthquake indicator here.
"""
                    
                case .QuakeFetchFrequency:
                    Message = """
How often to fetch new earthquakes from the USGS. Each time data is fetched, an average of about 1000 earthquakes is returned for about 10k of data. Increase the frequency to save data.

If you do not have an active internet connection, this value is ignored.
"""
                    
                case .QuakeHighlight:
                    Message = """
If enabled, "new" earthquakes (24 hours old or less) are highlighted visually.
"""
                    
                case .QuakeCheckNow:
                    Message = """
Check for new earthquakes. Result availability is determined by how busy the remote server is and your internet connection speed.
"""
                    
                case .QuakeScale:
                    Message = """
Sets the scale (size) of the 3D shapes that indicate where an earthquake has occurred. Does not affect stenciled text drawn on the map.
"""
                    
                case .NewQuakeIndicator:
                    Message = """
Lets you change how new earthquakes are shown. Animated new earthquake indicators will use more CPU and battery power.
"""
                    
                case .QRCodeHelp:
                    Message = """
If enabled, Flatland displays a QR code next to earthquake magnitude values that when viewed with a cell phone, open the USGS site related to the earthquake in question.
"""
                    
                // MARK: - Map attributes help.
                case .ShowGridLines:
                    Message = """
Show or hide grid lines. Showing grid lines (very slightly) increases power consumption. Changing this setting may take a few seconds to be reflected in the view.
"""
                    
                case .CursorAppearance:
                    Message = """
Show or hide the system arrow cursor when it is over the Earth. If you hide it, the cursor will be replaced by a 3D location indicator. The cursor will also resume its normal shape when not over the Earth.
"""
                    
                case .GridLineColor:
                    Message = """
Set the color of the grid lines. Ignored if grid lines are turned off. Changing the color may take a few seconds to be reflected in the view.
"""
                    
                case .BackgroundColor:
                    Message = """
Set the scene's background color. Defaults to black.
"""
                    
                case .FlatNightDarkness:
                    Message = """
Selects the darkness level of the night mask for 2D maps.
• |font type=bold|None|font type=system| removes the night mask so you cannot see the night.
• |font type=bold|Light|font type=system| shows a relatively light night mask that is easy to see through.
• |font type=bold|Dark|font type=system| is a darker night mask.
"""
                    
                case .ShowMoonlight:
                    Message = """
Turn on or off moonlight for the 3D globe. If off, there is no light on the night-side of the Earth, making it difficult to see the globe (but is more realistic). If on, a dim light is used to illuminate the night-side.
"""
                    
                case .PoleShape:
                    Message = """
Select the shape shown at the North and South Poles.
"""
                    
                case .WallClockSeparators:
                    Message = """
Determines if wall clock separators are shown when wall clock hours are on and you are viewing either the north-centered or south-centered map.
"""
                    
                case .ShowCities:
                    Message = """
Show cities on the map. You can select which cities and the shape they are shown in.
"""
                case .CityShape:
                    Message = """
The shape of cities shown on the map. Complex city shapes may slow down your computer. |font type=bold|This is especially true if you use 3D extruded text for city names.|font type=system|
"""
                case .CityByPopulation:
                    Message = """
Select cities to see by population. Click the |font type=bold|Set Population|font type=system| button to set the population criterion.
"""
                    
                case .CapitalCities:
                    Message = """
Show all national capital cities (in the case where a country has more than one captial city, all are shown).
"""
                    
                case .AllCities:
                    Message = """
Show all cities in the city database. This may slow down your computer as there are many cities. City shapes that are more complex will also slow down your computer.
"""
                    
                case .UNESCOSites:
                    Message = """
Determines the World Heritage Sites to display.
• |font type=bold|Cultural|font type=system| shows cultural-related sites.
• |font type=bold|Natural|font type=system| shows nature-related sites.
• |font type=bold|Mixed|font type=system| shows sites classified as both Cultural and Natural.
• |font type=bold|All|font type=system| shows all World Heritage Sites. There are many so this may slow down your computer.
"""
                    
                case .ShowUNESCOSites:
                    Message = """
If on, enables the viewing of the location of UNESCO World Heritage Sites. If off, sites will not be shown.
"""
                    
                case .ShowHome:
                    Message = """
Show your home location. If you have not entered your home location, nothing is shown even if you turn this option on.
"""
                    
                case .EditHome:
                    Message = """
Enter/edit your home location. You must enter a home location before it can be shown. Additionally, you can set your home location by right-clicking the mouse button on a map.
"""
                    
                case .ShowUserPOIs:
                    Message = """
Show your points-of-interest you have defined.
"""
                    
                case .EditUserPOIs:
                    Message = """
Enter/edit your points-of-interest. You can also use the map directly to do with with by selecting the proper menu item when right-clicking the mouse button on a map.
"""
                    
                case .POIScale:
                    Message = """
Sets the scale for POI items on the map. Does not affect stenciled text drawn on the map itself.
"""
                    
                case .ShowBuiltInPOIs:
                    Message = """
Plot all of the built-in points of interest on the map.
"""
                    
                case .ShowListofBuiltInPOIs:
                    Message = """
Show a list of all built-in points of interest.
"""
                    
                // MARK: - Live data help.
                case .LiveDataHelp:
                    Message = """
Live data is returned by remote servers that are not affiliated with Flatland. As such, there are times when those servers may be offline. Additionally, using live data will incur a data cost if you are using a metered connection. |font type=bold|Live data will not function if you are not connected to the internet.|font type=system|
"""
                case .EnableNASATilesHelp:
                    Message = """
In order to use NASA satellite imagery, you must enable this option. However doing so will result in increased data downloads and memory usage.
"""
                    
                case .NASATilesFetchFrequencyHelp:
                    Message = """
Determines how often to download NASA imagery to use for the map. Most data is available on a 24 hour cycle so more frequently than that will result in no changes to the map. Select |font type=bold|On demand|font type=system| to only load when you explicitly tell Flatland to do so.
"""
                    
                //MARK: - Sound help.
                case .ClearEventSoundHelp:
                    Message = """
Clear all sounds from the currently selected event. Essentially, this just sets the sound to |font type=bold|None|font type=system|.
"""
                    
                case .MuteEventHelp:
                    Message = """
Mutes an event's sound without changing it.
"""
                    
                case .PlaySampleHelp:
                    Message = """
Play the currently selected sound.
"""
                    
                case .UserFileHelp:
                    Message = """
This lets you select a sound file on your computer to use for a given event. If you select a sound file, please do not move it as Flatland will expect it to be in the same spot all of the time.
"""
                    
                case .SoundPlayHelp:
                    Message = """
Global sound enabling. Enable or disable all sounds Flatland plays. (Your system may generate its own sounds - this setting will not affect those sounds.)
"""
                    
                case .BuiltInSoundsHelp:
                    Message = """
List of built-in sounds for Flatland, including standard system sounds.
"""
                    
                case .MutePeriodHelp:
                    Message = """
This section lets you mute sounds generated by Flatland for a period of time every day.
"""
                
                    //MARK: - Common help.
                case .PaneReset:
                    Message = """
Reset all values in the current pane to original, factory values. You will be asked to confirm this before this action is taken.
"""
                    
                case .POIResetPaneHelp:
                    Message = """
Reset some values in the current pane to original, factory values. You will be asked to confirm this before this action is taken. You cannot reset built-in data (such as cities or points of interest). You can reset your personal cities and points of interest but need to do so from the |font type=bold|Edit|font type=system| button. |font type=italic|Your home location will be removed|font type=system|.
"""
                    
                case .QuakePanelReset:
                    Message = """
Reset all values in the current pane to original, factory values. You will be asked to confirm this before this action is taken. Your regions will remain unchanged - to reset them, click on |font type=bold|Edit Regions|font type=system| to delete/reset your regions.
"""
            }
            HelpController.SetHelpText(Message)
            Pop?.show(relativeTo: Where, of: What, preferredEdge: .maxY)
        }
    }
    
    var Pop: NSPopover? = nil
    
    let DialogID: UUID = UUID()
    func SubscriberID() -> UUID
    {
        return DialogID
    }
    
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .ShowUIHelp:
                for (_, Panel) in Panels
                {
                    if let Controller = Panel.Controller as? PreferencePanelProtocol
                    {
                        Controller.SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
                    }
                }
                
            default:
                return
        }
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
    case Cities
    case Sounds
}

enum PreferenceHelp: String, CaseIterable
{
    case InterfaceStyle = "InterfaceStyle"
    case MainDateFormat = "MainDateFormat"
    case ShowSeconds = "ShowSeconds"
    case InputUnits = "InputUnits"
    case HourTypes = "HourTypes"
    case MapTypes = "MapTypes"
    case HourScale = "HourScale"
    case ShowStatusBar = "ShowStatusBar"
    case UIHelp = "UIHelp"
    case HourEventHelp = "HourEventHelp"
    
    case MapSample = "MapSample"
    case ChangingMapsHelp = "ChangingMapsHelp"
    case UpdateNowHelp = "UpdateNowHelp"
    case SaveImageHelp = "SaveImageHelp"
    
    case QuakeRegions = "QuakeRegions"
    case DisplayQuakes = "DisplayQuakes"
    case QuakeHighlight = "QuakeHighlight"
    case QuakeShape = "QuakeShape"
    case EnableQuakeRegions = "EnableQuakeRegions"
    case QuakeFetchFrequency = "QuakeFetchFrequency"
    case QuakeCheckNow = "QuakeCheckNow"
    case QuakeScale = "QuakeScale"
    case QuakePanelReset = "QuakePanelReset"
    case NewQuakeIndicator = "NewQuakeIndicator"
    case QRCodeHelp = "QRCodeHelp"
    
    case ShowGridLines = "ShowGridLines"
    case GridLineColor = "GridLineColor"
    case BackgroundColor = "BackgroundColor"
    case FlatNightDarkness = "FlatNightDarkness"
    case ShowMoonlight = "ShowMoonlight"
    case PoleShape = "PoleShape"
    case CursorAppearance = "CursorAppearance"
    case WallClockSeparators = "WallClockSeparators"
    
    case ShowCities = "ShowCities"
    case CityShape = "CityShape"
    case CityByPopulation = "CityByPopulation"
    case CapitalCities = "CapitalCities"
    case AllCities = "AllCities"
    case UNESCOSites = "UNESCOCites"
    case ShowUNESCOSites = "ShowUNESCOSites"
    case ShowBuiltInPOIs = "ShowBuiltInPOIs"
    case ShowListofBuiltInPOIs = "ShowListOfBuiltInPOIs"
    case POIResetPaneHelp = "POIResetPaneHelp"
    
    case ShowHome = "ShowHome"
    case EditHome = "EditHome"
    case ShowUserPOIs = "ShowUserPOIs"
    case EditUserPOIs = "EditUserPOIs"
    case POIScale = "POIScale"
    
    case LiveDataHelp = "LiveDataHelp"
    case EnableNASATilesHelp = "EnableNASATilesHelp"
    case NASATilesFetchFrequencyHelp = "NASATilesFetchFrequencyHelp"
    
    case PaneReset = "PaneReset"
    
    case SoundPlayHelp = "SoundPlayHelp"
    case UserFileHelp = "UserFileHelp"
    case BuiltInSoundsHelp = "BuiltInSoundsHelp"
    case PlaySampleHelp = "PlaySampleHelp"
    case MuteEventHelp = "MuteEventHelp"
    case ClearEventSoundHelp = "ClearEventSoundHelp"
    case MutePeriodHelp = "MutePeriodHelp"
}
