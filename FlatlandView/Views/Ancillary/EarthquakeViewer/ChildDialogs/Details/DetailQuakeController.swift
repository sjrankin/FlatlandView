//
//  DetailQuakeController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DetailQuakeController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    public func SetQuake(_ Quake: Earthquake)
    {
        let Roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
        DataSet.removeAll()
        DataSet.append(("Code", Quake.Code, false))
        DataSet.append(("ID", Quake.EventID, false))
        DataSet.append(("Sequence", "\(Quake.Sequence)", false))
        DataSet.append(("Title", Quake.Title, false))
        DataSet.append(("Alert", Quake.Alert, false))
        var LatString = ""
        var LonString = ""
        if Settings.GetBool(.DecorateEarthquakeCoordinates)
        {
            var LatInd = "N"
            if Quake.Latitude < 0.0
            {
                LatInd = "S"
            }
            LatString = "\(abs(Quake.Latitude.RoundedTo(4))) \(LatInd)"
            var LonInd = "E"
            if Quake.Longitude < 0.0
            {
                LonInd = "W"
            }
            LonString = "\(abs(Quake.Longitude.RoundedTo(4))) \(LonInd)"
        }
        else
        {
            LatString = "\(Quake.Latitude.RoundedTo(4))"
            LonString = "\(Quake.Longitude.RoundedTo(4))"
        }
        DataSet.append(("Latitude", LatString, false))
        DataSet.append(("Longitude", LonString, false))
        DataSet.append(("Horizontal Error", "\(Quake.HorizontalError.RoundedTo(3)) km", false))
        DataSet.append(("Depth", "\(Quake.Depth.RoundedTo(3)) km", false))
        DataSet.append(("Depth Error", "\(Quake.DepthError.RoundedTo(3)) km", false))
        DataSet.append(("Place", Quake.Place, false))
        DataSet.append(("Magnitude", "\(Quake.Magnitude.RoundedTo(3))", false))
        let Intensity = Int(Quake.CDI)
        let IntensityValue = Roman[Intensity]
        DataSet.append(("CDI", "\(IntensityValue) [\(Quake.CDI.RoundedTo(3))]", false))
        DataSet.append(("Greatest Magnitude", "\(Quake.GreatestMagnitude.RoundedTo(3))", true))
        DataSet.append(("Magnitude Type", MakeMagType(From: Quake.MagType), false))
        let MagSourceList = PrettyList(From: Quake.MagSource)
        DataSet.append(("Magnitude Source", MagSourceList, false))
        DataSet.append(("Magnitude Error", "\(Quake.MagError.RoundedTo(3))", false))
        DataSet.append(("MagNST", "\(Quake.MagNST)", false))
        DataSet.append(("Gap", "\(Quake.Gap.RoundedTo(3))", false))
        DataSet.append(("RMS", "\(Quake.RMS.RoundedTo(3))", false))
        DataSet.append(("DMin", "\(Quake.DMin.RoundedTo(3))", false))
        DataSet.append(("NPH", Quake.NPH, false))
        DataSet.append(("IsCluster", "\(Quake.IsCluster)", true))
        DataSet.append(("ClusterCount", "\(Quake.ClusterCount)", true))
        DataSet.append(("Time", Quake.Time.PrettyDateTime(), false))
        if abs(Quake.TZ) < 24
        {
            DataSet.append(("Time Zone", "\(Quake.TZ)", false))
        }
        DataSet.append(("Age", "\(Quake.GetAge().RoundedTo(0)) seconds", true))
        if Quake.Updated.timeIntervalSince1970 > Date().timeIntervalSince1970
        {
            DataSet.append(("Update", "\(Quake.Updated.PrettyDateTime())", false))
        }
        else
        {
            DataSet.append(("Updated", "", false))
        }
        DataSet.append(("Felt", "\(Quake.Felt)", false))
        DataSet.append(("Significance", "\(Quake.Significance)", false))
        DataSet.append(("Tsunami", "\(Quake.Tsunami)", false))
        let MMIR = Roman[Int(Quake.MMI)]
        DataSet.append(("MMI", "\(MMIR) [\(Quake.MMI.RoundedTo(3))]", false))
        DataSet.append(("Status", Quake.Status, false))
        DataSet.append(("Internal ID", Quake.ID.uuidString, true))
        let IDList = PrettyList(From: Quake.IDs)
        DataSet.append(("IDs", IDList, false))
        let SourceList = PrettyList(From: Quake.Sources)
        DataSet.append(("Sources", SourceList, false))
        let LocationList = PrettyList(From: Quake.LocationSource)
        DataSet.append(("Location Source", LocationList, false))
        let NetList = PrettyList(From: Quake.Net)
        DataSet.append(("Net", NetList, false))
        let TypeList = PrettyList(From: Quake.Types)
        DataSet.append(("Types", TypeList, false))
        DataSet.append(("Event Type", Quake.EventType, false))
        DataSet.append(("JSON Details", Quake.Detail, false))
        DataSet.append(("Event Page", Quake.EventPageURL, false))
        
        DetailTable.reloadData()
    }
    
    func MakeMagType(From Raw: String) -> String
    {
        let SwitchOn = Raw.lowercased()
        switch SwitchOn
        {
            case "mww":
                return "Moment W-Phase (MW)"
                
            case "mwc":
                return "Centroid (MWC)"
                
            case "mwb":
                return "Body Wave (MWB)"
                
            case "mwr":
                return "Regional (MWR)"
                
            case "ms20", "ms":
                return "20s Surface Wave (MS20/MS)"
                
            case "mb":
                return "Short-Period Body Wave (MB)"
                
            case "mfa":
                return "Felt Area Magnitude (MFA)"
                
            case "ml mi", "ml":
                return "Local (ML/MI)"
                
            case "mb_lb", "mgl":
                return "Short-Period Surface Wave (mb_Lg/mb_lg/MLg)"
                
            case "md":
                return "Duration (MD/md)"
                
            case "mi", "mwp":
                return "Integrated p-wave (Mi/Mwp)"
                
            case "me":
                return "Energy (Me)"
                
            case "mh":
                return "Non-standard (Mh)"
                
            case "finite fault":
                return "Modeling (Finite Fault)"
                
            case "mint":
                return "Intensity Magnitude (Mint)"
                
            default:
                return "Unknown"
        }
    }
    
    func PrettyList(From: String) -> String
    {
        if From.isEmpty
        {
            return ""
        }
        let Parts = From.split(separator: ",", omittingEmptySubsequences: true)
        var Result = ""
        for Part in Parts
        {
            Result.append(String(Part))
            if Parts.last != Part
            {
                Result.append(", ")
            }
        }
        return Result
    }
    
    var DataSet = [(Key: String, Value: String, Derived: Bool)]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case DetailTable:
                return DataSet.count
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var BoldText = true
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "KeyColumn"
            CellContents = DataSet[row].Key
            BoldText = false
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ValueColumn"
            CellContents = DataSet[row].Value
            if DataSet[row].Derived
            {
                BoldText = false
            }
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        Cell?.textField?.font = BoldText ? NSFont.boldSystemFont(ofSize: 14.0) : NSFont.systemFont(ofSize: 14.0)
        Cell?.textField?.textColor = BoldText ? NSColor.PrussianBlue : NSColor.black
        return Cell
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var DetailTable: NSTableView!
}
