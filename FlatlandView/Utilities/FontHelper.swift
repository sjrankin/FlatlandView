//
//  FontHelper.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Font-related helper functions.
class FontHelper
{
    /// Initialize data tables.
    static func Initialize()
    {
        let FontFamilies = NSFontManager.shared.availableFonts
        for Family in FontFamilies
        {
            let FD = FontDataType(Family)
            if let MemberData = NSFontManager.shared.availableMembers(ofFontFamily: Family)
            {
                var PSNames = [(String, String)]()
                for Member in MemberData
                {
                    if let PSName = Member[0] as? String
                    {
                        if let FontName = Member[1] as? String
                        {
                            PSNames.append((FontName, PSName))
                        }
                    }
                }
                for (FontName, PSName) in PSNames
                {
                    FD.Variants.append((FontName, PSName))
                }
            }
            FontData.append(FD)
        }
        FontData.sort(by: {$0.FontFamilyName.caseInsensitiveCompare($1.FontFamilyName) == .orderedAscending})
    }
    
    /// Holds the font data table.
    private static var _FontData: [FontDataType] = [FontDataType]()
    /// Get or set the table of fonts.
    public static var FontData: [FontDataType]
    {
        get
        {
            return _FontData
        }
        set
        {
            _FontData = newValue
        }
    }
    
    /// Find the font family name for the passed Postscript name.
    /// - Parameter Postscript: The Postscript font name.
    /// - Returns: The font family associated with `Postscript` on success, nil if not found.
    public static func FontFamilyForPostscriptFile(_ Postscript: String) -> String?
    {
        if let CachedName = FontFamilyNameCache[Postscript]
        {
            return CachedName
        }
        for FData in FontData
        {
            for (_, PSName) in FData.Variants
            {
                if PSName.compare(Postscript) == .orderedSame
                {
                    FontFamilyNameCache[Postscript] = FData.FontFamilyName
                    return FData.FontFamilyName
                }
            }
        }
        return nil
    }
    
    /// Cache for searched Postscript font family names.
    private static var FontFamilyNameCache = [String: String]()
}
