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
                self.Delegate?.AsynchronousDataAvailable(DataType: .Earthquakes, Actual: self.EarthquakeList as Any)
        }
    }
    
    /// Perform the actual web call here to get the list of USGS earthquakes.
    /// - Parameter completion: The completion handler called when results are available.
    func GetUSGSEarthquakeData(_ completion: @escaping (String?) -> Void)
    {
        let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
        //let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_week.geojson")
        let task = URLSession.shared.downloadTask(with: url!)
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
        for OneFeature in JSON
        {
            for subset in OneFeature
            {
                let NewEarthquake = Earthquake()
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
                                    if let GeoC = GeoVal as? [NSNumber]
                                    {
                                        NewEarthquake.Latitude = Double(truncating: GeoC[0])
                                        NewEarthquake.Longitude = Double(truncating: GeoC[1])
                                        NewEarthquake.Depth = Double(truncating: GeoC[2])
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
                                    
                                    default:
                                        continue
                                }
                        }
                        
                        default:
                            continue
                    }
                }
                if NewEarthquake.Magnitude >= Settings.GetDouble(.MinimumMagnitude, 4.5)
                {
                    EarthquakeList.append(NewEarthquake)
                }
            }
        }
    }
    
    /// Current list of earthquakes.
    var EarthquakeList = [Earthquake]()
}
