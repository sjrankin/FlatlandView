//
//  FileIO.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import ImageIO

/// Class to help with file I/O operations.
class FileIO
{
    /// Initialize needed file structures and databases.
    /// - Warning: This function *must* be called prior to using external maps, the earthquake history database,
    ///            and World Heritage Sites. If any is used prior to calling this function, Flatland will be in
    ///            an undefined state.
    public static func Initialize()
    {
        InstallMappableDatabase()
        InstallPOIDatabase()
        //InstallEarthquakeHistoryDatabase()
        InitializeFileStructure()
    }
    
    public static func InstallDatabases()
    {
        InstallDatabase(Name: FileIONames.QuakeHistoryDatabaseS.rawValue)
        InstallDatabase(Name: FileIONames.MappableDatabaseS.rawValue)
        InstallDatabase(Name: FileIONames.Settings.rawValue) 
    }
    
    public static func InstallDatabase(Name: String)
    {
        print("Checking existence of the database \(Name)")
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
                Debug.Print("Created database directory \(DBPath!.path)")
            }
            catch
            {
                fatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + Name
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            Debug.Print("\"\(Name)\" exists at \(LookForExisting.path)")
            return
        }
        let Parts = Name.split(separator: ".", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            Debug.FatalError("Invalid name: \(Name). Must have name part and extension part.")
        }
        let FileName = String(Parts[0])
        let ExtensionName = String(Parts[1])
        if let Source = Bundle.main.path(forResource: FileName,
                                         ofType: ExtensionName)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
                Debug.Print("Installed \(FileName) database.")
            }
            catch
            {
                fatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            fatalError("Did not find \(Name) in bundle.")
        }
    }
    
    public static let AppDirectory = FileIONames.AppDirectory.rawValue
    public static let MapDirectory = FileIONames.MapDirectory.rawValue
    public static let SoundDirectory = FileIONames.SoundDirectory.rawValue
    
    /// Initialize the file structure we need in the user's Documents directory.
    public static func InitializeFileStructure()
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let AppDirURL = DocDirURL.appendingPathComponent(AppDirectory)
        if !DirectoryExists(AppDirURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: AppDirURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(AppDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        let MapsURL = DocDirURL.appendingPathComponent(MapDirectory)
        if !DirectoryExists(MapsURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: MapsURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(MapDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        #if false
        let SoundsURL = DocDirURL.appendingPathComponent(SoundDirectory)
        if !DirectoryExists(SoundsURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: SoundsURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(SoundDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        #endif
    }
    
    /// Read the contents of the map structure file.
    /// - Note: The name of the file is defined in `FileIONames.MapStructure`.
    /// - Returns: The contents of the map structure file. Nil on error.
    public static func GetMapStructure() -> String?
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let AppDirURL = DocDirURL.appendingPathComponent(AppDirectory)
        let FileURL = AppDirURL.appendingPathComponent(FileIONames.MapStructure.rawValue)
        do
        {
            let Raw = try String(contentsOf: FileURL, encoding: .utf8)
            return Raw
        }
        catch
        {
            print("Error reading contents of \(FileURL.path): \(error.localizedDescription)")
        }
        return nil
    }
    
    /// Write the contents of the passed string to the map structure file.
    /// - Note: The name of the file is defined in `FileIONames.MapStructure`.
    /// - Parameter SaveMe: The string to save to the map structure file.
    public static func SetMapStructure(_ SaveMe: String)
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let AppDirURL = DocDirURL.appendingPathComponent(AppDirectory)
        let FileURL = AppDirURL.appendingPathComponent(FileIONames.MapStructure.rawValue)
        do
        {
            try SaveMe.write(to: FileURL, atomically: false, encoding: .utf8)
        }
        catch
        {
            print("Error writing to \(FileIONames.MapStructure.rawValue): \(error.localizedDescription)")
        }
    }
    
    public static let DatabaseDirectory = FileIONames.DatabaseDirectory.rawValue
    
    /// Make sure the mappable site database is installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallMappableDatabase()
    {
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
                Debug.Print("Created database directory \(DBPath!.path)")
            }
            catch
            {
                fatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabase.rawValue
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            Debug.Print("\"\(FileIONames.MappableDatabase.rawValue)\" exists at \(LookForExisting.path)")
            return
        }
        if let Source = Bundle.main.path(forResource: FileIONames.MappableName.rawValue,
                                         ofType: FileIONames.DatabaseExtension.rawValue)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
                Debug.Print("Installed \(FileIONames.MappableName) database.")
            }
            catch
            {
                fatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            fatalError("Did not find \(FileIONames.MappableDatabase.rawValue) in bundle.")
        }
    }
    
    /// Make sure the POI site database is installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallPOIDatabase()
    {
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
                Debug.Print("Created database directory \(DBPath!.path)")
            }
            catch
            {
                fatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + FileIONames.POIDatabase.rawValue
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            Debug.Print("\"\(FileIONames.POIDatabase.rawValue)\" exists at \(LookForExisting.path)")
            return
        }
        if let Source = Bundle.main.path(forResource: FileIONames.POIName.rawValue,
                                         ofType: FileIONames.DatabaseExtension.rawValue)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
                Debug.Print("Installed \(FileIONames.POIName) database.")
            }
            catch
            {
                fatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            fatalError("Did not find \(FileIONames.POIDatabase.rawValue) in bundle.")
        }
    }
    
    /// Make sure the earthquake history database is installed. If not installed, an empty database will be
    /// installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallEarthquakeHistoryDatabase()
    {
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch
            {
                Debug.FatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + FileIONames.QuakeHistoryDatabase.rawValue
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            return
        }
        if let Source = Bundle.main.path(forResource: FileIONames.QuakeName.rawValue,
                                         ofType: FileIONames.DatabaseExtension.rawValue)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
            }
            catch
            {
                Debug.FatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            Debug.FatalError("Did not find \(FileIONames.QuakeHistoryDatabase.rawValue) in bundle.")
        }
    }
    
    /// Returns the URL for the mappable database.
    /// - Returns: URL of the mappable database on success, nil if not found.
    public static func GetMappableDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabase.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    public static func GetMappagleDatabaseSURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabaseS.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the POI database.
    /// - Returns: URL of the POI database on success, nil if not found.
    public static func GetPOIDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.POIDatabase.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the earthquake history database.
    /// - Returns: URL of the earthquake history database on success, nil if not found.
    public static func GetEarthquakeHistoryDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.QuakeHistoryDatabase.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the earthquake history database.
    /// - Returns: URL of the earthquake history database on success, nil if not found.
    public static func GetEarthquakeHistoryDatabaseSURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.QuakeHistoryDatabaseS.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the settings database.
    /// - Returns: URL of the settings database on success, nil if not found.
    public static func GetSettingsDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.Settings.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Determines if the settings exists at its expected location.
    /// - Returns: True if the database is where it is expected to be, false if not.
    public static func SettingsDatabaseExists() -> Bool
    {
        if DirectoryExists(DatabaseDirectory)
        {
            let PathComponent = DatabaseDirectory + "/" + FileIONames.Settings.rawValue
            let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            if FileManager.default.fileExists(atPath: LookForExisting.path)
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if the mappable database exists at its expected location.
    /// - Returns: True if the database is where it is expected to be, false if not.
    public static func MappableDatabaseExists() -> Bool
    {
        if DirectoryExists(DatabaseDirectory)
        {
            let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabase.rawValue
            let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            if FileManager.default.fileExists(atPath: LookForExisting.path)
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if the POI database exists at its expected location.
    /// - Returns: True if the database is where it is expected to be, false if not.
    public static func POIDatabaseExists() -> Bool
    {
        if DirectoryExists(DatabaseDirectory)
        {
            let PathComponent = DatabaseDirectory + "/" + FileIONames.POIDatabase.rawValue
            let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            if FileManager.default.fileExists(atPath: LookForExisting.path)
            {
                return true
            }
        }
        return false
    }
    
    /// Initialize the directory structure. If the structure already exists, remove any existing files that are no longer needed.
    public static func InitializeDirectory()
    {
        
    }
    
    public static func ImageFromFile(WithName: String) -> NSImage?
    {
        if let DocDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        {
//            let Image = NSImage(named: WithName, in: Bundle(for: self), compatibleWith: nil)
            let Image = NSImage(contentsOf: DocDir.appendingPathComponent(WithName))
            return Image
        }
        return nil
    }
    
    public static func ResourceFileList() -> [String]
    {
        var FileList = [String]()
        do
        {
            FileList = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            return FileList
        }
        catch
        {
            print("ResourceFileList error: \(error)")
            return []
        }
    }
    
    /// Determines if the passed file exists.
    /// - Parameter FinalURL: The URL of the file.
    /// - Returns: True if the file exists, false if not.
    public static func FileExists(_ FinalURL: URL) -> Bool
    {
        return FileManager.default.fileExists(atPath: FinalURL.path)
    }
    
    /// Determines if a given directory exists.
    /// - Parameter DirectoryName: The name of the directory to check for existence.
    /// - Returns: True if the directory exists, false if not.
    public static func DirectoryExists(_ DirectoryName: String) -> Bool
    {
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        if CPath == nil
        {
            return false
        }
        return FileManager.default.fileExists(atPath: CPath!.path)
    }
    
    /// Create a directory in the document directory.
    /// - Parameter DirectoryName: Name of the directory to create.
    /// - Returns: URL of the newly created directory on success, nil on error.
    @discardableResult public static func CreateDirectory(DirectoryName: String) -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            return nil
        }
        return CPath
    }
    
    /// Returns the URL of the passed directory. The directory is assumed to be a sub-directory of the
    /// document directory.
    /// - Parameter DirectoryName: Name of the directory whose URL is returned.
    /// - Returns: URL of the directory on success, nil if not found.
    public static func GetDirectoryURL(DirectoryName: String) -> URL?
    {
        if !DirectoryExists(DirectoryName)
        {
            return nil
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        return CPath
    }
    
    /// Returns BlockCam's document directory.
    /// - Returns: The URL of the app's document directory.
    public static func GetDocumentDirectory() -> URL?
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// Delete the specified file.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteFile(_ FileURL: URL)
    {
        do
        {
            try FileManager.default.removeItem(at: FileURL)
        }
        catch
        {
            return
        }
    }
    
    /// Delete the specified file. If the file does not exist, return without any errors being issued.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteIfPresent(_ FileURL: URL)
    {
        if FileManager.default.fileExists(atPath: FileURL.path)
        {
            DeleteFile(FileURL)
        }
    }
    
    /// Loads an image from the file system. This is not intended for images from the photo album (and probably
    /// wouldn't work) but for images in our local directory tree.
    /// - Parameter Name: The name of the image to load.
    /// - Parameter InDirectory: Name of the directory where the file resides.
    /// - Returns: The image if found, nil if not found.
    public static func LoadImage(_ Name: String, InDirectory: String) -> NSImage?
    {
        if !DirectoryExists(InDirectory)
        {
            return nil
        }
        let DirURL = GetDirectoryURL(DirectoryName: InDirectory)
        return NSImage(contentsOfFile: (DirURL?.appendingPathComponent(Name).path)!)
    }
    
    /// Returns a listing of the contents of the specified directory.
    /// - Parameter Directory: The directory whose contents will be returned.
    /// - Returns: Array of strings representing the contents of the specified directory on success, nil on error.
    public static func ContentsOfDirectory(_ Directory: String) -> [String]?
    {
        do
        {
            let Results = try FileManager.default.contentsOfDirectory(atPath: Directory)
            return Results
        }
        catch
        {
            return nil
        }
    }
}


