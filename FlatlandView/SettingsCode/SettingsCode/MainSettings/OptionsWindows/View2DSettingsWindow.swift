//
//  View2DSettingsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class View2DSettingsWindow: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Initialize2DMap()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
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
    
    @IBAction func HandleShow2DNightChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
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
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return SunImageList.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 65.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
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
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            let SelectedSun = SunImageList[Table.selectedRow].0
            Settings.SetEnum(SelectedSun, EnumType: SunNames.self, ForKey: .SunType)
        }
    }
    
    @IBOutlet weak var Show2DNoonMeridians: NSSwitch!
    @IBOutlet weak var Show2DPolarCircles: NSSwitch!
    @IBOutlet weak var Show2DPrimeMeridians: NSSwitch!
    @IBOutlet weak var Show2DTropics: NSSwitch!
    @IBOutlet weak var Show2DEquator: NSSwitch!
    @IBOutlet weak var SunSelector: NSTableView!
    @IBOutlet weak var Show2DNight: NSSwitch!
    @IBOutlet weak var NightDarknessSegment: NSSegmentedControl!
}
