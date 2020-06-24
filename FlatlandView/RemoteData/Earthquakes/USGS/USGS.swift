//
//  USGS.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// This class is used to receive earthquake data from the USGS. Data is received asynchronously on a
/// background thread and posted to `Delegate` when available.
/// - Note:
///   - See [USGS GeoJSON](https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php)
///   - See [API Documentation - Earthqake Catalog](https://earthquake.usgs.gov/fdsnws/event/1/)
///   - See [USGS Developer's Corner](https://github.com/usgs/devcorner)
///   - See [USGS Web Services](https://earthquake.usgs.gov/ws/)
class USGS
{
    /// The delegate of who receives asynchronous data.
    public weak var Delegate: AsynchronousDataProtocol? = nil
    
    /// Start calling the USGS for earthquake data.
    /// - Note: Data is returned asynchronously via the `Delegate`. If `Delegate` is not assigned
    ///         by the caller, no data is returned.
    /// - Parameter Every: Number of seconds between calls. Suggest no more frequent than every
    ///                    ten minutes.
    func GetEarthquakes(Every: Double)
    {
        EarthquakeTimer?.invalidate()
        EarthquakeTimer = nil
        EarthquakeTimer = Timer.scheduledTimer(timeInterval: Every,
                                               target: self,
                                               selector: #selector(GetNewEarthquakeData),
                                               userInfo: nil,
                                               repeats: true)
        //Call immediately so data will be ready when the user expects.
        GetNewEarthquakeData()
    }
    
    /// Make a web request to the USGS to return earthquake data.
    /// - Note: Execution occurs on a background thread.
    @objc func GetNewEarthquakeData()
    {
        DispatchQueue.global(qos: .background).async
            {
                self.GetUSGSEarthquakeData
                    {
                        Results in
                        if let Raw = Results
                        {
                            do
                            {
                                let RawData = Data(Raw.utf8)
                                if let json = try JSONSerialization.jsonObject(with: RawData, options: []) as? [String: Any]
                                {
                                    for (Name, _) in json
                                    {
                                        if Name == "features"
                                        {
                                            if let Feature = json["features"] as? [[String: Any]]
                                            {
                                                self.ParseJsonEntity(Feature)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            catch
                            {
                                print("JSON error \(error)")
                            }
                            self.HaveAllEarthquakes()
                        }
                        else
                        {
                            print("Nothing to do")
                        }
                }
        }
    }
    
    /// Called by `GetNewEarthquakeData` when all data for a given asynchronous call have been
    /// received and parsed. Calls `Delegate` on the main thread.
    func HaveAllEarthquakes()
    {
        DispatchQueue.main.async
            {
                var FinalList = self.RemoveDuplicates(From: self.EarthquakeList)
                FinalList = self.FilterForMagnitude(FinalList, Magnitude: Settings.GetDouble(.MinimumMagnitude))
                self.Delegate?.AsynchronousDataAvailable(DataType: .Earthquakes, Actual: FinalList as Any)
                self.Delegate?.AsynchronousDataAvailable(DataType: .Earthquakes2, Actual: self.EarthquakeList2 as Any )
        }
    }
    
    /// Remove duplicate entries from the passed list of earthquakes.
    /// - Note: Duplicates are defined as earthquakes with the same code.
    /// - Parameter From: The source list of earthquakes with possible duplicates.
    /// - Returns: List of earthquakes with no duplicates.
    func RemoveDuplicates(From: [Earthquake]) -> [Earthquake]
    {
        var Unique = [String: Earthquake]()
        for Quake in From
        {
            if let _ = Unique[Quake.Code]
            {
                continue
            }
            Unique[Quake.Code] = Quake
        }
        return Unique.map{$1}
    }
    
    /// Filter the passed list for minimum magnitude. Earthquakes that have a magnitude less than
    /// the passed value are excluded from the returned list.
    /// - Parameter List: The source list to filter.
    /// - Parameter Magnitude: The minimum magnitude an earthquake must have to be returned.
    /// - Returns: List of earthquakes from `List` that have a magnitude greater or equal to `Magnitude`.
    func FilterForMagnitude(_ List: [Earthquake], Magnitude: Double) -> [Earthquake]
    {
        var Final = [Earthquake]()
        for Quake in List
        {
            if Quake.Magnitude >= Magnitude
            {
                Final.append(Quake)
            }
        }
        return Final
    }
    
    /// Perform the actual web call here to get the list of USGS earthquakes.
    /// - Parameter completion: The completion handler called when results are available.
    func GetUSGSEarthquakeData(_ completion: @escaping (String?) -> Void)
    {
        let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
        //let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_week.geojson")
        _ = URLSession.shared.downloadTask(with: url!)
        {
            Local, Response, error in
            guard let HTTPResponse = Response as? HTTPURLResponse,
                (200 ... 299).contains(HTTPResponse.statusCode) else
            {
                let HTTPResponse = Response as! HTTPURLResponse
                print("Response error: \(HTTPResponse)")
                completion(nil)
                return
            }
            if let LocalURL = Local
            {
                if let Results = try? String(contentsOf: LocalURL)
                {
                    completion(Results)
                }
            }
        }.resume()
    }
    
    /// Stops the timer to get earthquakes from the USGS.
    func StopReceivingEarthquakes()
    {
        EarthquakeTimer?.invalidate()
        EarthquakeTimer = nil
    }
    
    /// Timer for getting USGS earthquakes.
    var EarthquakeTimer: Timer? = nil
    
    /// Parse a JSON dictionary into an array of earthquake data.
    /// - Parameter JSON: Array of arrays of JSON data.
    func ParseJsonEntity(_ JSON: [[String: Any]])
    {
        EarthquakeList.removeAll()
        var Seq = 0
        for OneFeature in JSON
        {
            let NewEarthquake = Earthquake(Sequence: Seq)
            for subset in OneFeature
            {
                
                Seq = Seq + 1
                let Dict = Dictionary(dictionaryLiteral: subset)
                for (Key, Value) in Dict
                {
                    let SubDict = Value as? [String: Any]
                    if SubDict == nil
                    {
                        continue
                    }
                    switch Key
                    {
                        case "geometry":
                            for (GeoKey, GeoVal) in SubDict!
                            {
                                if GeoKey == "coordinates"
                                {
                                    if let A = GeoVal as? [Double]
                                    {
                                        NewEarthquake.Latitude = A[1]
                                        NewEarthquake.Longitude = A[0]
                                        NewEarthquake.Depth = A[2]
                                    }
                                }
                        }
                        
                        case "properties":
                            for (PropKey, PropVal) in SubDict!
                            {
                                switch PropKey
                                {
                                    case "mag":
                                        if let Magnitude = PropVal as? Double
                                        {
                                            NewEarthquake.Magnitude = Magnitude
                                        }
                                        else
                                        {
                                            NewEarthquake.Magnitude = 0.0
                                    }
                                    
                                    case "place":
                                        NewEarthquake.Place = PropVal as! String
                                    
                                    case "time":
                                        var TimeDouble = PropVal as! Double
                                        TimeDouble = TimeDouble / 1000.0
                                        NewEarthquake.Time = Date(timeIntervalSince1970: TimeDouble)
                                    
                                    case "tsunami":
                                        NewEarthquake.Tsunami = PropVal as! Int
                                    
                                    case "code":
                                        NewEarthquake.Code = PropVal as! String
                                    
                                    case "status":
                                        NewEarthquake.Status = PropVal as! String
                                    
                                    case "updated":
                                        NewEarthquake.Updated = PropVal as! Int
                                    
                                    case "mmi":
                                        if let MMI = PropVal as? Double
                                        {
                                        NewEarthquake.MMI = MMI
                                    }
                                    
                                    case "felt":
                                        if let Felt = PropVal as? Int
                                        {
                                        NewEarthquake.Felt = Felt
                                    }
                                    
                                    case "sig":
                                        NewEarthquake.Significance = PropVal as! Int
                                    
                                    default:
                                        continue
                                }
                        }
                        
                        default:
                            continue
                    }
                }
                let Minimum = Settings.GetDouble(.MinimumMagnitude, 6.0)
                if NewEarthquake.Magnitude >= Minimum
                {
                    EarthquakeList.append(NewEarthquake)
                    let NEq2 = Earthquake2(NewEarthquake)
                    Earthquake2.AddEarthquake(New: NEq2, To: &EarthquakeList2)
                }
            }
        }
    }
    
    /// Current list of earthquakes.
    var EarthquakeList = [Earthquake]()
    var EarthquakeList2 = [Earthquake2]()
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Returns: True if the lists have equal contents, false if not.
    public static func SameEarthquakes(_ List1: [Earthquake], _ List2: [Earthquake]) -> Bool
    {
        if List1.count != List2.count
        {
            return false
        }
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        return SList1 == SList2
    }
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Returns: True if the lists have equal contents, false if not.
    public static func SameEarthquakes(_ List1: [Earthquake2], _ List2: [Earthquake2]) -> Bool
    {
        if List1.count != List2.count
        {
            return false
        }
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        return SList1 == SList2
    }
}
