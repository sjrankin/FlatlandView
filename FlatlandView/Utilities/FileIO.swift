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
import Photos

/// Class to help with file I/O operations.
class FileIO
{
    /// Initialize needed file structures and databases.
    public static func Initialize()
    {
        InstallDatabase()
        InitializeFileStructure()
    }
    
    public static let AppDirectory = "Flatland"
    public static let MapDirectory = "Flatland/Maps"
    
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
                print("Error creating \(AppDirectory) in Documents: \(error.localizedDescription)")
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
                print("Error creating \(MapDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
    }
    
    public static func LoadMapDirectory() -> String
    {
        
    }
    
    public static let DatabaseDirectory = "/Database"
    
    /// Make sure the Unesco world heritage site database is installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallDatabase()
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
                fatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(DatabaseDirectory + "/UnescoSites.db")
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            return
        }
        if let Source = Bundle.main.path(forResource: "UnescoSites", ofType: "db")
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(DatabaseDirectory + "/UnescoSites.db")
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
            }
            catch
            {
                fatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            fatalError("Did not find UnescoSites.db in bundle.")
        }
    }
    
    /// Returns the URL for the Unesco database.
    /// - Returns: URL of the Unesco database on success, nil if not found.
    public static func GetDatabaseURL() -> URL?
    {
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(DatabaseDirectory + "/UnescoSites.db")
        return DBURL
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


