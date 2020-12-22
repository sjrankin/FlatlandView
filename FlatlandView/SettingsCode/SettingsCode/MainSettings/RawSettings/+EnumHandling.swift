//
//  +EnumHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RawSettingsController
{
    func GetEnumCases() -> [String]
    {
        let Row = SettingsTable.selectedRow
        var CaseList = [String]()
        switch SettingsData[Row].Type
        {
            case "MapTypes":
                CaseList = Utility.EnumCases(EnumType: MapTypes.self)
                
            case "ViewTypes":
                CaseList = Utility.EnumCases(EnumType: ViewTypes.self)
                
            case "HourValueTypes":
                CaseList = Utility.EnumCases(EnumType: HourValueTypes.self)
                
            case "TimeLabels":
                CaseList = Utility.EnumCases(EnumType: TimeLabels.self)
                
            case "Scripts":
                CaseList = Utility.EnumCases(EnumType: Scripts.self)
                
            case "SunNames":
                CaseList = Utility.EnumCases(EnumType: SunNames.self)
                
            case "StarSpeeds":
                CaseList = Utility.EnumCases(EnumType: StarSpeeds.self)
                
            case "PolarShapes":
                CaseList = Utility.EnumCases(EnumType: PolarShapes.self)
                
            case "CameraProjections":
                CaseList = Utility.EnumCases(EnumType: CameraProjections.self)
                
            case "HomeShapes":
                CaseList = Utility.EnumCases(EnumType: HomeShapes.self)
                
            case "CityDisplayTypes":
                CaseList = Utility.EnumCases(EnumType: CityDisplayTypes.self)
                
            case "PopulationTypes":
                CaseList = Utility.EnumCases(EnumType: PopulationTypes.self)
                
            case "SiteTypeFilters":
                CaseList = Utility.EnumCases(EnumType: WorldHeritageSiteTypes.self)
                
            case "EarthquakeColorMethods":
                CaseList = Utility.EnumCases(EnumType: EarthquakeColorMethods.self)
                
            case "EarthquakeShapes":
                CaseList = Utility.EnumCases(EnumType: EarthquakeShapes.self)
                
            case "EarthquakeListStyles":
                CaseList = Utility.EnumCases(EnumType: EarthquakeListStyles.self)
                
            case "EarthquakeRecents":
                CaseList = Utility.EnumCases(EnumType: EarthquakeRecents.self)
                
            case "EarthquakeTextures":
                CaseList = Utility.EnumCases(EnumType: EarthquakeTextures.self)
                
            case "EarthquakeIndicators":
                CaseList = Utility.EnumCases(EnumType: EarthquakeIndicators.self)
                
            case "EarthquakeIndicators2D":
                CaseList = Utility.EnumCases(EnumType: EarthquakeIndicators2D.self)
                
            case "EarthquakeMagnitudeViews":
                CaseList = Utility.EnumCases(EnumType: EarthquakeMagnitudeViews.self)
                
            case "NotificationLocations":
                CaseList = Utility.EnumCases(EnumType: NotificationLocations.self)
                
            case "SettingGroups":
                CaseList = Utility.EnumCases(EnumType: SettingGroups.self)
                
            case "TimeControls":
                CaseList = Utility.EnumCases(EnumType: TimeControls.self)
                
            default:
                return [String]()
        }
        return CaseList
    }
    
    func GetEnumValue(_ EnumType: String) -> String?
    {
        switch EnumType
        {
            case "MapTypes":
                let Actual = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Standard)
                return "\(Actual)"
                
            case "ViewTypes":
                let Actual = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
                return "\(Actual)"
                
            case "HourValueTypes":
                let Actual = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .Solar)
                return "\(Actual)"
                
            case "TimeLabels":
                let Actual = Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .UTC)
                return "\(Actual)"
                
            case "Scripts":
                let Actual = Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
                return "\(Actual)"
                
            case "SunNames":
                let Actual = Settings.GetEnum(ForKey: .SunType, EnumType: SunNames.self, Default: .PlaceHolder)
                return "\(Actual)"
                
            case "StarSpeeds":
                let Actual = Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
                return "\(Actual)"
                
            case "PolarShapes":
                let Actual = Settings.GetEnum(ForKey: .PolarShape, EnumType: PolarShapes.self, Default: .Pole)
                return "\(Actual)"
                
            case "CameraProjections":
                let Actual = Settings.GetEnum(ForKey: .CameraProjection, EnumType: CameraProjections.self,
                                              Default: .Perspective)
                return "\(Actual)"
                
            case "HomeShapes":
                let Actual = Settings.GetEnum(ForKey: .HomeShape, EnumType: HomeShapes.self, Default: .Pulsate)
                return "\(Actual)"
                
            case "CityDisplayTypes":
                let Actual = Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .RelativeFloatingSpheres)
                return "\(Actual)"
                
            case "PopulationTypes":
                let Actual = Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self,
                                              Default: .Metropolitan)
                return "\(Actual)"
                
            case "SiteTypeFilters":
                let Actual = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self,
                                              Default: .Natural)
                return "\(Actual)"
                
            case "EarthquakeColorMethods":
                let Actual = Settings.GetEnum(ForKey: .ColorDetermination, EnumType: EarthquakeColorMethods.self,
                                              Default: .Magnitude)
                return "\(Actual)"
                
            case "EarthquakeShapes":
                let Actual = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self,
                                              Default: .Arrow)
                return "\(Actual)"
                
            case "EarthquakeListStyles":
                let Actual = Settings.GetEnum(ForKey: .EarthquakeListStyle, EnumType: EarthquakeListStyles.self,
                                              Default: .Clustered)
                return "\(Actual)"
                
            case "EarthquakeRecents":
                let Actual = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                              Default: .Day7)
                return "\(Actual)"
                
            case "EarthquakeTextures":
                let Actual = Settings.GetEnum(ForKey: .EarthquakeTextures, EnumType: EarthquakeTextures.self,
                                              Default: .Gradient1)
                return "\(Actual)"
                
            case "EarthquakeIndicators":
                let Actual = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self,
                                              Default: .TriangleRingIn)
                return "\(Actual)"
                
            case "EarthquakeIndicators2D":
                let Actual = Settings.GetEnum(ForKey: .Earthquake2DStyles, EnumType: EarthquakeIndicators2D.self,
                                              Default: .Ring)
                return "\(Actual)"
                
            case "EarthquakeMagnitudeViews":
                let Actual = Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self,
                                              Default: .Stenciled)
                return "\(Actual)"
                
            case "NotificationLocations":
                let Actual = Settings.GetEnum(ForKey: .NotifyLocation, EnumType: NotificationLocations.self,
                                              Default: .Flatland)
                return "\(Actual)"
                
            case "SettingGroups":
                let Actual = Settings.GetEnum(ForKey: .LastSettingsViewed, EnumType: SettingGroups.self,
                                              Default: .Map3D)
                return "\(Actual)"
                
            case "TimeControls":
                let Actual = Settings.GetEnum(ForKey: .TimeControl, EnumType: TimeControls.self, Default: .Run)
                return "\(Actual)"
                
            default:
                return nil
        }
    }
    
    func SetEnumValue(_ SettingKey: SettingKeys, _ AsString: String)
    {
        switch SettingKey
        {
            case .MapType:
                if let Value = MapTypes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: MapTypes.self, ForKey: .MapType)
                }
                
            case .ViewType:
                if let Value = ViewTypes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: ViewTypes.self, ForKey: .ViewType)
                }
                
            case .HourType:
                if let Value = HourValueTypes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: HourValueTypes.self, ForKey: .HourType)
                }
                
            case .TimeLabel:
                if let Value = TimeLabels(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: TimeLabels.self, ForKey: .TimeLabel)
                }
                
            case .Script:
                if let Value = Scripts(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: Scripts.self, ForKey: .Script)
                }
                
            case .SunType:
                if let Value = SunNames(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: SunNames.self, ForKey: .SunType)
                }
                
            case .StarSpeeds:
                if let Value = StarSpeeds(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                }
                
            case .PolarShape:
                if let Value = PolarShapes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: PolarShapes.self, ForKey: .PolarShape)
                }
                
            case .CameraProjection:
                if let Value = CameraProjections(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: CameraProjections.self, ForKey: .CameraProjection)
                }
                
            case .HomeShape:
                if let Value = HomeShapes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: HomeShapes.self, ForKey: .HomeShape)
                }
                
            case .CityShapes:
                if let Value = CityDisplayTypes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: CityDisplayTypes.self, ForKey: .CityShapes)
                }
                
            case .PopulationType:
                if let Value = PopulationTypes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: PopulationTypes.self, ForKey: .PopulationType)
                }
                
            case .WorldHeritageSiteType:
                if let Value = WorldHeritageSiteTypes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: WorldHeritageSiteTypes.self, ForKey: .WorldHeritageSiteType)
                }
                
            case .ColorDetermination:
                if let Value = EarthquakeColorMethods(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeColorMethods.self, ForKey: .ColorDetermination)
                }
                
            case .EarthquakeShapes:
                if let Value = EarthquakeShapes(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                }
                
            case .EarthquakeListStyle:
                if let Value = EarthquakeListStyles(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeListStyles.self, ForKey: .EarthquakeListStyle)
                }
                
            case .RecentEarthquakeDefinition:
                if let Value = EarthquakeRecents(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeRecents.self, ForKey: .RecentEarthquakeDefinition)
                }
                
            case .EarthquakeTextures:
                if let Value = EarthquakeTextures(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeTextures.self, ForKey: .EarthquakeTextures)
                }
                
            case .EarthquakeStyles:
                if let Value = EarthquakeIndicators(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                }
                
            case .Earthquake2DStyles:
                if let Value = EarthquakeIndicators2D(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeIndicators2D.self, ForKey: .Earthquake2DStyles)
                }
                
            case .EarthquakeMagnitudeViews:
                if let Value = EarthquakeMagnitudeViews(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: EarthquakeMagnitudeViews.self, ForKey: .EarthquakeMagnitudeViews)
                }
                
            case .NotifyLocation:
                if let Value = NotificationLocations(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: NotificationLocations.self, ForKey: .NotifyLocation)
                }
                
            case .LastSettingsViewed:
                if let Value = SettingGroups(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: SettingGroups.self, ForKey: .LastSettingsViewed)
                }
                
            case .TimeControl:
                if let Value = TimeControls(rawValue: AsString)
                {
                    Settings.SetEnum(Value, EnumType: TimeControls.self, ForKey: .TimeControl)
                }
                
            default:
                return
        }
    }
    
}
