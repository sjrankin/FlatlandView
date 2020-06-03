//
//  MainSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MainSettings: NSViewController, NSTableViewDataSource, NSTableViewDelegate,
    NSTextFieldDelegate,
    LocationEditingProtocol, ConfirmProtocol
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
    }
    
    // MARK: - 2D Map settings.
    
    func Initialize2DMap()
    {
        Show2DNight.state = Settings.GetBool(.ShowNight) ? .on : .off
        Show2DPolarCircles.state = Settings.GetBool(.Show2DPolarCircles) ? .on : .off
        Show2DPrimeMeridians.state = Settings.GetBool(.Show2DPrimeMeridians) ? .on : .off
        Show2DNoonMeridians.state = Settings.GetBool(.Show2DNoonMeridians) ? .on : .off
        Show2DEquator.state = Settings.GetBool(.Show2DEquator) ? .on : .off
        Show2DTropics.state = Settings.GetBool(.Show2DTropics) ? .on : .off
        let CurrentSun = Settings.GetEnum(ForKey: .SunType, EnumType: SunNames.self, Default: .Classic1)
        var Index = 0
        var SunIndex = -1
        for SomeSun in SunNames.allCases
        {
            if let ImageName = SunMap[SomeSun]
            {
                if SomeSun == CurrentSun
                {
                    SunIndex = Index
                }
                var SunImage = NSImage(named: ImageName)
                SunImage = Utility.ResizeImage(Image: SunImage!, Longest: 50.0)
                SunImageList.append((SomeSun, SunImage!))
            }
            Index = Index + 1
        }
        if SunIndex > -1
        {
            let ISet = IndexSet(integer: SunIndex)
            SunSelector.selectRowIndexes(ISet, byExtendingSelection: false)
            SunSelector.scrollRowToVisible(SunIndex)
        }
        let DarkType = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Light)
        var DarkIndex = 0
        switch DarkType
        {
            case .VeryLight:
                DarkIndex = 0
            
            case .Light:
                DarkIndex = 1
            
            case .Dark:
                DarkIndex = 2
            
            case .VeryDark:
                DarkIndex = 3
        }
        NightDarknessSegment.selectedSegment = DarkIndex
    }
    
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
    
    @IBAction func HandleShow2DNightChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowNight, Button.state == .on ? true : false)
        }
    }
    
    @IBAction func Handle2DGridLinesChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            let IsChecked = Check.state == .on ? true: false
            switch Check
            {
                case Show2DEquator:
                    Settings.SetBool(.Show2DEquator, IsChecked)
                
                case Show2DTropics:
                    Settings.SetBool(.Show2DTropics, IsChecked)
                
                case Show2DNoonMeridians:
                    Settings.SetBool(.Show2DNoonMeridians, IsChecked)
                
                case Show2DPrimeMeridians:
                    Settings.SetBool(.Show2DPrimeMeridians, IsChecked)
                
                case Show2DPolarCircles:
                    Settings.SetBool(.Show2DPolarCircles, IsChecked)
                
                default:
                    return
            }
            MainDelegate?.Refresh("MainSettings.Handle2DGridLinesChanged")
        }
    }
    
    @IBAction func HandleNightDarknessChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            let DarkTypes = [NightDarknesses.VeryLight, NightDarknesses.Light, NightDarknesses.Dark, NightDarknesses.VeryDark]
            if Index > DarkTypes.count - 1
            {
                return
            }
            Settings.SetEnum(DarkTypes[Index], EnumType: NightDarknesses.self, ForKey: .NightDarkness)
            MainDelegate?.Refresh("MainSettings.HandleNightDarknessChanged")
        }
    }
    
    @IBOutlet weak var NightDarknessSegment: NSSegmentedControl!
    @IBOutlet weak var SunSelector: NSTableView!
    @IBOutlet weak var Show2DNoonMeridians: NSButton!
    @IBOutlet weak var Show2DPrimeMeridians: NSButton!
    @IBOutlet weak var Show2DPolarCircles: NSButton!
    @IBOutlet weak var Show2DTropics: NSButton!
    @IBOutlet weak var Show2DEquator: NSButton!
    @IBOutlet weak var Show2DNight: NSButton!
    
    // MARK: - 3D Map settings.
    
    func Initialize3DMap()
    {
        let Gap = Settings.GetDouble(.MinorGrid3DGap)
        if let GapIndex = [5.0, 15.0, 30.0, 45.0].firstIndex(of: Gap)
        {
            MinorGridGapSegment.selectedSegment = GapIndex
        }
        else
        {
            //If we don't have a valid index, select 1, which corresponds to 15°.
            MinorGridGapSegment.selectedSegment = 1
        }
        let GlobeTransparency = Settings.GetDouble(.GlobeTransparencyLevel, 0.0)
        if let AlphaIndex = [0.0, 0.15, 0.35, 0.50].firstIndex(of: GlobeTransparency)
        {
            GlobeTransparencySegment.selectedSegment = AlphaIndex
        }
        else
        {
            //If we don't have a valid index, select 0 which corresponds to a fully opaque globe.
            GlobeTransparencySegment.selectedSegment = 0
        }
        Show3DTropicsCheck.state = Settings.GetBool(.Show3DTropics) ? .on : .off
        Show3DMinorGridLinesCheck.state = Settings.GetBool(.Show3DMinorGrid) ? .on : .off
        Show3DPrimeMeridiansCheck.state = Settings.GetBool(.Show3DPrimeMeridians) ? .on : .off
        Show3DPolarCirclesCheck.state = Settings.GetBool(.Show3DPolarCircles) ? .on : .off
        Show3DEquatorCheck.state = Settings.GetBool(.Show3DEquator) ? .on : .off
        ShowMovingStarsSwitch.state = Settings.GetBool(.ShowMovingStars) ? .on : .off
        ShowMoonLightSwitch.state = Settings.GetBool(.ShowMoonLight) ? .on : .off
        PoleShapeCombo.removeAllItems()
        for PoleShape in PolarShapes.allCases
        {
            PoleShapeCombo.addItem(withObjectValue: PoleShape.rawValue)
        }
        let CurrentPole = Settings.GetEnum(ForKey: .PolarShape, EnumType: PolarShapes.self, Default: .None)
        PoleShapeCombo.selectItem(withObjectValue: CurrentPole.rawValue)
    }
    
    @IBAction func Handle3DGridLineChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            let IsChecked = Button.state == .on ? true : false
            switch Button
            {
                case Show3DMinorGridLinesCheck:
                    Settings.SetBool(.Show3DMinorGrid, IsChecked)
                
                case Show3DPrimeMeridiansCheck:
                    Settings.SetBool(.Show3DPrimeMeridians, IsChecked)
                
                case Show3DPolarCirclesCheck:
                    Settings.SetBool(.Show3DPolarCircles, IsChecked)
                
                case Show3DTropicsCheck:
                    Settings.SetBool(.Show3DTropics, IsChecked)
                
                case Show3DEquatorCheck:
                    Settings.SetBool(.Show3DEquator, IsChecked)
                
                default:
                    return
            }
            MainDelegate?.Refresh("MainSettings.Handle3DGridLineChanged")
        }
    }
    
    @IBAction func HandleMovingStarChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowMovingStars, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleMovingStarChanged")
        }
    }
    
    @IBAction func HandleMoonLightChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowMoonLight, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleMoonLightChanged")
        }
    }
    @IBAction func HandleTransparencyChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.indexOfSelectedItem > 3
            {
                Settings.SetDouble(.MinorGrid3DGap, 0.0)
            }
            else
            {
                let Transparency = [0.0, 0.15, 0.35, 0.50][Segment.indexOfSelectedItem]
                Settings.SetDouble(.GlobeTransparencyLevel, Transparency)
            }
            MainDelegate?.Refresh("MainSettings.HandleTransparencyChanged")
        }
    }
    
    @IBAction func HandleGridGapChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.indexOfSelectedItem > 3
            {
                Settings.SetDouble(.MinorGrid3DGap, 15.0)
            }
            else
            {
                let Gap = [5.0, 15.0, 30.0, 45.0][Segment.indexOfSelectedItem]
                Settings.SetDouble(.MinorGrid3DGap, Gap)
            }
            MainDelegate?.Refresh("MainSettings.HandleGridGapChanged")
        }
    }
    
    @IBAction func HandlePoleShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let RawPole = Combo.objectValueOfSelectedItem as? String
            {
                if let Pole = PolarShapes(rawValue: RawPole)
                {
                    Settings.SetEnum(Pole, EnumType: PolarShapes.self, ForKey: .PolarShape)
                    MainDelegate?.Refresh("MainSettings.HandlePoleShapeChanged")
                }
            }
        }
    }
    
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
    
    func InitializeCitySettingsUI()
    {
        ShowCitiesCheck.state = Settings.GetBool(.ShowCities) ? .on : .off
        ShowCapitalCitiesSwitch.state = Settings.GetBool(.ShowCapitalCities) ? .on : .off
        ShowWorldCitiesSwitch.state = Settings.GetBool(.ShowWorldCities) ? .on : .off
        ShowAfricanCitiesSwitch.state = Settings.GetBool(.ShowAfricanCities) ? .on : .off
        ShowAsianCitiesSwitch.state = Settings.GetBool(.ShowAsianCities) ? .on : .off
        ShowEuropeanCitiesSwitch.state = Settings.GetBool(.ShowEuropeanCities) ? .on : .off
        ShowNorthAmericanCitiesSwitch.state = Settings.GetBool(.ShowNorthAmericanCities) ? .on : .off
        ShowSouthAmericanCitiesSwitch.state = Settings.GetBool(.ShowSouthAmericanCities) ? .on : .off
        CityShapeCombo.removeAllItems()
        for Shape in CityDisplayTypes.allCases
        {
            CityShapeCombo.addItem(withObjectValue: Shape.rawValue)
        }
        let CurrentShape = Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .UniformEmbedded)
        CityShapeCombo.selectItem(withObjectValue: CurrentShape.rawValue)
        let PopType = Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self, Default: .City)
        if PopType == .City
        {
            PopulationSegment.selectedSegment = 0
        }
        else
        {
            PopulationSegment.selectedSegment = 1
        }
    }
    
    @IBAction func ShowCitiesChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowCities, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.ShowCitiesChanged")
        }
    }
    
    @IBAction func HandleCityShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Final = CityDisplayTypes(rawValue: Raw)
                {
                    Settings.SetEnum(Final, EnumType: CityDisplayTypes.self, ForKey: .CityShapes)
                }
            }
        }
    }
    
    @IBAction func HandlePopulationTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.indexOfSelectedItem == 0
            {
                Settings.SetEnum(.City, EnumType: PopulationTypes.self, ForKey: .PopulationType)
                MainDelegate?.Refresh("MainSettings.HandlePopulationTypeChanged")
                return
            }
            if Segment.indexOfSelectedItem == 1
            {
                Settings.SetEnum(.Metropolitan, EnumType: PopulationTypes.self, ForKey: .PopulationType)
                MainDelegate?.Refresh("MainSettings.HandlePopulationTypeChanged")
                return
            }
        }
    }
    
    @IBAction func HandleCityColorsPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "CityColorWindow") as? CityColorWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
            if let WinCon = Window?.contentViewController as? CityColorCode
            {
                WinCon.MainDelegate = MainDelegate
            }
        }
    }
    
    @IBAction func HandleShowCityTypeChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            let IsChecked = Button.state == .on ? true : false
            switch Button
            {
                case ShowCapitalCitiesSwitch:
                    Settings.SetBool(.ShowCapitalCities, IsChecked)
                
                case ShowSouthAmericanCitiesSwitch:
                    Settings.SetBool(.ShowSouthAmericanCities, IsChecked)
                
                case ShowNorthAmericanCitiesSwitch:
                    Settings.SetBool(.ShowNorthAmericanCities, IsChecked)
                
                case ShowEuropeanCitiesSwitch:
                    Settings.SetBool(.ShowEuropeanCities, IsChecked)
                
                case ShowAsianCitiesSwitch:
                    Settings.SetBool(.ShowAsianCities, IsChecked)
                
                case ShowAfricanCitiesSwitch:
                    Settings.SetBool(.ShowAfricanCities, IsChecked)
                
                case ShowWorldCitiesSwitch:
                    Settings.SetBool(.ShowWorldCities, IsChecked)
                
                default:
                    return
            }
            MainDelegate?.Refresh("MainSettings.HandleShowCityTypeChanged")
        }
    }
    
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
    
    func InitializeUserLocationUI()
    {
        UserLocations = Settings.GetLocations()
        UserLocationTable.reloadData()
        UserLocationLatitudeBox.delegate = self
        UserLocationLongitudeBox.delegate = self
        ShowUserLocationsCheck.state = Settings.GetBool(.ShowUserLocation) ? .on : .off
        UserTimeZoneOffsetCombo.removeAllItems()
        for Offset in -12 ... 14
        {
            var OffsetValue = "\(Offset)"
            if Offset > 0
            {
                OffsetValue = "+" + OffsetValue
            }
            UserTimeZoneOffsetCombo.addItem(withObjectValue: OffsetValue)
        }
        if Settings.HaveLocalLocation()
        {
            let UserLat = Settings.GetDoubleNil(.LocalLatitude, 0.0)!
            let UserLon = Settings.GetDoubleNil(.LocalLongitude, 0.0)!
            UserLocationLatitudeBox.stringValue = "\(UserLat.RoundedTo(4))"
            UserLocationLongitudeBox.stringValue = "\(UserLon.RoundedTo(4))"
            let ZoneOffset = Int(Settings.GetDoubleNil(.LocalTimeZoneOffset, 0.0)!)
            var ZoneOffsetString = "\(ZoneOffset)"
            if ZoneOffset > 0
            {
                ZoneOffsetString = "+" + ZoneOffsetString
            }
            UserTimeZoneOffsetCombo.selectItem(withObjectValue: ZoneOffsetString)
        }
        else
        {
            UserLocationLongitudeBox.stringValue = ""
            UserLocationLatitudeBox.stringValue = ""
            UserTimeZoneOffsetCombo.selectItem(withObjectValue: nil)
        }
        let LocalShape = Settings.GetEnum(ForKey: .HomeShape, EnumType: HomeShapes.self, Default: .Hide)
        var HomeShapeIndex = 0
        switch LocalShape
        {
            case .Hide:
                HomeShapeIndex = 0
            
            case .Arrow:
                HomeShapeIndex = 1
            
            case .Flag:
                HomeShapeIndex = 2
            
            case .Pulsate:
                HomeShapeIndex = 3
        }
        HomeLocationShapeSegment.selectedSegment = HomeShapeIndex
    }
    
    var UserLocations = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: NSColor)]()
    
    @IBAction func HandleDeleteCurrentUserLocation(_ sender: Any)
    {
        if CurrentUserLocationIndex < 0
        {
            return
        }
        UserLocations.remove(at: CurrentUserLocationIndex)
        UserLocationTable.reloadData()
        Settings.SetLocations(UserLocations)
        MainDelegate?.Refresh("MainSettings.HandleDeleteCurrentUserLocation")
    }
    
    @IBAction func HandleEditUserLocation(_ sender: Any)
    {
        if CurrentUserLocationIndex < 0
        {
            return
        }
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "UserLocationEditorWindow") as? UserLocationEditorWindow
        {
            AddNewUserLocation = false
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? UserLocationEditorController
            {
                Controller.Delegate = self
                self.view.window?.beginSheet(Window!, completionHandler: nil)
            }
        }
    }
    
    @IBAction func HandleAddUserLocation(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "UserLocationEditorWindow") as? UserLocationEditorWindow
        {
            AddNewUserLocation = true
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? UserLocationEditorController
            {
                Controller.Delegate = self
                self.view.window?.beginSheet(Window!, completionHandler: nil)
            }
        }
    }
    
    var AddNewUserLocation = false
    
    @IBAction func HandleClearUserLocations(_ sender: Any)
    {
        ConfirmMessage = "Do you really want to delete all of your locations?"
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ConfirmDialogWindowCode") as? ConfirmDialogWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? ConfirmDialogCode
            {
                Controller.ConfirmDelegate = self
                self.view.window?.beginSheet(Window!)
                {
                    Response in
                    if Response == .OK
                    {
                        self.UserLocations.removeAll()
                        self.UserLocationTable.reloadData()
                        Settings.SetLocations(self.UserLocations)
                        self.MainDelegate?.Refresh("MainSettings.HandleClearUserLocations")
                    }
                }
            }
            else
            {
                fatalError("Error getting contentViewController")
            }
        }
    }
    
    @IBAction func HandleShowUserLocationsCheckChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowUserLocation, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleShowUserLocationsCheckChanged")
        }
    }
    
    @IBAction func HandleClearHomeLocation(_ sender: Any)
    {
        UserLocationLongitudeBox.stringValue = ""
        UserLocationLatitudeBox.stringValue = ""
        UserTimeZoneOffsetCombo.selectItem(withObjectValue: nil)
        Settings.SetDoubleNil(.LocalLatitude, nil)
        Settings.SetDoubleNil(.LocalLongitude, nil)
        Settings.SetDoubleNil(.LocalTimeZoneOffset, nil)
        MainDelegate?.Refresh("MainSettings.HandleClearUserLocations")
    }
    
    @IBAction func HandleUserTimeZoneOffsetChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let ActualValue = Int(Raw)
                {
                    let DVal = Double(ActualValue)
                    Settings.SetDoubleNil(.LocalTimeZoneOffset, DVal)
                    MainDelegate?.Refresh("MainSettings.HandleUsertimeZoneOffsetChanged")
                }
            }
        }
    }
    
    @IBAction func HandleHomeLocationShapeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var Shape = HomeShapes.Hide
            switch Segment.indexOfSelectedItem
            {
                case 0:
                    Shape = .Hide
                
                case 1:
                    Shape = .Arrow
                
                case 2:
                    Shape = .Flag
                
                case 3:
                    Shape = .Pulsate
                
                default:
                    return
            }
            Settings.SetEnum(Shape, EnumType: HomeShapes.self, ForKey: .HomeShape)
            MainDelegate?.Refresh("MainSettings.HandleHomeLocationShapeChanged")
        }
    }
    
    @IBOutlet weak var HomeLocationShapeSegment: NSSegmentedControl!
    @IBOutlet weak var UserTimeZoneOffsetCombo: NSComboBox!
    @IBOutlet weak var UserLocationTable: NSTableView!
    @IBOutlet weak var UserLocationLongitudeBox: NSTextField!
    @IBOutlet weak var UserLocationLatitudeBox: NSTextField!
    @IBOutlet weak var ShowUserLocationsCheck: NSButton!
    
    // MARK: - Other location settings.
    
    func InitializeOtherLocationUI()
    {
        ShowHeritageSiteCheck.state = Settings.GetBool(.ShowWorldHeritageSites) ? .on : .off
        var Index = 0
        switch Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: SiteTypeFilters.self, Default: .Either)
        {
            case .Either:
                Index = 0
            
            case .Natural:
                Index = 1
            
            case .Cultural:
                Index = 2
            
            case .Both:
                Index = 3
        }
        HeritageSiteSegment.selectedSegment = Index
    }
    
    @IBAction func HandleShowHeritageSiteChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowWorldHeritageSites, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleShowHeritageSiteChanged")
        }
    }
    
    @IBAction func HandleHeritageSiteTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var Index = Segment.indexOfSelectedItem
            if Index > 3
            {
                Index = 0
            }
            let SiteType = [SiteTypeFilters.Either, SiteTypeFilters.Natural, SiteTypeFilters.Cultural,
                            SiteTypeFilters.Both][Index]
            Settings.SetEnum(SiteType, EnumType: SiteTypeFilters.self, ForKey: .WorldHeritageSiteType)
            MainDelegate?.Refresh("MainSettings.HandleHeritageSiteTypeChanged")
        }
    }
    
    @IBOutlet weak var ShowHeritageSiteCheck: NSButton!
    @IBOutlet weak var HeritageSiteSegment: NSSegmentedControl!
    
    // MARK: - Other settings.
    
    func InitializeOtherSettings()
    {
        
        ShowLocalDataCheck.state = Settings.GetBool(.ShowLocalData) ? .on : .off
        ScriptCombo.removeAllItems()
        for Script in Scripts.allCases
        {
            ScriptCombo.addItem(withObjectValue: Script.rawValue)
        }
        let CurrentScript = Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
        ScriptCombo.selectItem(withObjectValue: CurrentScript.rawValue)
    }
    
    @IBAction func HandleShowLocalDataCheckChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowLocalData, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleShowLocalDataCheckChanged")
        }
    }
    
    @IBAction func HandleScriptComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Final = Scripts(rawValue: Raw)
                {
                    Settings.SetEnum(Final, EnumType: Scripts.self, ForKey: .Script)
                    MainDelegate?.Refresh("MainSettings.HandleScriptComboChanged")
                }
            }
        }
    }
    
    @IBOutlet weak var ScriptCombo: NSComboBox!
    @IBOutlet weak var ShowLocalDataCheck: NSButton!
    
    // MARK: - Common code.
    
    func ValidateText(_ Raw: String, IsLongitude: Bool, GoodValue: inout Double) -> Bool
    {
        if let RawValue = Double(Raw)
        {
            if IsLongitude
            {
                if RawValue < -180.0 || RawValue > 180.0
                {
                    return false
                }
                GoodValue = RawValue
                return true
            }
            else
            {
                if RawValue < -90.0 || RawValue > 90.0
                {
                    return false
                }
                GoodValue = RawValue
                return true
            }
        }
        GoodValue = 0.0
        return false
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let TextValue = TextField.stringValue
            var GoodValue: Double = 0.0
            switch TextField
            {
                case UserLocationLongitudeBox:
                    if ValidateText(TextValue, IsLongitude: true, GoodValue: &GoodValue)
                    {
                        Settings.SetDoubleNil(.LocalLongitude, GoodValue)
                        MainDelegate?.Refresh("MainSettings.controlTextDidEndEditing")
                    }
                    else
                    {
                        TextField.stringValue = ""
                }
                
                case UserLocationLatitudeBox:
                    if ValidateText(TextValue, IsLongitude: false, GoodValue: &GoodValue)
                    {
                        Settings.SetDoubleNil(.LocalLatitude, GoodValue)
                        MainDelegate?.Refresh("MainSettings.controlTextDidEndEditing")
                    }
                    else
                    {
                        TextField.stringValue = ""
                }
                
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        MainDelegate?.Refresh("MainSettings")
        self.view.window?.close()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case UserLocationTable:
                return UserLocations.count
            
            case SunSelector:
                return SunImageList.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        switch tableView
        {
            case SunSelector:
                return 65.0
            
            default:
                return 22.0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = "" 
        switch tableView
        {
            case UserLocationTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "NameColumn"
                    CellContents = UserLocations[row].Name
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "LocationColumn"
                    let Loc = "\(UserLocations[row].Coordinates.Latitude.RoundedTo(3)), \(UserLocations[row].Coordinates.Longitude.RoundedTo(3))"
            }
            
            case SunSelector:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "SunNameColumn"
                    CellContents = SunImageList[row].0.rawValue
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    let SunView = NSImageView(image: SunImageList[row].1)
                    return SunView
            }
            
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            switch Table
            {
                case UserLocationTable:
                    CurrentUserLocationIndex = Table.selectedRow
                
                case SunSelector:
                    let SelectedSun = SunImageList[Table.selectedRow].0
                    Settings.SetEnum(SelectedSun, EnumType: SunNames.self, ForKey: .SunType)
                    MainDelegate?.Refresh("MainSettings.HandleTableClicked")
                
                default:
                    return
            }
        }
    }
    
    var CurrentUserLocationIndex = -1
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return SunImageList.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        return NSCollectionViewItem()
    }
    
    // MARK: - Location delegate protocol functions.
    
    func AddNewLocation() -> Bool
    {
        return AddNewUserLocation
    }
    
    func GetLocationToEdit() -> (Name: String, Latitude: Double, Longitude: Double, Color: NSColor)
    {
        if CurrentUserLocationIndex < 0
        {
            return ("", 0.0, 0.0, NSColor.black)
        }
        return (UserLocations[CurrentUserLocationIndex].Name,
                UserLocations[CurrentUserLocationIndex].Coordinates.Latitude,
                UserLocations[CurrentUserLocationIndex].Coordinates.Longitude,
                UserLocations[CurrentUserLocationIndex].Color)
    }
    
    func SetEditedLocation(Name: String, Latitude: Double, Longitude: Double, Color: NSColor, IsValid: Bool)
    {
        if IsValid
        {
            if AddNewUserLocation
            {
                UserLocations.append((UUID(), GeoPoint2(Latitude, Longitude), Name, Color))
            }
            else
            {
                if CurrentUserLocationIndex >= 0
                {
                    UserLocations[CurrentUserLocationIndex].Name = Name
                    UserLocations[CurrentUserLocationIndex].Coordinates.Latitude = Latitude
                    UserLocations[CurrentUserLocationIndex].Coordinates.Longitude = Longitude
                    UserLocations[CurrentUserLocationIndex].Color = Color
                }
            }
            Settings.SetLocations(UserLocations)
            MainDelegate?.Refresh("MainSettings.SetEditedLocation")
        }
    }
    
    func CancelEditing()
    {
    }
    
    // MARK: - Confirmation protocol functions.
    
    func GetConfirmationMessage(ID: UUID) -> String
    {
        return ConfirmMessage
    }
    
    var ConfirmMessage = ""
    
    func GetButtonTitle(_ ForButton: ConfirmationButtons, ID: UUID) -> String?
    {
        switch ForButton
        {
            case .LeftButton:
                return "OK"
            
            case .RightButton:
                return "No"
        }
    }
    
    func GetInstanceID() -> UUID
    {
        return UUID()
    }
    
    func HandleButtonPressed(PressedButton: ConfirmationButtons, ID: UUID)
    {
    }
}
