//
//  AttributedText.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/11/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Class that converts text strings into attributed strings.
class AttributedText
{
    /// Initialize the class. Not necessary to be called - called whenever a new string is converted.
    public static func Initialize()
    {
        Delimiter = "|"
        PrimaryAttributes = CharAttribute(0)
    }
    
    /// Get or set the delimiter character.
    public static var Delimiter = "|"
    
    /// Precondition the string before it is parsed.
    /// - Parameter Raw: The string to precondition.
    /// - Returns: Preconditioned string.
    private static func Precondition(_ Raw: String) -> String
    {
        let Working = Raw.replacingOccurrences(of: "|nl|", with: "\n")
        return Working
    }
    
    public static var PrimaryAttributes = CharAttribute(0)
    
    private static func Tokenize(_ Raw: String, _ Delimiter: String = "|") -> [String]
    {
        var Tokens = [String]()
        let Conditioned = Precondition(Raw)
        var Working = ""
        var InAttribute = false
        for Char in Conditioned
        {
            if String(Char) == "|"
            {
                if InAttribute
                {
                    Working.append(String(Char))
                    InAttribute = false
                    Tokens.append(Working)
                    Working = ""
                    continue
                }
                else
                {
                    InAttribute = true
                    Tokens.append(Working)
                    Working = String(Char)
                    continue
                }
            }
            Working.append(String(Char))
        }
        if !Working.isEmpty
        {
            Tokens.append(Working)
        }
        return Tokens
    }
    
    private static func MakeTextColor(From: String) -> NSColor
    {
        switch From.lowercased()
        {
            case "black":
                return NSColor.black
            case "white":
                return NSColor.white
            case "gray":
                return NSColor.gray
            case "blue":
                return NSColor.blue
            case "cyan":
                return NSColor.cyan
            case "yellow":
                return NSColor.yellow
            case "red":
                return NSColor.red
            case "magenta":
                return NSColor.magenta
            case "brown":
                return NSColor.brown
            case "teal":
                return NSColor.systemTeal
            case "orange":
                return NSColor.orange
            case "systemyellow":
                return NSColor.systemYellow
            case "green":
                return NSColor.green
            case "systemgreen":
                return NSColor.systemGreen
            case "systemblue":
                return NSColor.systemBlue
            case "systempink":
                return NSColor.systemPink
            case "clear":
                return NSColor.clear
            default:
                print("Did not find color \(From)")
                return NSColor.black
        }
    }
    
    private static func MakeFont(From: String) -> (FontTypes, CGFloat)?
    {
        var Parts = From.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count < 2
        {
            print("Bad parts count: \(Parts.count)")
            return nil
        }
        var Size: CGFloat = 16.0
        var Type: FontTypes = .System
        Parts.removeFirst()
        for SubPart in Parts
        {
            let Attrs = String(SubPart).split(separator: "=", omittingEmptySubsequences: true)
            if Attrs.count == 2
            {
                switch String(Attrs[0]).lowercased()
                {
                    case "type":
                        switch String(Attrs[1].lowercased())
                        {
                            case "system":
                                Type = .System
                            case "bold":
                                Type = .Bold
                            case "mono":
                                Type = .Mono
                            default:
                                print("Unknown type \(Attrs[1])")
                                return nil
                        }
                    case "size":
                        if let Actual = Double(String(Attrs[1]))
                        {
                            Size = CGFloat(Actual)
                        }
                        else
                        {
                            print("Bad font size: \(Attrs[1])")
                        }
                    default:
                        print("Unknown font attribute \(Attrs[0])")
                        return nil
                }
            }
        }
        switch Type
        {
            case .Bold:
                Type = .Bold
                
            case .Mono:
                Type = .Mono
                
            case .System:
                Type = .System
        }
        return (Type, Size)
    }
    
    private static func MakeOutline(_ Raw: String) -> (Double, NSColor)?
    {
        print("Parsing outline")
        var Parts = Raw.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count < 2
        {
            print("Bad parts count: \(Parts.count)")
            return nil
        }
        var Width: Double = 1.0
        var Color: NSColor = NSColor.black
        Parts.removeFirst()
        for SubPart in Parts
        {
            let Attrs = String(SubPart).split(separator: "=", omittingEmptySubsequences: true)
            if Attrs.count == 2
            {
                switch String(Attrs[0]).lowercased()
                {
                    case "color":
                        Color = MakeTextColor(From: String(Attrs[1]))
                        
                    case "width":
                        if let Actual = Double(String(Attrs[1]))
                        {
                            Width = Actual
                        }
                        else
                        {
                            print("Invalid width \(Attrs[1])")
                            return nil
                        }
                        
                    default:
                        print("Unknown attribute \(Attrs[0])")
                        return nil
                }
            }
        }
        return (Width, Color)
    }
    
    private static var Sequence: Int = 0
    
    private static func ParseTextAttribute(_ Raw: String) -> CharAttribute
    {
        let Attr = CharAttribute(Sequence)
        Sequence = Sequence + 1
        Attr.NewLine = false
        let Working = Raw.replacingOccurrences(of: "|", with: "")
        let Parts = Working.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let SubParts = String(Part).split(separator: " ", omittingEmptySubsequences: true)
            switch String(SubParts[0]).lowercased()
            {
                case "outline":
                    if SubParts.count > 1
                    {
                        if let (Width, Color) = MakeOutline(String(Part))
                        {
                            Attr.StrokeWidth = Width
                            Attr.StrokeColor = Color
                        }
                    }
                    
                case "font":
                    if let (Type, Size) = MakeFont(From: String(Part))
                    {
                        Attr.FontType = Type
                        Attr.FontSize = Size
                    }
                    else
                    {
                        Debug.Print("Error creating font")
                    }
                    
                case "color":
                    if SubParts.count > 1
                    {
                        Attr.TextColor = MakeTextColor(From: String(SubParts[1]))
                    }
                    
                case "bgcolor":
                    if SubParts.count > 1
                    {
                        Attr.BackColor = MakeTextColor(From: String(SubParts[1]))
                    }
                    
                case "nl":
                    Attr.NewLine = true
                    
                default:
                    continue
            }
        }
        return Attr
    }
    
    private static func MakeAttributeMap(_ Tokens: [String]) -> [CharAttribute]
    {
        var AMap = [CharAttribute]()
        let CurrentAttributes = PrimaryAttributes
        for Token in Tokens
        {
            if Token.starts(with: "|")
            {
                let TokenAttributes = ParseTextAttribute(Token)
                CurrentAttributes.MergeWith(TokenAttributes)
                continue
            }
            for TokenChar in Token
            {
                let TokenAttribute = CharAttribute(From: CurrentAttributes)
                TokenAttribute.Character = String(TokenChar)
                AMap.append(TokenAttribute)
            }
        }
        return AMap
    }
    
    /// Convert the raw string into an attributed string.
    /// - Parameter Raw: The raw string to convert.
    /// - Parameter Delimiter: The string to use as an attribute delimiter. Defaults to `|`.
    /// - Parameter FontSize: The default font size. Defaults to `16.0`.
    /// - Returns: Prettified string.
    public static func ConvertText(_ Raw: String, Delimiter: String = "|", FontSize: CGFloat = 16.0) -> NSMutableAttributedString
    {
        Initialize()
        PrimaryAttributes.FontSize = FontSize
        PrimaryAttributes.FontType = .System
        let Tokens = Tokenize(Raw, Delimiter)
        let AMap = MakeAttributeMap(Tokens)
        let Final = DoConvertText(From: AMap)
        return Final
    }
    
    private static func DoConvertText(From: [CharAttribute]) -> NSMutableAttributedString
    {
        let Result = NSMutableAttributedString()
        for CAttr in From
        {
            var Attributes = [NSAttributedString.Key: Any]()
            if CAttr.FontSize != nil && CAttr.FontType != nil
            {
                var Font = NSFont.systemFont(ofSize: 16.0)
                switch CAttr.FontType!
                {
                    case .Bold:
                        Font = NSFont.boldSystemFont(ofSize: CAttr.FontSize!)
                    case .Mono:
                        Font = NSFont.monospacedSystemFont(ofSize: CAttr.FontSize!, weight: .regular)
                    case .System:
                        Font = NSFont.systemFont(ofSize: CAttr.FontSize!)
                }
                Attributes[NSAttributedString.Key.font] = Font as Any
            }
            if CAttr.TextColor != nil
            {
                Attributes[NSAttributedString.Key.foregroundColor] = CAttr.TextColor as Any
            }
            if CAttr.BackColor != nil
            {
                Attributes[NSAttributedString.Key.backgroundColor] = CAttr.BackColor as Any
            }
            if CAttr.StrokeColor != nil && CAttr.StrokeWidth != nil
            {
                Attributes[NSAttributedString.Key.strokeColor] = CAttr.StrokeColor! as Any
                Attributes[NSAttributedString.Key.strokeWidth] = -CAttr.StrokeWidth! as Any
            }
            let OneChar = NSMutableAttributedString(string: CAttr.Character, attributes: Attributes)
            Result.append(OneChar)
        }
        return Result
    }
}

class CharAttribute: CustomDebugStringConvertible
{
    init(_ Sequence: Int)
    {
        self.Sequence = Sequence
    }
    
    init(From: CharAttribute)
    {
        self.NewLine = From.NewLine
        self.TextColor = From.TextColor
        self.BackColor = From.BackColor
        self.FontType = From.FontType
        self.FontSize = From.FontSize
        self.StrokeColor = From.StrokeColor
        self.StrokeWidth = From.StrokeWidth
        self.Sequence = From.Sequence
    }
    
    var Sequence: Int = -1
    
    var debugDescription: String
    {
        get
        {
            var Debug = "\"\(Character)\": "
            Debug.append("Index=\(Index) ")
            Debug.append("Sequence=\(Sequence) ")
            if FontType != nil
            {
                Debug.append("FontType=\(FontType!) ")
            }
            if FontSize != nil
            {
                Debug.append("FontSize=\(FontSize!) ")
            }
            if TextColor != nil
            {
                Debug.append("TextColor=\(TheColor(TextColor!)) ")
            }
            if BackColor != nil
            {
                Debug.append("BackColor=\(TheColor(BackColor!)) ")
            }
            if StrokeWidth != nil
            {
                Debug.append("StrokeWidth=\(StrokeWidth!) ")
            }
            if StrokeColor != nil
            {
                Debug.append("StrokeColor=\(TheColor(StrokeColor!))")
            }
            return Debug
        }
    }
    
    var Character: String = ""
    var Index: Int = -1
    var NewLine: Bool = false
    var FontSize: CGFloat? = nil
    var FontType: FontTypes? = nil
    var TextColor: NSColor? = nil
    var BackColor: NSColor? = nil
    var StrokeWidth: Double? = nil
    var StrokeColor: NSColor? = nil
    
    func TheColor(_ Raw: NSColor, IncludeAlpha: Bool = false) -> String
    {
        let Working: CIColor = CIColor(color: Raw)!
        let NR = Int(Working.red * 255.0)
        let NG = Int(Working.green * 255.0)
        let NB = Int(Working.blue * 255.0)
        let NA = Int(Working.alpha * 255.0)
        var FinalR = String(NR, radix: 16, uppercase: false)
        if FinalR.count < 2
        {
            FinalR = "0" + FinalR
        }
        var FinalG = String(NG, radix: 16, uppercase: false)
        if FinalG.count < 2
        {
            FinalG = "0" + FinalG
        }
        var FinalB = String(NB, radix: 16, uppercase: false)
        if FinalB.count < 2
        {
            FinalB = "0" + FinalB
        }
        var FinalString = "#\(FinalR)\(FinalG)\(FinalB)"
        if IncludeAlpha
        {
            var FinalA = String(NA, radix: 16, uppercase: false)
            if FinalA.count < 2
            {
                FinalA = "0" + FinalA
            }
            FinalString.append("\(FinalA)")
        }
        return FinalString
    }
    
    func MergeWith(_ Other: CharAttribute)
    {
        self.Sequence = Other.Sequence
        if Other.BackColor != nil
        {
            self.BackColor = Other.BackColor
        }
        if Other.TextColor != nil
        {
            self.TextColor = Other.TextColor
        }
        if Other.FontSize != nil
        {
            self.FontSize = Other.FontSize
        }
        if Other.FontType != nil
        {
            self.FontType = Other.FontType
        }
        if Other.StrokeColor != nil
        {
            self.StrokeColor = Other.StrokeColor
        }
        if Other.StrokeWidth != nil
        {
            self.StrokeWidth = Other.StrokeWidth
        }
    }
}

enum FontTypes: String
{
    case Bold = "Bold"
    case System = "System"
    case Mono = "Mono"
}

