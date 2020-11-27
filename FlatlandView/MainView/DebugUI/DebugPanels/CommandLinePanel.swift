//
//  CommandLinePanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CommandLinePanel: PanelController, NSTextFieldDelegate, NSTextViewDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextBox.isRichText = true
        TextBox.backgroundColor = NSColor.black
        TextBox.textColor = NSColor.yellow
        TextBox.font = NSFont.monospacedDigitSystemFont(ofSize: 16.0, weight: .medium)
        TextBox.insertionPointColor = NSColor.green
        TextBox.string.append("Flatland Command Prompt\n>")
        BlockedText = TextBox.string.count
        StartIndex = BlockedText
        TextBox.becomeFirstResponder()
    }
    
    var StartIndex: Int = 0
    var BlockedText: Int = 0
    
    func textViewDidChangeSelection(_ notification: Notification)
    {
        guard let TextView = notification.object as? NSTextView else
        {
            return
        }
        if let Index = TextView.selectedRanges.first?.rangeValue.location
        {
            CurrentCursorIndex = Index
        }
    }
    
    //https://stackoverflow.com/questions/33078314/how-to-prevent-user-not-to-remove-particular-character-in-uitextfield
    func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue],
                  replacementStrings: [String]?) -> Bool
    {
        if affectedRanges.count != 1
        {
            return false
        }
        if let Range = affectedRanges[0] as? NSRange
        {
            if Range.location == 0 && (Range.length == 0 || Range.length == 1)
            {
                return false
            }
            if Range.location < BlockedText && (Range.length == 0 || Range.length == 1)
            {
                return false
            }
        }
        return true
    }
    
    var CurrentCursorIndex: Int = -1
    
    func textDidChange(_ notification: Notification)
    {
        guard let TextControl = notification.object as? NSTextView else
        {
            return
        }
        let New = TextControl.string
        if let Last = TextControl.string.last
        {
            if Last == "\n"
            {
                if TextControl.string.count == BlockedText + 1
                {
                    TextControl.string.append(">")
                    BlockedText = TextControl.string.count
                    StartIndex = BlockedText
                    return
                }
            }
        }
        let (Added, Removed) = GetDelta(Previous: Previous, New: New)
        Previous = New
        if Added == "\n"
        {
            GetCommandLine()
            TextControl.string.append(">")
            BlockedText = TextControl.string.count
            StartIndex = BlockedText
        }
    }
    
    var Previous = ""
    
    func GetCommandLine()
    {
        let Raw = TextBox.string
        let RawStart = Raw.index(Raw.startIndex, offsetBy: StartIndex)
        let RawEnd = Raw.index(RawStart, offsetBy: Raw.count - StartIndex)
        StartIndex = Raw.count
        let Line = String(Raw[RawStart ..< RawEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        let Words = Line.Words()
        HandleCommand(Words)
    }
    
    func HandleCommand(_ Tokens: [String])
    {
        if Tokens.count < 1
        {
            return
        }
        let Command = Tokens[0].lowercased()
        switch Command
        {
            case "status":
                RunSetStatusText(Tokens)
                
            case "inject":
                if Tokens.count < 2
                {
                    Print("Inject what?")
                    return
                }
                RunInjection(Tokens)
                
            case "ver":
                Print(Versioning.MakeSimpleVersionString())
                
            case "show":
                if Tokens.count < 2
                {
                    Print("Show what? Need operand.")
                    return
                }
                RunShow(Tokens)
                
            case "find":
                if Tokens.count < 2
                {
                    Print("Find what? Need operand.")
                    return
                }
                RunFind(Tokens)
                
            case "today":
                RunToday(Tokens)
                
            case "set":
                if Tokens.count < 3
                {
                    Print("Set command is in the form: set setting value")
                    return
                }
                RunSet(Tokens)
                
            case "clear":
                if Tokens.count < 2
                {
                    Print("Clear command requires an operand.")
                    return
                }
                RunClear(Tokens)
                
            case "program":
                if Tokens.count < 2
                {
                    Print("Program command requires an operand.")
                    return
                }
                RunProgramCommand(Tokens)
                
            case "help":
                if Tokens.count < 2
                {
                    Print("Type \"help command\" to see help on a given command.")
                    Print("Commands:")
                    Print("show: Show the value of an object.")
                    Print("ver: Show the version and build.")
                    Print("set: Set the value of a setting.")
                    Print("find: Find an enum or setting.")
                    Print("clear: Removes a set of objects.")
                    Print("status: Sets status text.")
                    Print("program: Issue a program command.")
                    return
                }
                RunShowHelp(Tokens)
                
            default:
                Print("Unrecognized command: \"\(Tokens[0])\"")
        }
    }
    
    func RunProgramCommand(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        switch Tokens[1].lowercased()
        {
            case "quit", "exit", "stop":
                Main?.ExitProgram()
                
            case "settings":
                if Tokens.count < 3
                {
                    Print("Need to specify program settings operation.")
                    return
                }
                if ["reset", "default"].contains(Tokens[2].lowercased())
                {
                    //reset settings
                    return
                }
                
            default:
                return
        }
    }
    
    func RunSetStatusText(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            Main?.ClearStatusText()
            return
        }
        var TextToDisplay = ""
        for Index in 1 ..< Tokens.count
        {
            TextToDisplay.append(Tokens[Index])
            TextToDisplay.append(" ")
        }
        TextToDisplay = TextToDisplay.trimmingCharacters(in: .whitespaces)
        Main?.SetDisappearingStatusText(TextToDisplay, HideAfter: 25.0)
    }
    
    func RunClear(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        if ["status"].contains(Tokens[1].lowercased())
        {
            Main?.ClearStatusText()
            return
        }
        if ["inject", "injected"].contains(Tokens[1].lowercased())
        {
            if Tokens.count < 3
            {
                Print("Need to specify what injected object set to clear.")
                return
            }
            let Object = Tokens[2].lowercased()
            switch Object
            {
                case "quakes", "earthquakes":
                    if let Quakes = Main?.GetEarthquakeController()
                    {
                        Quakes.ClearInjectedEarthquakes()
                    }
                    
                case "city", "cities":
                    break
                    
                default:
                    return
            }
            return
        }
    }
    
    func RunInjection(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let Object = Tokens[1].lowercased()
        switch Object
        {
            case "quake", "earthquake":
                //"inject quake latitude longitude magnitude"
                if Tokens.count != 5
                {
                    Print("Inject syntax error: must be: \"inject quake latitude longitude magnitude\"")
                    return
                }
                let RawLat = Tokens[2]
                let RawLon = Tokens[3]
                let RawMag = Tokens[4]
                guard let ActualLat = Double(RawLat) else
                {
                    Print("Unable to parse latitude \(RawLat): Must be a double value only.")
                    return
                }
                guard let ActualLon = Double(RawLon) else
                {
                    Print("Unable to parse longitude \(RawLon): Must be a double value only.")
                    return
                }
                guard let ActualMag = Double(RawMag) else
                {
                    Print("Unable to parse magnitude \(RawMag): Must be a double value only.")
                    return
                }
                let DebugQuake = Earthquake(Latitude: ActualLat, Longitude: ActualLon, Magnitude: ActualMag,
                                            IsDebug: true)
                DebugQuake.ID = UUID()
                DebugQuake.Sequence = Int.random(in: 100000 ... 500000)
                DebugQuake.Code = String.Random(10)
                if let Quakes = Main?.GetEarthquakeController()
                {
                    Quakes.InjectEarthquake(DebugQuake)
                }
                else
                {
                    Print("Unable to retrieve current earthquake controller.")
                }
                
            case "city":
                //"inject city latitude longitude name population"
                break
                
            default:
                return
        }
    }
    
    func RunShowHelp(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let HelpFor = Tokens[1].lowercased()
        switch HelpFor
        {
            case "inject":
                Print("Injects a logical object. Form is: inject something where attributes; something is \"earthquake\" or \"quake\", \"city\", where is a latitude longtiude pair, and attributes are dependent on what is injected.")
                
            case "show":
                Print("Show the value of an object. Form is: show class object where class is enum and object is the name. You can also use show setting name to get the name, value and type of a setting.")
                
            case "ver":
                Print("Shows the version and build of Flatland.")
                
            case "set":
                Print("Sets the value of a setting. Form is: set setting name setting value")
                
            case "find":
                Print("Finds information and prints it. Form is: find something where something is what you want to find.")
                
            case "today":
                Print("Displays solar information for current home location. Optionally for other location.")
                
            default:
                Print("No help for \"\(Tokens[1])\"")
        }
    }
    
    func RunFind(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let SearchFor = Tokens[1]
        switch SearchFor.lowercased()
        {
            case "name", "location", "place":
                if Tokens.count < 3
                {
                    Print("You must specify a placename - no spaces allowed.")
                    return
                }
                SearchForPlaces(Tokens[2])
                
            case "enum":
                if Tokens.count < 3
                {
                    Print("You must specify the enum case.")
                    return
                }
                break
                
            default:
                Print("Find what?")
        }
    }
    
    func SearchForPlaces(_ Placename: String)
    {
        if Placename.isEmpty
        {
            Print("Empty placename.")
            return
        }
        #if true
        let LocationFinder = Locations()
        LocationFinder.Main = Main
        if let Record = LocationFinder.SearchFor(Placename, Compressed: true, CaseSensitive: false)
        {
            let Coordinates = Utility.PrettyCoordinates(Record.Latitude, Record.Longitude)
            switch Record.LocationType
            {
                case .City:
                    Print("Found city \(Record.Name) at \(Coordinates), population \(Record.Population)")
                    return
                    
                case .Home:
                    let HomeName = Record.Name.isEmpty ? "" : "\(Record.Name) "
                    Print("Found home \(HomeName)at \(Coordinates)")
                    return
                    
                case .UNESCO:
                    Print("Found World Heritage Site \(Record.Name) at \(Coordinates)")
                    return
                    
                case .UserPOI:
                    Print("Found user POI \(Record.Name) at \(Coordinates)")
                    return
            }
        }
        #else
        if Placename.lowercased() == "home"
        {
            if Settings.HaveLocalLocation()
            {
                let Coordinates = Utility.PrettyCoordinates(Settings.GetDoubleNil(.LocalLatitude)!,
                                                            Settings.GetDoubleNil(.LocalLongitude)!)
                let HomeName = Settings.GetString(.LocalName, "")
                let FinalName = HomeName.isEmpty ? "" : "\"\(HomeName)\" "
                Print("Found home \(FinalName)at \(Coordinates)")
                return
            }
        }
        let LookFor = Placename.lowercased()
        
        for City in CityManager.AllCities!
        {
            var CityName = City.Name
            CityName = CityName.replacingOccurrences(of: " ", with: "").lowercased()
            if CityName == LookFor
            {
                let Coordinates = Utility.PrettyCoordinates(City.Latitude, City.Longitude)
                Print("Found \(City.Name) at \(Coordinates), population \(City.GetPopulation())")
                return
            }
        }
        
        let Locations = Settings.GetLocations()
        for Location in Locations
        {
            let LocName = Location.Name.replacingOccurrences(of: " ", with: "").lowercased()
            if LocName == LookFor
            {
                let Coordinates = Utility.PrettyCoordinates(Location.Coordinates.Latitude,
                                                            Location.Coordinates.Longitude)
                Print("Found \(Location.Name) at \(Coordinates)")
                return
            }
        }
        #endif
        
        Print("\(Placename) not found.")
    }
    
    func RunToday(_ Tokens: [String])
    {
        if Tokens.count == 1
        {
            //Today for home location.
            return
        }
        
        if Tokens.count == 2
        {
            //Today for placename.
            let LocationFinder = Locations()
            LocationFinder.Main = Main
            if let Record = LocationFinder.SearchFor(Tokens[1], Compressed: true, CaseSensitive: false)
            {
                return
            }
            Print("Did not find \(Tokens[1]).")
        }
        
        if Tokens.count == 3
        {
            //Today for coordinate.
            if let (Latitude, Longitude) = Utility.PrettyCoordinateToActual("\(Tokens[1]) \(Tokens[2])")
            {
                Print("TEST: Latitude=\(Latitude), Longitude=\(Longitude)")
                return
            }
            Print("Command must be in the format today latitude longitude. latitude and longitude must not have any spaces")
        }
    }
    
    func RunSet(_ Tokens: [String])
    {
        if Tokens.count < 3
        {
            return
        }
        let What = Tokens[1].lowercased()
        for Setting in SettingKeys.allCases
        {
            if Setting.rawValue.lowercased() == What
            {
                let SetOK = Settings.TryToSet(Setting, WithValue: Tokens[2])
                if !SetOK
                {
                    Print("Error setting \(Setting.rawValue) to \(Tokens[2])")
                }
            }
        }
    }
    
    func GetOptionalValue(From: String, Value: inout Double, Constraint: inout ConstraintTypes) -> Bool
    {
        for Separator in ["=", "<", ">"]
        {
            let Parts = From.split(separator: String.Element(Separator), omittingEmptySubsequences: true)
            if Parts.count == 2
            {
                switch Separator
                {
                    case "=":
                        Constraint = .Equality
                        
                    case "<":
                        Constraint = .LessOrEqual
                        
                    case ">":
                        Constraint = .GreaterOrEqual
                        
                    default:
                        return false
                }
                if let ActualValue = Double(String(Parts[1]))
                {
                    Value = ActualValue
                    return true
                }
            }
        }
        return false
    }
    
    func QuakeOptions(From: [String]) -> (AgeConstraints?, SizeConstraints?)
    {
        if From.count < 1
        {
            return (nil, nil)
        }
        var ForAge = AgeConstraints()
        ForAge.ConstraintType = .None
        var ForMagnitude = SizeConstraints()
        ForMagnitude.ConstraintType = .None
        for Option in From
        {
            let NormalizedOption = Option.lowercased()
            switch NormalizedOption
            {
                case "m4":
                    ForMagnitude.ConstrainTo = 4.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m5":
                    ForMagnitude.ConstrainTo = 5.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m6":
                    ForMagnitude.ConstrainTo = 6.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m7":
                    ForMagnitude.ConstrainTo = 7.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m8":
                    ForMagnitude.ConstrainTo = 8.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "m9":
                    ForMagnitude.ConstrainTo = 9.0
                    ForMagnitude.ConstraintType = .GreaterOrEqual
                    
                case "a0":
                    ForAge.ConstrainTo = 0
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a1":
                    ForAge.ConstrainTo = 1
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a2":
                    ForAge.ConstrainTo = 2
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a3":
                    ForAge.ConstrainTo = 3
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a4":
                    ForAge.ConstrainTo = 4
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a5":
                    ForAge.ConstrainTo = 5
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a6":
                    ForAge.ConstrainTo = 6
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a7":
                    ForAge.ConstrainTo = 7
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a8":
                    ForAge.ConstrainTo = 8
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a9":
                    ForAge.ConstrainTo = 9
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a10":
                    ForAge.ConstrainTo = 10
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a11":
                    ForAge.ConstrainTo = 11
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a12":
                    ForAge.ConstrainTo = 12
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a13":
                    ForAge.ConstrainTo = 13
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a14":
                    ForAge.ConstrainTo = 14
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a15":
                    ForAge.ConstrainTo = 15
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a16":
                    ForAge.ConstrainTo = 16
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a17":
                    ForAge.ConstrainTo = 17
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a18":
                    ForAge.ConstrainTo = 18
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a19":
                    ForAge.ConstrainTo = 19
                    ForAge.ConstraintType = .LessOrEqual
                    
                case "a20":
                    ForAge.ConstrainTo = 20
                    ForAge.ConstraintType = .LessOrEqual
                    
                default:
                    continue
            }
        }
        return (ForAge, ForMagnitude)
    }
    
    func ValidQuake(_ Quake: Earthquake, ForAge: AgeConstraints?, ForMagnitude: SizeConstraints?) -> Bool
    {
        if ForAge == nil && ForMagnitude == nil
        {
            return true
        }
        var ValidAge = true
        var ValidMagnitude = true
        if let CheckAge = ForAge
        {
            var QuakeDays = Int(Quake.GetAge())
            QuakeDays = QuakeDays / (24 * 60 * 60)
            switch CheckAge.ConstraintType
            {
                case .None:
                    break
                    
                case .Equality:
                    ValidAge = Double(QuakeDays) == CheckAge.ConstrainTo
                    
                case .GreaterOrEqual:
                    ValidAge = Double(QuakeDays) >= CheckAge.ConstrainTo
                    
                case .LessOrEqual:
                    ValidAge = Double(QuakeDays) <= CheckAge.ConstrainTo
            }
        }
        if let CheckMag = ForMagnitude
        {
            switch CheckMag.ConstraintType
            {
                case .None:
                    break
                    
                case .Equality:
                    ValidMagnitude = Quake.Magnitude == CheckMag.ConstrainTo
                    
                case .GreaterOrEqual:
                    ValidMagnitude = Quake.Magnitude >= CheckMag.ConstrainTo
                    
                case .LessOrEqual:
                    ValidMagnitude = Quake.Magnitude <= CheckMag.ConstrainTo
            }
        }
        return ValidAge && ValidMagnitude
    }
    
    func RunShow(_ Tokens: [String])
    {
        if Tokens.count < 2
        {
            return
        }
        let What = Tokens[1].lowercased()
        if What == "enum"
        {
            if Tokens.count < 3
            {
                Print("Please specify an enum name. Use \"show enum list\" to list all enums.")
                return
            }
            ShowEnum(Tokens[2])
            return
        }
        if ["applications", "programs"].contains(Tokens[1].lowercased())
        {
            var Results = [(Name: String, PID: Int32)]()
            for Running in NSWorkspace.shared.runningApplications
            {
                if let AppName = Running.localizedName
                {
                    Results.append((AppName, Running.processIdentifier))
                }
            }
            Results.sort{$0.Name < $1.Name}
            for Result in Results
            {
                Print("\(Result.Name) (\(Result.PID))")
            }
            return
        }
        if ["quake", "quakes", "earthquake", "earthquakes"].contains(Tokens[1].lowercased())
        {
            if let Quakes = Main?.GetEarthquakeController()
            {
                var Count = 0
                var Ages: AgeConstraints? = nil
                var Magnitudes: SizeConstraints? = nil
                if Tokens.count > 2
                {
                    let SubTokens = Array(Tokens[2 ..< Tokens.count])
                    let (SomeAge, SomeSize) = QuakeOptions(From: SubTokens)
                    Ages = SomeAge
                    Magnitudes = SomeSize
                }
                for Quake in Quakes.EarthquakeList
                {
                    if ValidQuake(Quake, ForAge: Ages, ForMagnitude: Magnitudes)
                    {
                        var qd = ""
                        if Quake.DebugQuake
                        {
                            qd = "* "
                        }
                        qd.append("M\(Quake.Magnitude), ")
                        let Lat = Quake.Latitude.RoundedTo(3)
                        let SLat = Lat < 0.0 ? "\(abs(Lat))S" : "\(Lat)N"
                        qd.append("\(SLat), ")
                        let Lon = Quake.Longitude.RoundedTo(3)
                        let SLon = Lon < 0.0 ? "\(abs(Lon))W" : "\(Lon)E"
                        qd.append("\(SLon), ")
                        qd.append("\(Quake.Time.PrettyDateTime(Separator: .Space)), ")
                        qd.append("\"\(Quake.Title)\"")
                        Print(qd)
                        Count = Count + 1
                    }
                }
                let Plural = Count == 1 ? "" : "s"
                Print("\(Count) earthquake\(Plural) returned.")
            }
            return
        }
        for Setting in SettingKeys.allCases
        {
            if Setting.rawValue.lowercased() == What
            {
                if let (SettingName, SettingValue, SettingType) = Settings.Query(Setting)
                {
                    let Result = "\(SettingName): \(SettingType) = \(SettingValue)"
                    Print(Result)
                }
                else
                {
                    Print("Error retrieving setting information.")
                }
            }
        }
    }
    
    func ShowEnum(_ EnumName: String)
    {
        if EnumName.lowercased() == "list"
        {
            var EnumNames = [String]()
            EnumNames = EnumList.Enums.keys.map{"\($0)"}
            EnumNames.sort()
            var AllEnums = ""
            for EnumName in EnumNames
            {
                AllEnums.append(EnumName)
                if EnumName != EnumNames.last
                {
                    AllEnums.append("\n")
                }
            }
            Print(AllEnums)
            return
        }
        if let EnumCases = EnumList.Enums[EnumName]
        {
            var Cases = "\(EnumName):\n"
            for SomeCase in EnumCases
            {
                Cases.append(" \(SomeCase)")
                if SomeCase != EnumCases.last
                {
                    Cases.append("\n")
                }
            }
            Print(Cases)
            return
        }
        Print("Unknown enum name \"\(EnumName)\". Enum names are case sensitive. Use \"show enum list\" to see all enums.")
    }
    
    func GetDelta(Previous: String, New: String) -> (Added: String, Removed: String)
    {
        let PrevArray = Array(Previous)
        let NewArray = Array(New)
        let Deltas = NewArray.difference(from: PrevArray)
        var Accumulated = ""
        var Stripped = ""
        for SomeChange in Deltas.insertions
        {
            switch SomeChange
            {
                case .insert(_, let Element, _):
                    Accumulated.append(String(Element))
                    
                default:
                    continue
            }
        }
        for SomeChange in Deltas.removals
        {
            switch SomeChange
            {
                case .remove(_, let Element, _):
                    Stripped.append(String(Element))
                    
                default:
                    continue
            }
        }
        return (Accumulated, Stripped)
    }
    
    func Print(_ Text: String)
    {
        TextBox.string.append("\(Text)\n")
        BlockedText = TextBox.string.count
        StartIndex = BlockedText
    }
    
    @IBOutlet var TextBox: NSTextView!
}

class AgeConstraints
{
    public var ConstraintType: ConstraintTypes = .None
    public var ConstrainTo: Double = 0.0
}

enum ConstraintTypes
{
    case None
    case Equality
    case GreaterOrEqual
    case LessOrEqual
}

class SizeConstraints
{
    public var ConstraintType: ConstraintTypes = .None
    public var ConstrainTo: Double = 0.0
}

