//
//  Snapshot.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Enables taking snapshots of a specified view.
class Snapshot
{
    /// Object to ensure only one caller per time.
    private static var LockingObject = NSObject()
    
    /// Take a snapshot of the passed view. The image will be saved according to the user.
    /// - Note: Only one thread at a time may use this function.
    /// - Parameter View: The view that will supply the image.
    /// - Parameter WindowID: The ID of the window.
    /// - Parameter Frame: The frame of the view.
    /// - Returns: Image of the passed view on success, nil on error.
    public static func MakeImage(From View: NSView, WindowID: CGWindowID, Frame: CGRect) -> NSImage?
    {
        objc_sync_enter(LockingObject)
        defer{objc_sync_exit(LockingObject)}
        
        let Multiplier = NSScreen.main!.backingScaleFactor
        var ImageOptions = CGWindowImageOption()
        ImageOptions = [CGWindowImageOption.boundsIgnoreFraming, CGWindowImageOption.bestResolution]
        if let Ref = CGWindowListCreateImage(CGRect.zero, CGWindowListOption.optionIncludingWindow, WindowID,
                                             ImageOptions)
        {
            let ViewHeight = View.bounds.height
            let WindowFrame = Frame
            let Delta = abs(ViewHeight - WindowFrame.height) * Multiplier
            let PrimarySize = NSSize(width: View.bounds.size.width * Multiplier,
                                     height: View.bounds.size.height * Multiplier)
            let ClientRect = NSRect(origin: NSPoint(x: 0, y: Delta), size: PrimarySize)
            let ClientAreaImage = Ref.cropping(to: ClientRect)
            let ScreenImage = NSImage(cgImage: ClientAreaImage!, size: PrimarySize)
            return ScreenImage
        }
        return nil
    }
    
    /// Take a snapshot of the passed view. The image will be saved according to the user.
    /// - Note: Only one thread at a time may use this function.
    /// - Parameter View: The view that will supply the image.
    /// - Parameter WindowID: The ID of the window.
    /// - Parameter Frame: The frame of the view.
    public static func Take(From View: NSView, WindowID: CGWindowID, Frame: CGRect)
    {
        if let SnapshotImage = MakeImage(From: View, WindowID: WindowID, Frame: Frame)
        {
            SaveImage(SnapshotImage)
        }
    }
    
    /// Save the specified image to a file.
    /// - Note: Images are saved as .png files.
    /// - Parameter Image: The image to save.
    private static func SaveImage(_ Image: NSImage)
    {
        if let SaveWhere = GetSaveLocation()
        {
            let OK = Image.WritePNG(ToURL: SaveWhere)
            if OK
            {
                return
            }
        }
    }
    
    /// Get the URL where to save an image file.
    /// - Note: Only `.png` files are supported.
    /// - Returns: The URL of the target location on success, nil on error or user cancellation.
    private static func GetSaveLocation() -> URL?
    {
        let SavePanel = NSSavePanel()
        SavePanel.showsTagField = true
        SavePanel.title = "Save Image"
        SavePanel.allowedFileTypes = ["png"]
        SavePanel.canCreateDirectories = true
        let Now = Date()
        let PrettyDate = Now.PrettyDate()
        let PrettyTime = Now.PrettyTime(ForFileName: true)
        SavePanel.nameFieldStringValue = "Flatland Snapshot \(PrettyDate), \(PrettyTime).png"
        SavePanel.level = .modalPanel
        if SavePanel.runModal() == .OK
        {
            return SavePanel.url
        }
        else
        {
            return nil
        }
    }
}
