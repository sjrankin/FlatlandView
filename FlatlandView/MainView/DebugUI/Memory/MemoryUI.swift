//
//  MemoryUI.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MemoryUI: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SampleTimeSegment.selectedSegment = 0
        ReadMemory()
        SampleTable.reloadData()
    }
    
    override func viewDidAppear()
    {
        SampleTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(ReadMemory),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    var Samples: [MemoryFields: (Absolute: UInt64?, Delta: Int64?, SampleTime: Double?)] =
    [
        .PhysicalFootprint: (nil, nil, nil),
        .ResidentSize: (nil, nil, nil),
        .ResidentPeakSize: (nil, nil, nil),
        .Reusable: (nil, nil, nil),
        .ReusablePeak: (nil, nil, nil),
        .PageSize: (nil, nil, nil),
        .VirtualSize: (nil, nil, nil),
        .RegionCount: (nil, nil, nil)
    ]
    var Fields: [MemoryFields] = [.PhysicalFootprint, .ResidentSize, .ResidentPeakSize, .Reusable,
                                  .ReusablePeak, .PageSize, .VirtualSize, .RegionCount]
    var Names: [MemoryFields: String] =
    [
        .PhysicalFootprint: "Physical Footprint",
        .ResidentSize: "Resident",
        .ResidentPeakSize: "Resident Peak",
        .Reusable: "Reusable",
        .ReusablePeak: "Reusable Peak",
        .PageSize: "Page Size",
        .VirtualSize: "Virtual Size",
        .RegionCount: "Region Count"
    ]
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        Fields.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var CellTextColor = NSColor.black
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "MeasurementName"
            let MemoryField = Fields[row]
            if let Name = Names[MemoryField]
            {
            CellContents = Name
            }
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ValueColumn"
            let MemoryField = Fields[row]
            var Actual = ""
            if let ActualValue = Samples[MemoryField]?.Absolute
            {
                if FullValueSwitch.state == .on
                {
                    Actual = ActualValue.Delimited()
                }
                else
                {
                    Actual = ActualValue.WithSuffix()
                }
            }
            else
            {
                Actual = ""
            }
            CellContents = Actual
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "DeltaColumn"
            let MemoryField = Fields[row]
            var Delta = ""
            if var DeltaValue = Samples[MemoryField]?.Delta
            {
                let NegativeDelta = DeltaValue < 0
                if NegativeDelta
                {
                    CellTextColor = NSColor.systemGreen
                }
                else
                {
                    CellTextColor = NSColor.systemRed
                }
                if FullValueSwitch.state == .on
                {
                    Delta = DeltaValue.Delimited()
                }
                else
                {
                    DeltaValue = abs(DeltaValue)
                    Delta = DeltaValue.WithSuffix()
                    if NegativeDelta
                    {
                        Delta = "-" + Delta
                    }
                }
                if Delta.trimmingCharacters(in: .whitespacesAndNewlines) == "0.0"
                {
                    CellTextColor = NSColor.black
                }
            }
            else
            {
                Delta = ""
            }
            CellContents = Delta
        }
        if tableColumn == tableView.tableColumns[3]
        {
            CellIdentifier = "DeltaTimeColumn"
            let MemoryField = Fields[row]
            var DeltaTValue = ""
            if let DeltaT = Samples[MemoryField]?.SampleTime
            {
                let Delta = Int(CACurrentMediaTime() - DeltaT)
                DeltaTValue = "\(Delta) s"
            }
            CellContents = DeltaTValue
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        Cell?.textField?.textColor = CellTextColor
        return Cell
    }
    
    var SampleTimer: Timer? = nil
    
    @IBAction func HandleSampleTimeChanged(_ sender: Any)
    {
        #if false
        if let Segment = sender as? NSSegmentedControl
        {
            if let NewSampleTime = [1.0, 5.0, 30.0, 60.0, 300.0][Segment.selectedSegment]
            {
                SampleTimer = Timer.scheduledTimer(timeInterval: NewSampleTime,
                                                   target: self,
                                                   selector: #selector(ReadMemory),
                                                   userInfo: nil,
                                                   repeats: true)
            }
        }
        #endif
    }
    
    @objc func ReadMemory()
    {
        for Field in Fields
        {
            let Value = LowLevel.MemoryStatistics(Field)
            if Value != nil
            {
                let OldAbsolute = Samples[Field]?.Absolute
                if OldAbsolute == nil
                {
                    Samples[Field] = (Value, nil, CACurrentMediaTime())
                }
                else
                {
                    let OldDelta = Samples[Field]?.Delta
                    var LastChanged = Samples[Field]?.SampleTime
                    let NewDelta = Int64(Value!) - Int64(OldAbsolute!)
                    if OldDelta != nil
                    {
                        let OldDeltaS = Int64(OldDelta!).WithSuffix()
                        let NewDeltaS = Int64(NewDelta).WithSuffix()
                        if OldDeltaS != NewDeltaS
                        {
                            LastChanged = CACurrentMediaTime()
                        }
                    }
                    Samples[Field] = (Value, NewDelta, LastChanged)
                }
            }
        }
        SampleTable.reloadData()
    }
    
    @IBAction func HandleFullValueChanged(_ sender: Any)
    {
        SampleTable.reloadData()
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var FullValueSwitch: NSSwitch!
    @IBOutlet weak var SampleTable: NSTableView!
    @IBOutlet weak var SampleTimeSegment: NSSegmentedControl!
}
