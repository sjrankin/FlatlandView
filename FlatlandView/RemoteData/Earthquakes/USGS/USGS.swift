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
            #if DEBUG
            FinalList.append(contentsOf: self.DebugEarthquakes)
            #endif
            self.Delegate?.AsynchronousDataAvailable(DataType: .Earthquakes, Actual: FinalList as Any)
        }
    }
    
    /// Force fetch earthquake data regardless of the fetch cycle.
    func ForceFetch()
    {
        GetNewEarthquakeData()
    }
    
    /// Insert a debug earthquake.
    /// - Note: Will be returned at the next fetch cycle.
    /// - Parameter Latitude: The latitude of the debug earthquake.
    /// - Parameter Longitude: The longitude of the debug earthquake.
    /// - Parameter Magnitude: The magnitude of the debug earthquake.
    func InsertDebugEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    {
        let DebugQuake = Earthquake2(Sequence: 100000)
        DebugQuake.Latitude = Latitude
        DebugQuake.Longitude = Longitude
        DebugQuake.Magnitude = Magnitude
        DebugEarthquakes.append(DebugQuake)
    }
    
    /// Insert a cluster of earthquakes for debug purposes.
    /// - Parameter Count: The number of earthquakes to insert.
    /// - Parameter Within: The number of earthquakes that will be within 500 kilometers of the first earthquake.
    ///                     If nil, all earthquakes will be within range.
    func InsertEarthquakeCluster(_ Count: Int, Within Distance: Int? = nil, ClusterRange: Double = 500.0)
    {
        let Base = Earthquake2(Sequence: 200000)
        let (Lat, Lon) = RandomLocation()
        Base.Latitude = Lat
        Base.Longitude = Lon
        Base.Code = "Cluster Base"
        Base.Magnitude = Double.random(in: 5.0 ... 9.5)
        DebugEarthquakes.append(Base)
        var FinalCount = Count
        if let InRange = Distance
        {
            if InRange < FinalCount
            {
                FinalCount = FinalCount - InRange
                for Index in 0 ..< InRange
                {
                    let OutOfRangeQuake = Earthquake2(Sequence: 200002)
                    let (Lat, Lon) = RandomLocation()
                    OutOfRangeQuake.Latitude = Lat
                    OutOfRangeQuake.Longitude = Lon
                    OutOfRangeQuake.Code = "Cluster far \(Index)"
                    OutOfRangeQuake.Magnitude = Double.random(in: 5.0 ... 9.5)
                    DebugEarthquakes.append(OutOfRangeQuake)
                }
            }
        }
        for Index in 0 ..< FinalCount
        {
            let InRangeQuake = Earthquake2(Sequence: 200001)
            let (Lat, Lon) = RandomLocation(Near: Base, Distance: ClusterRange)
            InRangeQuake.Latitude = Lat
            InRangeQuake.Longitude = Lon
            InRangeQuake.Code = "Cluster close \(Index)"
            InRangeQuake.Magnitude = Double.random(in: 5.0 ... 9.5)
            DebugEarthquakes.append(InRangeQuake)
        }
    }
    
    /// Create a random location based on the passed earthquake and maximum distance.
    /// - Note: This is not optimized and if you are unlucky, will never return.
    /// - Parameter Near: The base earthquake.
    /// - Parameter Distance: The maximum distance of a random location from `Near`.
    /// - Returns: Tuple with the latitude and longitude of a randomly generated location.
    func RandomLocation(Near Quake: Earthquake2, Distance: Double) -> (Latitude: Double, Longitude: Double)
    {
        while true
        {
            let (Lat, Lon) = RandomLocation()
            if Quake.DistanceTo(Lat, Lon) <= Distance
            {
                return (Lat, Lon)
            }
        }
    }
    
    /// Create a random location somewhere on the surface of the world.
    /// - Returns: Tuple with the latitude and longitude of a randomly generated location.
    func RandomLocation() -> (Latitude: Double, Longitude: Double)
    {
        return (Latitude: Double.random(in: -90.0 ... 90.0), Longitude: Double.random(in: -180.0 ... 180.0))
    }
    
    /// Remove all debug earthquakes.
    func ClearDebugEarthquakes()
    {
        DebugEarthquakes.removeAll()
    }
    
    /// Remove duplicate entries from the passed list of earthquakes.
    /// - Note: Duplicates are defined as earthquakes with the same code.
    /// - Parameter From: The source list of earthquakes with possible duplicates.
    /// - Returns: List of earthquakes with no duplicates.
    func RemoveDuplicates(From: [Earthquake2]) -> [Earthquake2]
    {
        var Unique = [String: Earthquake2]()
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
    func FilterForMagnitude(_ List: [Earthquake2], Magnitude: Double) -> [Earthquake2]
    {
        var Final = [Earthquake2]()
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
        URLSession.shared.downloadTask(with: url!)
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
            let NewEarthquake = Earthquake2(Sequence: Seq)
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
                                        #if true
                                        NewEarthquake.SetLocation(A[1], A[0])
                                        #else
                                        NewEarthquake.Latitude = A[1]
                                        NewEarthquake.Longitude = A[0]
                                        #endif
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
                                        var UpdatedDouble = PropVal as! Double
                                        UpdatedDouble = UpdatedDouble / 1000.0
                                        NewEarthquake.Updated = Date(timeIntervalSince1970: UpdatedDouble)
                                        
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
                }
            }
        }
    }
    
    /// Current list of earthquakes.
    var EarthquakeList = [Earthquake2]()
    var DebugEarthquakes = [Earthquake2]()
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Note: Equality is based on the `Code` of each earthquake, assigned by the USGS.
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
    
    /// Flatten the passed list of earthquakes. All earthquakes will be at the top-most level
    /// of the array.
    /// - Parameter Quakes: The array of earthquakes to flatten.
    /// - Returns: Array of earthquakes, all at the top-most level.
    public static func FlattenEarthquakes(_ Quakes: [Earthquake2]) -> [Earthquake2]
    {
        var Final = [Earthquake2]()
        for Quake in Quakes
        {
            if let Related = Quake.Related
            {
                for RelatedQuake in Related
                {
                    Final.append(RelatedQuake)
                }
                Quake.Related?.removeAll()
                Quake.Related = nil
                Quake.Marked = false
                Final.append(Quake)
            }
            else
            {
                Quake.Marked = false
                Final.append(Quake)
            }
        }
        return Final
    }
    
    /// Place an earthquake in the proper location. Passed earthquakes are added to earthquakes already in
    /// `To` if they are close enough. Otherwise, the are added at the end of the array.
    /// - Parameter Quake: The earthquake to place into the passed earthquake list.
    /// - Parameter To: The earthquake list where `Quake` will be placed.
    /// - Parameter InRange: How close `Quake` must be to an earthquake in `To` in order for it to be added
    ///                      to that earthquake.
    private static func AddForCombined(_ Quake: Earthquake2, To: inout [Earthquake2], InRange: Double)
    {
        if To.isEmpty
        {
            To.append(Quake)
            return
        }
        for Combined in To
        {
            let Distance = Combined.DistanceTo(Quake)
            if Distance <= InRange
            {
                Combined.AddRelated(Quake)
                return
            }
        }
        To.append(Quake)
    }
    
    /// Return an `Earthquake2` class with the greatest magnitude of `Quake` and its child earthquakes. If
    /// `Quake` does not have any related earthquakes, it is returned as is.
    /// - Parameter From: The earthquake whose child earthquakes are used to determine the greatest earthquake.
    /// - Returns: `Earthquake2` class with the greatest earthquake (based on magnitude) of `Quake`. If a child
    ///            earthquake has a greater magnitude than `Quake`, `Quake` is converted to a child earthquake.
    private static func GetGreatestMagnitude(From Quake: Earthquake2) -> Earthquake2
    {
        let ParentMagnitude = Quake.Magnitude
        var MaxChild: Earthquake2? = nil
            MaxChild = Quake.Related!.max(by: {(E1, E2) -> Bool in E1.Magnitude > E2.Magnitude})
            if MaxChild!.Magnitude < ParentMagnitude
            {
                return Quake
            }
        for ChildQuake in Quake.Related!
        {
            if ChildQuake.Code != MaxChild?.Code
            {
                MaxChild?.AddRelated(ChildQuake)
            }
        }
        let OldParent = Earthquake2(Quake)
        MaxChild?.AddRelated(OldParent)
        return MaxChild!
    }
    
    /// Return an `Earthquake2` class with the earliest date of `Quake` and its child earthquakes. If
    /// `Quake` does not have any related earthquakes, it is returned as is.
    /// - Parameter From: The earthquake whose child earthquakes are used to determine the earliest date.
    /// - Returns: `Earthquake2` class with the earliest earthquake (based on date) of `Quake`. If a child
    ///            earthquake has an earlier date than `Quake`, `Quake` is converted to a child earthquake.
    private static func GetEarliestEarthquake(From Quake: Earthquake2) -> Earthquake2
    {
        let ParentDate = Quake.Time
        var EarliestChild: Earthquake2? = nil
        EarliestChild = Quake.Related!.max(by: {(E1, E2) -> Bool in E1.Time < E2.Time})
        if EarliestChild!.Time > ParentDate
        {
            return Quake
        }
        for ChildQuake in Quake.Related!
        {
            if ChildQuake.Code != EarliestChild?.Code
            {
                EarliestChild?.AddRelated(ChildQuake)
            }
        }
        let OldParent = Earthquake2(Quake)
        EarliestChild?.AddRelated(OldParent)
        return EarliestChild!
    }
    
    /// Combined the passed list of earthquakes. All earthquakes within a certain radius will be
    /// put into a single earthquake node.
    /// - Note: This function assumes the passed earthquake list is flat.
    /// - Parameter Quakes: The array of earthquakes to combine.
    /// - Parameter Closeness: How close earthquakes must be to be considered to be combined. Units
    ///                        are kilometers. Default is `100.0`.
    /// - Parameter RelatedOrderedBy: Determines how earthquakes with related earthquakes are ordered. Defaults
    ///                               to `.ByGreatestMagnitude`.
    /// - Returns: Array of combined earthquakes.
    public static func CombineEarthquakes(_ Quakes: [Earthquake2], Closeness: Double = 100.0,
                                          RelatedOrderedBy: MultipleQuakeOrders = .ByGreatestMagnitude) -> [Earthquake2]
    {
        var Combined = [Earthquake2]()
        for Quake in Quakes
        {
            AddForCombined(Quake, To: &Combined, InRange: Closeness)
        }
        switch RelatedOrderedBy
        {
            case .Unordered:
                return Combined
                
            case .ByGreatestMagnitude:
                var Fixed = [Earthquake2]()
                for Quake in Combined
                {
                    if Quake.IsCluster
                    {
                        let Greatest = GetGreatestMagnitude(From: Quake)
                        Fixed.append(Greatest)
                    }
                    else
                    {
                        Fixed.append(Quake)
                    }
                }
                return Fixed
                
            case .ByEarliestDate:
                var Fixed = [Earthquake2]()
                for Quake in Combined
                {
                    if Quake.IsCluster
                    {
                        let Greatest = GetGreatestMagnitude(From: Quake)
                        Fixed.append(Greatest)
                    }
                    else
                    {
                        Fixed.append(Quake)
                    }
                }
                return Fixed
        }
    }
}


