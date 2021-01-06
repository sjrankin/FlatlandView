//
//  LiveDataStatusController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/5/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LiveDataStatusController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                                WindowManagement
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DataSelectionSegment.selectedSegment = 0
    }
    
    override func viewDidLayout()
    {
        LoadData()
    }
    
    func LoadData()
    {
        TableData.removeAll()
        switch DataSelectionSegment.selectedSegment
        {
            case 0:
                var Enabled = ""
                if Settings.GetBool(.EnableEarthquakes)
                {
                    Enabled = "True"
                }
                else
                {
                    Enabled = "False"
                }
                AddData("Earthquakes Enabled", Enabled)
                AddData("Source", "United States Geologic Service")
                AddData("URL", "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
                let Seconds = Settings.GetDouble(.EarthquakeFetchInterval, 0.0)
                if Seconds > 0.0
                {
                    AddData("Retrieval Frequency", "\(Seconds) seconds")
                }
                AddData("Call Count", "\(USGS.CallCount)")
                AddData("Total Duration", "\(USGS.TotalDuration.RoundedTo(2)) seconds")
                if USGS.CallCount > 0
                {
                    var MeanDuration = USGS.TotalDuration / Double(USGS.CallCount)
                    MeanDuration = MeanDuration.RoundedTo(1)
                    AddData("Mean Duration", "\(MeanDuration) seconds")
                }
                AddData("Total Quakes Retrieved", "\(USGS.TotalRetrieved)")
                if USGS.CallCount > 0
                {
                    var Mean: Double = Double(USGS.TotalRetrieved) / Double(USGS.CallCount)
                    Mean = Mean.RoundedTo(1)
                    AddData("Mean Quakes per Call", "\(Mean)")
                }
                AddData("Parse Error Count", "\(USGS.ParseErrorCount)")
                AddData("Response Error Count", "\(USGS.ResponseErrorCount)")
                AddData("Time-Out Count", "\(USGS.TimeOutCount)")
                let Cached = Settings.GetCachedEarthquakes()
                AddData("Cached Quake Count", "\(Cached.count)")
                if USGS.CallCount > 0 && USGS.TotalRetrieved > 0
                {
                    for Mag in 0 ... 10
                    {
                        let MagTitle = ["0 - 1", "1 - 2", "2 - 3", "3 - 4", "4 - 5", "5 - 6", "6 - 7", "7 - 8", "8 - 9", "9 - 10", "10+"][Mag]
                        if let MagTotal = USGS.MagDistribution[Mag]
                        {
                            var MagMean = Double(MagTotal) / Double(USGS.CallCount)
                            MagMean = MagMean.RoundedTo(2)
                            var MagPercent = (MagMean / Double(USGS.TotalRetrieved) * 100.0)
                            MagPercent = MagPercent.RoundedTo(2)
                            AddData("Range \(MagTitle)", "\(MagMean) (\(MagPercent)%)")
                        }
                    }
                }
                
            case 1:
                break
                
            default:
                break
        }
        StatusView.reloadData()
    }
    
    func AddData(_ Key: String, _ Value: String)
    {
        let NewRow = KVPType()
        NewRow.KeyName = Key
        NewRow.ValueContents = Value
        TableData.append(NewRow)
    }
    
    @objc dynamic var TableData = [KVPType]()
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleRefreshButtonPressed(_ sender: Any)
    {
        LoadData()
    }
    
    @IBAction func HandleDataSelectionChanged(_ sender: Any)
    {
        LoadData()
    }
    
    @IBOutlet weak var StatusView: NSTableView!
    @IBOutlet weak var DataSelectionSegment: NSSegmentedControl!
}

@objcMembers class KVPType: NSObject
{
    dynamic var KeyName: String = ""
    dynamic var ValueContents: String = ""
}
