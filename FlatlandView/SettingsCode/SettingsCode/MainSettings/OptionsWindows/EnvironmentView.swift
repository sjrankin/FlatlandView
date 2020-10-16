//
//  EnvironmentView.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EnvironmentView:  NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
        PopulateSelector()
    }
    
    func PopulateSelector()
    {
        Selections.removeAll()
        SelectorTable.reloadData()
        Selections.append(Selectors.System.rawValue)
        Selections.append(Selectors.CPU.rawValue)
        Selections.append(Selectors.GPU.rawValue)
        Selections.append(Selectors.OS.rawValue)
        Selections.append(Selectors.Flatland.rawValue)
        Selections.append(Selectors.Bundle.rawValue)
        Selections.append(Selectors.Runtime.rawValue)
        Selections.append(Selectors.Legal.rawValue)
        SelectorTable.reloadData()
        let SelectedSet = IndexSet(integer: 0)
        SelectorTable.selectRowIndexes(SelectedSet, byExtendingSelection: false)
        PopulateTables()
    }
    
    var Selections = [String]()
    
    func PopulateTables()
    {
        let SelectedIndex = SelectorTable.selectedRow
        let Selected = Selectors.allCases[SelectedIndex]
        DataLabel.stringValue = Selected.rawValue
        switch Selected
        {
            case .System:
                PopulateWithSystem()
                
            case .CPU:
                PopulateWithCPU()
                
            case .GPU:
                PopulateWithGPU()
                
            case .OS:
                PopulateWithOS()
                
            case .Flatland:
                PopulateWithFlatland()
                
            case .Bundle:
                PopulateWithBundle()
                
            case .Runtime:
                PopulateWithRuntime()
                
            case .Legal:
                PopulateWithLegal()
        }
    }
    
    var PrimaryData = [(Key: String, Value: String)]()
    
    func PopulateWithSystem()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        let Model = LowLevel.QueryFor(.HWModel)
        PrimaryData.append((Key: "Model", Value: Model))
        if let (Computer, Size, When) = LowLevel.MacIdentifier(From: Model)
        {
            PrimaryData.append((Key: "Computer", Value: Computer))
            PrimaryData.append((Key: "Display Size", Value: "\(Size) inches"))
            PrimaryData.append((Key: "Released", Value: When))
        }
        let Screens = NSScreen.screens
        if Screens.count == 1
        {
            let ScreenFrame = Screens[0].frame
            let ScreenRes = "\(Int(ScreenFrame.width)) x \(Int(ScreenFrame.height))"
            PrimaryData.append((Key: "Screen Resolution", Value: ScreenRes))
            let Scale = Screens[0].backingScaleFactor
            PrimaryData.append((Key: "Screen Scale Factor", Value: "\(Scale)"))
            PrimaryData.append((Key: "Screen Bits/Pixel", Value: "\(Screens[0].depth.bitsPerPixel)"))
            if let CSName = Screens[0].depth.colorSpaceName
            {
                PrimaryData.append((Key: "Screen Colorspace", Value: "\(CSName.rawValue)"))
            }
        }
        else
        {
            var Index = 1
            PrimaryData.append((Key: "Detected Screens", Value: "\(Screens.count)"))
            for Screen in Screens
            {
                let ScreenFrame = Screen.frame
                let ScreenRes = "\(Int(ScreenFrame.width)) x \(Int(ScreenFrame.height))"
                PrimaryData.append((Key: "Screen \(Index) Resolution", Value: ScreenRes))
                let Scale = Screen.backingScaleFactor
                PrimaryData.append((Key: "Screen \(Index) Scale Factor", Value: "\(Scale)"))
                PrimaryData.append((Key: "Screen \(Index) Bits/Pixel", Value: "\(Screen.depth.bitsPerPixel)"))
                if let CSName = Screen.depth.colorSpaceName
                {
                    PrimaryData.append((Key: "Screen \(Index) Colorspace", Value: "\(CSName.rawValue)"))
                }
                Index = Index + 1
            }
        }
        let TotalRAM = LowLevel.NumericQuery(For: .HWMemSize)
        let RamValue = TotalRAM.Delimited()
        PrimaryData.append((Key: "Total RAM", Value: RamValue))
        let (UsedRAM, FreeRAM) = LowLevel.RAMSize()
        let UsedPercent = Double(UsedRAM) / Double(TotalRAM) * 100.0
        let FreePercent = Double(FreeRAM) / Double(TotalRAM) * 100.0
        PrimaryData.append((Key: "Used RAM", Value: "\(UsedRAM.Delimited())\t\t(\(UsedPercent.RoundedTo(2))%)"))
        PrimaryData.append((Key: "Free RAM", Value: "\(FreeRAM.Delimited())\t\t(\(FreePercent.RoundedTo(2))%)"))
        PrimaryTable.reloadData()
    }
    
    func PopulateWithCPU()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        PrimaryData.append((Key: "CPU Vendor", Value: LowLevel.QueryFor(.CPUVendor)))
        PrimaryData.append((Key: "CPU Type", Value: LowLevel.QueryFor(.HWCPUType)))
        PrimaryData.append((Key: "CPU Brand", Value: LowLevel.QueryFor(.CPUBrandString)))
        PrimaryData.append((Key: "Physical CPUs", Value: LowLevel.QueryFor(.HWCPUCount)))
        PrimaryData.append((Key: "Logical CPUs", Value: LowLevel.QueryFor(.HWLogicalCPUCount)))
        PrimaryData.append((Key: "CPU Threads", Value: LowLevel.QueryFor(.CPUThreadCount)))
        PrimaryData.append((Key: "CPU Clock", Value: LowLevel.QueryFor(.KernelClockRate)))
        let Is64Bit = LowLevel.NumericQuery(For: .HWCPU64Bit) != 0 ? true : false
        PrimaryData.append((Key: "64-bit", Value: "\(Is64Bit)"))
        PrimaryData.append((Key: "Cache Line Size", Value: LowLevel.QueryFor(.HWCacheLineSize)))
        PrimaryData.append((Key: "CPU Thermal Level", Value: LowLevel.QueryFor(.CPUThermalLevel)))
        PrimaryTable.reloadData()
    }
    
    func PopulateWithGPU()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        let MetalDevices = LowLevel.MetalGPUs()
        if MetalDevices.count == 1
        {
            PrimaryData.append((Key: "GPU", Value: MetalDevices[0]))
        }
        else
        {
            var Index = 1
            for MetalDevice in MetalDevices
            {
                PrimaryData.append((Key: "GPU \(Index)", Value: MetalDevice))
                Index = Index + 1
            }
        }
        PrimaryData.append((Key: "Allocated GPU Memory", Value: LowLevel.MetalAllocatedSpace()))
        PrimaryData.append((Key: "GPU Thermal Level", Value: LowLevel.QueryFor(.GPUThermalLevel)))
        PrimaryTable.reloadData()
    }
    
    func PopulateWithBundle()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        if let ProdName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        {
            PrimaryData.append((Key: "Bundle Product Name", ProdName))
        }
        if let ExeName = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
        {
            PrimaryData.append((Key: "Bundle Executable", ExeName))
        }
        if let BundVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            PrimaryData.append((Key: "Bundle Version", BundVer))
        }
        if let BundBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            PrimaryData.append((Key: "Bundle Build", BundBuild))
        }
        if let MinSys = Bundle.main.infoDictionary?["LSMinimumSystemVersion"] as? String
        {
            PrimaryData.append((Key: "Minimum System", MinSys))
        }
        PrimaryTable.reloadData()
    }
    
    func PopulateWithFlatland()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        let Parts = Versioning.MakeVersionParts()
        for Part in Parts
        {
            PrimaryData.append((Key: Part.0, Value: Part.1))
        }
        PrimaryData.append((Key: "Debug Flag", Value: "\(Versioning.CompiledWithDebug())"))
        PrimaryTable.reloadData()
    }
    
    func PopulateWithLegal()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        PrimaryData.append((Key: "Copyright", Value: Versioning.CopyrightText()))
        PrimaryData.append((Key: "Authors", Value: Versioning.AuthorList()))
        PrimaryTable.reloadData()
    }
    
    let ThermalDictionary: [ProcessInfo.ThermalState: String] =
        [
            .critical: "Critical",
            .fair: "Fair",
            .nominal: "Normal",
            .serious: "Serious"
        ]
    
    func PopulateWithOS()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        PrimaryData.append((Key: "OS Version", Value: LowLevel.QueryFor(.KernelOSVersion)))
        PrimaryData.append((Key: "iOS Supported", Value: LowLevel.QueryFor(.KerneliOSSupported)))
        PrimaryTable.reloadData()
    }
    
    func PopulateWithRuntime()
    {
        PrimaryData.removeAll()
        PrimaryTable.reloadData()
        PrimaryData.append((Key: "Host Name", Value: LowLevel.QueryFor(.KernelHostName)))
        let ThermalState = LowLevel.ThermalState()
        let ThermalValue = ThermalDictionary[ThermalState] ?? "Unknown"
        PrimaryData.append((Key: "Thermal", Value: ThermalValue))
        PrimaryTable.reloadData()
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            switch Table
            {
                case SelectorTable:
                    let Row = Table.selectedRow
                    if Row >= 0
                    {
                        LastSelection = Row
                        PopulateTables()
                    }
                    
                default:
                    return
            }
        }
    }
    
    var LastSelection: Int = -1
    
    @IBAction func HandleRefreshButton(_ sender: Any)
    {
        PopulateTables()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case SelectorTable:
                return Selections.count
                
            case PrimaryTable:
                return PrimaryData.count
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        switch tableView
        {
            case PrimaryTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "HardwareKey"
                    CellContents = PrimaryData[row].Key
                }
                else
                {
                    CellIdentifier = "HardwareValue"
                    CellContents = PrimaryData[row].Value
                }
                
            case SelectorTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "SelectionColumn"
                    CellContents = Selections[row]
                }
                
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBOutlet weak var DataLabel: NSTextField!
    @IBOutlet weak var SelectorTable: NSTableView!
    @IBOutlet weak var PrimaryTable: NSTableView!
    
    enum Selectors: String, CaseIterable
    {
        case System = "System"
        case CPU = "CPU"
        case GPU = "GPU"
        case OS = "Operating System"
        case Flatland = "Flatland"
        case Bundle = "Bundle"
        case Runtime = "Runtime"
        case Legal = "Legal"
    }
}
