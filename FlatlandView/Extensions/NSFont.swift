//
//  NSFont.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/11/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension NSFont
{
    /// Try to create a font with the passed name and size.
    /// - Parameter Name: The **PostScript** name of the font to create.
    /// - Parameter Size: The size of the font to return.
    /// - Parameter Default: PostScript name of the font to use if the font specified in `Name` cannot be
    ///                      created. Defaults to empty string. If empty string is passed and the font in
    ///                      `Name` cannot be created, `NSFont.systemFont` is returned.
    /// - Returns: Font created from `Name` and `Size` on success, `NSFont.systemFont` on error.
    public static func TryGet(_ Name: String, Size: CGFloat = 12.0, Default: String = "") -> NSFont
    {
        if let Font = NSFont(name: Name, size: Size)
        {
            return Font
        }
        if Default.isEmpty
        {
            return NSFont.systemFont(ofSize: Size)
        }
        return TryGet(Default, Size: Size, Default: "")
    }
    
    /// Returns a font with the name in `InOrder`, traversing the array until a valid font can be returned.
    /// - Parameter InOrder: Array of font names (*in PostScript format*) in priority order (highest priority
    ///                      is at index 0 and lowest priority in the last position). The first successfully
    ///                      created font will be returned.
    /// - Parameter Size: The size of the font to return.
    /// - Returns: The first successfully create font from `InOrder`. If no fonts were created successfully,
    ///            `NSFont.systemFont` will be returned.
    public static func GetFont(InOrder: [String], Size: CGFloat) -> NSFont
    {
        for Name in InOrder
        {
            if let Font = NSFont(name: Name, size: Size)
            {
                return Font
            }
        }
        return NSFont.systemFont(ofSize: Size)
    }
}
