//
//  MainSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreLocation

class MainSettings: NSViewController, AutoLocationProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeUI()
    }
    
    func InitializeUI()
    {
        Initialize2DMap()
        Initialize3DMap()
        InitializeUserLocationUI()
        InitializeOtherLocationUI()
        InitializeCitySettingsUI()
        InitializeOtherSettings()
        InitializeAsynchronousEarthquakes()
        InitializeMaps()
    }
    
    // MARK: - 2D Map settings.
    
    var SunImageList = [(SunNames, NSImage)]()
    let SunMap: [SunNames: String] =
        [
            .None: "NoSun",
            .Simple: "SimpleSun",
            .Generic: "GenericSun",
            .Shining: "StarShine",
            .NaomisSun: "NaomiSun1Up",
            .Durer: "DurerSunUp",
            .Classic1: "SunX",
            .Classic2: "Sun2Up",
            .PlaceHolder: "SunPlaceHolder"
    ]
    
    @IBOutlet weak var NightDarknessSegment: NSSegmentedControl!
    @IBOutlet weak var SunSelector: NSTableView!
    @IBOutlet weak var Show2DNoonMeridians: NSButton!
    @IBOutlet weak var Show2DPrimeMeridians: NSButton!
    @IBOutlet weak var Show2DPolarCircles: NSButton!
    @IBOutlet weak var Show2DTropics: NSButton!
    @IBOutlet weak var Show2DEquator: NSButton!
    @IBOutlet weak var Show2DNight: NSButton!
    
    // MARK: - 3D Map settings.
    
    @IBOutlet weak var UseAmbientLight: NSButton!
    @IBOutlet weak var Background3DColorWell: NSColorWell!
    @IBOutlet weak var DebugButton: NSButton!
    @IBOutlet weak var StarSpeedSegment: NSSegmentedControl!
    @IBOutlet weak var SampleStars: Starfield!
    @IBOutlet weak var Show3DGridLines: NSButton!
    @IBOutlet weak var Show3DMinorGridLinesCheck: NSButton!
    @IBOutlet weak var Show3DPrimeMeridiansCheck: NSButton!
    @IBOutlet weak var Show3DPolarCirclesCheck: NSButton!
    @IBOutlet weak var Show3DTropicsCheck: NSButton!
    @IBOutlet weak var Show3DEquatorCheck: NSButton!
    @IBOutlet weak var MinorGridGapSegment: NSSegmentedControl!
    @IBOutlet weak var GlobeTransparencySegment: NSSegmentedControl!
    @IBOutlet weak var PoleShapeCombo: NSComboBox!
    @IBOutlet weak var ShowMoonLightSwitch: NSButton!
    @IBOutlet weak var ShowMovingStarsSwitch: NSButton!
    
    // MARK: - Locations settings.
    
    // MARK: - City settings.
    
    @IBOutlet weak var PopulationSegment: NSSegmentedControl!
    @IBOutlet weak var ShowCapitalCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowSouthAmericanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowNorthAmericanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowEuropeanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowAsianCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowAfricanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowWorldCitiesSwitch: NSSwitch!
    @IBOutlet weak var CityShapeCombo: NSComboBox!
    @IBOutlet weak var ShowCitiesCheck: NSButton!
    
    // MARK: - Your location settings.
    
    var UserLocations = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: NSColor)]()
    
    var AddNewUserLocation = false
    
    @IBOutlet weak var HomeShapeCombo: NSComboBox!
    @IBOutlet weak var UserTimeZoneOffsetCombo: NSComboBox!
    @IBOutlet weak var UserLocationTable: NSTableView!
    @IBOutlet weak var UserLocationLongitudeBox: NSTextField!
    @IBOutlet weak var UserLocationLatitudeBox: NSTextField!
    @IBOutlet weak var ShowUserLocationsCheck: NSButton!
    
    // MARK: - Other location settings.
    
    @IBOutlet weak var ShowHeritageSiteCheck: NSButton!
    @IBOutlet weak var HeritageSiteSegment: NSSegmentedControl!
    
    // MARK: - Other settings.
    
    @IBOutlet weak var ShowSecondsCheck: NSButton!
    @IBOutlet weak var TimeLabelSegment: NSSegmentedControl!
    @IBOutlet weak var ScriptCombo: NSComboBox!
    @IBOutlet weak var ShowLocalDataCheck: NSButton!
    
    // MARK: - Live data earthquake settings
    
    var LocalEarthquakeData = [Earthquake]()
    
    @IBOutlet weak var EarthquakeViewButton: NSButton!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var AgeCombo: NSComboBox!
    @IBOutlet weak var ColorDetCombo: NSComboBox!
    @IBOutlet weak var EarthquakeCheck: NSButton!
    @IBOutlet weak var MinMagnitudeSegment: NSSegmentedControl!
    @IBOutlet weak var FrequencyCombo: NSComboBox!
    @IBOutlet weak var BaseColorWell: NSColorWell!
    
    // MARK: - Common code.
    
    var CurrentUserLocationIndex = -1
   
    // MARK: - Map selection.
    
    var OriginalMap = MapTypes.BlackWhite
    var SampleType = ViewTypes.Globe3D
    var LastMap: MapTypes = .Standard
    var MapList = [MapTypes]()
    var MapCategoryList = [MapCategories]()
    var Updated = false
    
    @IBOutlet weak var SampleViewType: NSSegmentedControl!
    @IBOutlet weak var LastSelectedLabel: NSTextField!
    @IBOutlet weak var MapSampleView: NSImageView!
    @IBOutlet weak var MapTypeTable: NSTableView!
    @IBOutlet weak var MapListTable: NSTableView!
    
    // MARK: - Confirmation protocol functions.

    var ConfirmMessage = ""
}
