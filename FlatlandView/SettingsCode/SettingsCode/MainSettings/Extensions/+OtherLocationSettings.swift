//
//  +OtherLocationSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
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
}
