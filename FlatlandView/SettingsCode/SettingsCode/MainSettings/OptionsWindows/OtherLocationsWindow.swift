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
        switch Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self, Default: .AllSites)
        {
            case .AllSites:
                Index = 0
            
            case .Natural:
                Index = 1
            
            case .Cultural:
                Index = 2
            
            case .Mixed:
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
            var Index = Segment.selectedSegment
            if Index > 3
            {
                Index = 0
            }
            let SiteType = [WorldHeritageSiteTypes.AllSites, WorldHeritageSiteTypes.Natural, WorldHeritageSiteTypes.Cultural,
                            WorldHeritageSiteTypes.Mixed][Index]
            Settings.SetEnum(SiteType, EnumType: WorldHeritageSiteTypes.self, ForKey: .WorldHeritageSiteType)
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
