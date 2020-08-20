//
//  OtherLocationsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class OtherLocationsWindow: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeOtherLocationUI()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func InitializeOtherLocationUI()
    {
        ShowHeritageSiteSwitch.state = Settings.GetBool(.ShowWorldHeritageSites) ? .on : .off
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
        ShowAs2D.state = Settings.GetBool(.PlotSitesAs2D) ? .on : .off
    }
    
    @IBAction func HandleShowHeritageSiteChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.ShowWorldHeritageSites, Button.state == .on ? true : false)
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
        }
    }
    
    @IBAction func HandleShowAs2DChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.PlotSitesAs2D, Switch.state == .on ? true : false)
        }
    }
    
    @IBOutlet weak var ShowAs2D: NSSwitch!
    @IBOutlet weak var HeritageSiteSegment: NSSegmentedControl!
    @IBOutlet weak var ShowHeritageSiteSwitch: NSSwitch!
}
