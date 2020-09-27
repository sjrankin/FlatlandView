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
            .HourFontName: String.self,
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
            .UseHourChamfer: Bool.self,
            .UseLiveDataChamfer: Bool.self,
            .TextSmoothness: CGFloat.self,
            .ShowUserLocations: Bool.self,
            .LocalLatitude: Double?.self,
            .LocalLongitude: Double?.self,
            .LocalName: String.self,
            .LocalTimeZoneOffset: Double?.self,
            .HomeShape: HomeShapes.self,
            .UserLocations: String.self,
            .ShowHomeLocation: Bool.self,
            .HomeColor: NSColor.self,
            .ShowCities: Bool.self,
            .ShowCustomCities: Bool.self,
            .ShowAfricanCities: Bool.self,
            .ShowAsianCities: Bool.self,
            .ShowEuropeanCities: Bool.self,
            .ShowNorthAmericanCities: Bool.self,
            .ShowSouthAmericanCities: Bool.self,
            .ShowCapitalCities: Bool.self,
            .ShowWorldCities: Bool.self,
            .ShowCitiesByPopulation: Bool.self,
            .PopulationRank: Int.self,
            .PopulationRankIsMetro: Bool.self,
            .PopulationFilterValue: Int.self,
            .PopulationFilterGreater: Bool.self,
            .PopulationColor: NSColor.self,
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
            .WorldHeritageSiteType: SiteTypeFilters.self,
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
            .EarthquakeDisplayMagnitude: Int.self,
            .EarthquakeMagnitudeViews: EarthquakeMagnitudeViews.self,
            .CombinedEarthquakeColor: NSColor.self,
            .EarthquakeRegions: String.self,
            .ShowEarthquakeRegions: Bool.self,
            .GeneralMinimumMagnitude: Double.self,
            .PreloadNASATiles: Bool.self,
            .NotifiedEarthquakes: String.self,
            .NotifyLocation: NotificationLocations.self,
            .EnableNASATiles: Bool.self,
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
        ]
}