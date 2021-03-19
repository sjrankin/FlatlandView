//
//  SettingKeysMap.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension Settings
{
    /// Map between a setting key and the type of data it stores.
    public static let SettingKeyTypes: [SettingKeys: Any] =
        [
            .InitializationFlag: Bool.self,
            .InAttractMode: Bool.self,
            .MapType: MapTypes.self,
            .ViewType: ViewTypes.self,
            .ShowNight: Bool.self,
            .NightMaskAlpha: Double.self,
            .NightDarkness: NightDarknesses.self,
            .HourType: HourValueTypes.self,
            .TimeLabel: TimeLabels.self,
            .TimeLabelSeconds: Bool.self,
            .ShowSun: Bool.self,
            .Script: Scripts.self,
            .SunType: SunNames.self,
            .SampleViewType: ViewTypes.self,
            .POIScale: MapNodeScales.self,
            .Show2DEquator: Bool.self,
            .Show2DPolarCircles: Bool.self,
            .Show2DTropics: Bool.self,
            .Show2DPrimeMeridians: Bool.self,
            .Show2DNoonMeridians: Bool.self,
            .Show3DGridLines: Bool.self,
            .Show3DEquator: Bool.self,
            .Show3DPolarCircles: Bool.self,
            .Show3DTropics: Bool.self,
            .Show3DPrimeMeridians: Bool.self,
            .Show3DMinorGrid: Bool.self,
            .MinorGrid3DGap: Double.self,
            .GlobeTransparencyLevel: Double.self,
            .StarSpeeds: StarSpeeds.self,
            .ShowMoonLight: Bool.self,
            .PolarShape: PolarShapes.self,
            .ResetHoursPeriodically: Bool.self,
            .ResetHourTimeInterval: Double.self,
            .BackgroundColor3D: NSColor.self,
            .UseAmbientLight: Bool.self,
            .ShowPOIEmission: Bool.self,
            .UseHDRCamera: Bool.self,
            .HourColor: NSColor.self,
            .HourEmissionColor: NSColor.self,
            .HourFontName: String.self,
            .HourScale: MapNodeScales.self,
            .GridLineColor: NSColor.self,
            .MinorGridLineColor: NSColor.self,
            .FieldOfView: CGFloat.self,
            .OrthographicScale: Double.self,
            .ZFar: Double.self,
            .ZNear: Double.self,
            .ClosestZ: CGFloat.self,
            .SphereSegmentCount: Int.self,
            .GridLinesDrawnOnMap: Bool.self,
            .CityNamesDrawnOnMap: Bool.self,
            .MagnitudeValuesDrawnOnMap: Bool.self,
            .EarthquakeRegionBorderColor: NSColor.self,
            .EarthquakeRegionBorderWidth: Double.self,
            .InitialCameraPosition: SCNVector3.self,
            .UseSystemCameraControl: Bool.self,
            .EnableZooming: Bool.self,
            .EnableDragging: Bool.self,
            .EnableMoving: Bool.self,
            .CameraProjection: CameraProjections.self,
            .CameraFieldOfView: CGFloat.self,
            .CameraOrthographicScale: CGFloat.self,
            .ShowWireframes: Bool.self,
            .ShowBoundingBoxes: Bool.self,
            .ShowSkeletons: Bool.self,
            .ShowConstraints: Bool.self,
            .ShowLightInfluences: Bool.self,
            .ShowLightExtents: Bool.self,
            .ShowStatistics: Bool.self,
            .ShowCreases: Bool.self,
            .ShowPhysicsShapes: Bool.self,
            .ShowPhysicsFields: Bool.self,
            .RenderAsWireframe: Bool.self,
            .Debug3DMap: Debug_MapTypes.self,
            .Enable3DDebugging: Bool.self,
            .ShowAxes: Bool.self,
            .UseHourChamfer: Bool.self,
            .UseLiveDataChamfer: Bool.self,
            .TextSmoothness: CGFloat.self,
            .ShowUserLocations: Bool.self,
            .LocalTimeZoneOffset: Double?.self,
            .HomeShape: HomeShapes.self,
            .UserLocations: String.self,
            .ShowHomeLocation: Bool.self,
            .HomeColor: NSColor.self,
            .DailyLocationName: String.self,
            .DailyLocationLatitude: Double?.self,
            .DailyLocationLongitude: Double?.self,
            .ShowCities: Bool.self,
            .ShowCustomCities: Bool.self,
            .ShowAfricanCities: Bool.self,
            .ShowAsianCities: Bool.self,
            .ShowEuropeanCities: Bool.self,
            .ShowNorthAmericanCities: Bool.self,
            .ShowSouthAmericanCities: Bool.self,
            .ShowCapitalCities: Bool.self,
            .ShowAllCities: Bool.self,
            .ShowWorldCities: Bool.self,
            .ShowCitiesByPopulation: Bool.self,
            .PopulationRank: Int.self,
            .PopulationRankIsMetro: Bool.self,
            .PopulationFilterValue: Int.self,
            .PopulationFilterGreater: Bool.self,
            .PopulationColor: NSColor.self,
            .ExtrudedCitiesCastShadows: Bool.self,
            .HoursCastShadows: Bool.self,
            .PopulationFilterType: PopulationFilterTypes.self,
            .AfricanCityColor: NSColor.self,
            .EuropeanCityColor: NSColor.self,
            .AsianCityColor: NSColor.self,
            .NorthAmericanCityColor: NSColor.self,
            .SouthAmericanCityColor: NSColor.self,
            .CapitalCityColor: NSColor.self,
            .WorldCityColor: NSColor.self,
            .CustomCityListColor: NSColor.self,
            .CityShapes: CityDisplayTypes.self,
            .PopulationType: PopulationTypes.self,
            .CityFontName: String.self,
            .CustomCityList: String.self,
            .CityNodesGlow: Bool.self,
            .ShowWorldHeritageSites: Bool.self,
            .WorldHeritageSiteType: WorldHeritageSiteTypes.self,
            .SiteCountry: String.self,
            .SiteYear: Int.self,
            .SiteYearFilter: Int.self,
            .PlotSitesAs2D: Bool.self,
            .EarthquakeFetchInterval: Double.self,
            .EnableEarthquakes: Bool.self,
            .ColorDetermination: EarthquakeColorMethods.self,
            .BaseEarthquakeColor: NSColor.self,
            .EarthquakeShapes: EarthquakeShapes.self,
            .DisplayLargestOnly: Bool.self,
            .EarthquakeRegionRadius: Double.self,
            .EarthquakeMagnitudeColors: String.self,
            .EarthquakeListStyle: EarthquakeListStyles.self,
            .HighlightRecentEarthquakes: Bool.self,
            .RecentEarthquakeDefinition: EarthquakeRecents.self,
            .EarthquakeTextures: EarthquakeTextures.self,
            .EarthquakeStyles: EarthquakeIndicators.self,
            .Earthquake2DStyles: EarthquakeIndicators2D.self,
            .EarthquakeColor: NSColor.self,
            .EarthquakeFontName: String.self,
            .EarthquakeListAge: EarthquakeAges.self,
            .GroupEarthquakeListAge: EarthquakeAges.self,
            .EarthquakeDisplayMagnitude: Int.self,
            .CachedEarthquakes: String.self,
            .QuakeScales: MapNodeScales.self,
            .GroupEarthquakeDisplayMagnitude: Int.self,
            .EarthquakeMagnitudeViews: EarthquakeMagnitudeViews.self,
            .CombinedEarthquakeColor: NSColor.self,
            .EarthquakeRegions: String.self,
            .ShowEarthquakeRegions: Bool.self,
            .GeneralMinimumMagnitude: Double.self,
            .ShowMagnitudeBarCode: Bool.self,
            .PreloadNASATiles: Bool.self,
            .NotifiedEarthquakes: String.self,
            .NotifyLocation: NotificationLocations.self,
            .EnableNASATiles: Bool.self,
            .NASATilesFetchInterval: Int.self,
            .LastNASAFetchTime: Double?.self,
            .LastSettingsViewed: SettingGroups.self,
            .ShowSplashScreen: Bool.self,
            .SplashScreenDuration: Double.self,
            .DebugTime: Bool.self,
            .TimeControl: TimeControls.self,
            .TestTime: Date.self,
            .StopTimeAt: Date.self,
            .TimeMultiplier: Double.self,
            .EnableStopTime: Bool.self,
            .EarthquakeViewWindowFrame: NSRect.self,
            .CityFontRelativeSize: RelativeSizes.self,
            .MagnitudeRelativeFontSize: RelativeSizes.self,
            .StencilPlainText: Bool.self,
            .Show2DShadows: Bool.self,
            .EarthquakeShape2D: QuakeShapes2D.self,
            .WindowSize: NSSize.self,
            .WindowOrigin: CGPoint.self,
            .PrimaryViewSize: NSSize.self,
            .ShowDetailedInformation: Bool.self,
            .HighlightNodeUnderMouse: Bool.self,
            .ShowCamera: Bool.self,
            .DecorateEarthquakeCoordinates: Bool.self,
            .ShowStatusBar: Bool.self,
            .QuakeRegionRadius: Double?.self,
            .QuakeRegionLatitude: Double?.self,
            .QuakeRegionLongitude: Double?.self,
            .QuakeRegionEnable: Bool.self,
            .QuakeSetAll: Bool.self,
            .WorldIsLocked: Bool.self,
            .FollowMouse: Bool.self,
            .ShowKnownLocations: Bool.self,
            .EnableJittering: Bool.self,
            .AntialiasLevel: SceneJitters.self,
            .SearchForLocation: Bool.self,
            .HideMouseOverEarth: Bool.self,
            .InputUnit: InputUnits.self,
            .InterfaceStyle: InterfaceStyles.self,
            .ColorInputType: InputTypes.self,
            .ColorPickerColorspace: PickerColorspaces.self,
            .ShowUserPOIs: Bool.self,
            .ShowUIHelp: Bool.self,
            .ShowBuiltInPOIs: Bool.self,
            // MARK: - Event and sound settings
            .EnableSounds: Bool.self,
            .EnableHourEvent: Bool.self,
            // MARK: - Database-related settings
            .DB_Cities: [City2].self,
            .DB_UserCities: [City2].self,
            .DB_BuiltInPOIs: [POI2].self,
            .DB_UserPOIs: [POI2].self,
            .DB_Homes: [POI2].self,
            .DB_WorldHeritageSites: [WorldHeritageSite].self,
            // MARK: - Debugging settings
            .Debug_EnableClockControl: Bool.self,
            .Debug_ClockDebugMap: Debug_MapTypes.self,
            .Debug_ClockActionFreeze: Bool.self,
            .Debug_ClockActionFreezeAtTime: Bool.self,
            .Debug_ClockActionFreezeTime: Date.self,
            .Debug_ClockActionSetClockAngle: Bool.self,
            .Debug_ClockActionClockAngle: Double.self,
            .Debug_ClockUseTimeMultiplier: Bool.self,
            .Debug_ClockActionClockMultiplier: Double.self,
        ]
    
    /// Contains settings that are stored in secure storage.
    public static let SecureStringKeyTypes: [SettingKeys] =
    [
        .UserHomeLatitude,
        .UserHomeLongitude,
        .UserHomeName
    ]
}
