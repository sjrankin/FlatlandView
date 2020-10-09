//
//  +MainSnapshot.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    /// Get a snapshot of the client window and save it.
    /// - Notes:
    ///   - The method used to create the snapshot initially saves the entire window, non-client as well
    ///     as the client area. This function crops the non-client area from the initial image.
    ///   - This function uses the scaling factor of the screen to determine the final resolution of the
    ///     snapshot image.
    ///      - This function works at the resolution of the user's montior. If there are multiple monitors
    ///        with different pixel densities, it is possible the saved image will be low resolution.
    ///   - This function will work equally on 3D content and 2D content.
    func CreateClientSnapshot()
    {
        let Multiplier = NSScreen.main!.backingScaleFactor
        var ImageOptions = CGWindowImageOption()
        if Multiplier == 2.0
        {
            ImageOptions = [CGWindowImageOption.boundsIgnoreFraming, CGWindowImageOption.bestResolution]
        }
        else
        {
            ImageOptions = [CGWindowImageOption.boundsIgnoreFraming, CGWindowImageOption.nominalResolution]
        }
        if let Ref = CGWindowListCreateImage(CGRect.zero, CGWindowListOption.optionIncludingWindow, WindowID(),
                                             ImageOptions)
        {
            let ViewHeight = PrimaryView.bounds.height
            let WindowFrame = view.window?.frame
            let Delta = abs(ViewHeight - WindowFrame!.height) * Multiplier
            let PrimarySize = NSSize(width: PrimaryView.bounds.size.width * Multiplier,
                                     height: PrimaryView.bounds.size.height * Multiplier)
            let ClientRect = NSRect(origin: NSPoint(x: 0, y: Delta), size: PrimarySize)
            let ClientAreaImage = Ref.cropping(to: ClientRect)
            let ScreenImage = NSImage(cgImage: ClientAreaImage!, size: PrimarySize)
            SaveImage(ScreenImage)
        }
    }
    
    /// Save the specified image to a file.
    /// - Note: Images are saved as .png files.
    /// - Parameter Image: The image to save.
    func SaveImage(_ Image: NSImage)
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
    func GetSaveLocation() -> URL?
    {
        let SavePanel = NSSavePanel()
        SavePanel.showsTagField = true
        SavePanel.title = "Save Image"
        SavePanel.allowedFileTypes = ["png"]
        SavePanel.canCreateDirectories = true
        SavePanel.nameFieldStringValue = "Flatland Snapshot.png"
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
