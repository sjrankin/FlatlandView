//
//  Barcodes.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/18/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

class Barcodes
{
    /// Skews the passed image.
    /// - Note:
    ///    - Skewing occurs symmetrically on the horizontal axis - either the top or bottom is enlarged.
    ///    - See [CIPerspectiveTransform](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIPerspectiveTransform)
    /// - Parameter Image: The source image to skew.
    /// - Parameter TopPercent: Percent value (normal form) for the skewing. Skewing, for example, by `0.2` means
    ///                         the left side will be 20% of the base width to the left of the base left side, and
    ///                         the right side will be 20% of the base width to the right of the base right side,
    ///                         for a total of 40% distortion. **This value must be between 0.0 and 1.0. Invalid
    ///                         values are clamped to a normal range.** This affects the top of the image only.
    /// - Parameter BottomPercent: Percent value (normal form) for the skewing. Skewing, for example, by `0.2` means
    ///                            the left side will be 20% of the base width to the left of the base left side, and
    ///                            the right side will be 20% of the base width to the right of the base right side,
    ///                            for a total of 40% distortion. **This value must be between 0.0 and 1.0. Invalid
    ///                            values are clamped to a normal range.** This affects the bottom of the image only.
    /// - Returns: Skewed image.
    private static func SkewImage(_ Image: NSImage, TopPercent: Double, BottomPercent: Double) -> NSImage
    {
        let SourceTiff = Image.tiffRepresentation!
        let Working = CIImage(data: SourceTiff)!
        let Skew = CIFilter.perspectiveTransform()
        let Base = Image.size.width
        var TopOffset: CGFloat = 0.0
        var BottomOffset: CGFloat = 0.0
        var FinalTopPercent = TopPercent
        if FinalTopPercent < 0.0
        {
            FinalTopPercent = 0.0
        }
        if FinalTopPercent > 1.0
        {
            FinalTopPercent = 1.0
        }
        var FinalBottomPercent = BottomOffset
        if FinalBottomPercent < 0.0
        {
            FinalBottomPercent = 0.0
        }
        if FinalBottomPercent > 1.0
        {
            FinalBottomPercent = 1.0
        }
        
        TopOffset = Base * CGFloat(FinalTopPercent)
        BottomOffset = Base * CGFloat(FinalBottomPercent)
        Skew.topLeft = CGPoint(x: -TopOffset, y: Image.size.height)
        Skew.topRight = CGPoint(x: Image.size.width + TopOffset, y: Image.size.height)
        Skew.bottomLeft = CGPoint(x: -BottomOffset, y: 0)
        Skew.bottomRight = CGPoint(x: Image.size.width + BottomOffset, y: 0)
        Skew.inputImage = Working
        let Result = Skew.outputImage
        let ResRep = NSCIImageRep(ciImage: Result!)
        let NImage = NSImage(size: ResRep.size)
        NImage.addRepresentation(ResRep)
        return NImage
    }
    
    /// Resize the passed image.
    /// - Note: Probably a duplicate of already existing code.
    /// - Parameter Image: The image to resize.
    /// - Parameter To: New image size.
    /// - Returns: New image with the specified size.
    private static func Resize(_ Image: NSImage, To Size: NSSize) -> NSImage
    {
        let NewImage = NSImage(size: Size)
        NewImage.lockFocus()
        Image.draw(in: NSRect(x: 0, y: 0, width: Size.width, height: Size.height),
                   from: NSRect(x: 0, y: 0, width: Image.size.width, height: Image.size.height),
                   operation: .sourceOver, fraction: 1.0)
        NewImage.unlockFocus()
        NewImage.size = Size
        return NSImage(data: NewImage.tiffRepresentation!)!
    }
    
    /// Converts the image to black and clear.
    /// - Parameter In: The image to convert.
    /// - Returns: New image with all white pixels converted to clear and all other pixels converted to black.
    private static func ReplaceColor(In Image: NSImage) -> NSImage
    {
        let SourceTiff = Image.tiffRepresentation!
        let Working = CIImage(data: SourceTiff)!
        let FalseColor = CIFilter.falseColor()
        FalseColor.color0 = CIColor(color: NSColor.black)!
        FalseColor.color1 = CIColor(color: NSColor.clear)!
        FalseColor.inputImage = Working
        let Result = FalseColor.outputImage
        let ResRep = NSCIImageRep(ciImage: Result!)
        let NImage = NSImage(size: ResRep.size)
        NImage.addRepresentation(ResRep)
        return NImage
    }
    
    /// Add a number to the passed image.
    /// - Note:
    ///   - This function assumes the passed image is a QR barcode.
    ///   - This function assumes the number passed is 10 or less.
    ///   - Depending on the value of `NumberOnTop`, different colors and alpha levels will be used for the
    ///     text.
    /// - Parameter To: The image to which a number will be added.
    /// - Parameter Number: The number to add. The number is rounded to 1 trailing digit.
    /// - Parameter NumberOnTop: Determines the location of the number. If true, the number is overlayed on
    ///                          top of the passed image (and the image is not processed with `ReplaceColor`.
    ///                          If false, the number is under the image (which is presumed to be a QR code
    ///                          barcode) and the source image is processed with `ReplaceColor`. This means
    ///                          final returned image will have a transparent background. Defaults to `true`.
    /// - Returns: Image with the number overlayed.
    private static func AddOverlayNumber(To: NSImage, Number: Double,
                                         NumberOnTop: Bool = true) -> NSImage
    {
        var WorkingImage = To
        if !NumberOnTop
        {
            WorkingImage = ReplaceColor(In: To)
        }
        let NewImage = NSImage(size: To.size)
        NewImage.lockFocus()
        let DrawRect = NSRect(x: 0, y: 0, width: WorkingImage.size.width,
                              height: WorkingImage.size.height)
        
        let String = "\(Number.RoundedTo(1))"
        var Attrs = [NSAttributedString.Key: Any]()
        let Font = NSFont.boldSystemFont(ofSize: CGFloat(BarcodeConstants.OverlayTextSize.rawValue))
        Attrs[NSAttributedString.Key.font] = Font as Any
        Attrs[NSAttributedString.Key.backgroundColor] = NSColor.clear as Any
        let Alpha = NumberOnTop ? BarcodeConstants.TextOnTopAlpha.rawValue : BarcodeConstants.TextOnBottomAlpha.rawValue
        let TextColor = NumberOnTop ? NSColor.red : NSColor.cyan
        Attrs[NSAttributedString.Key.foregroundColor] = TextColor.withAlphaComponent(CGFloat(Alpha)) as Any
        if !NumberOnTop
        {
            Attrs[NSAttributedString.Key.strokeColor] = NSColor.blue as Any
            Attrs[NSAttributedString.Key.strokeWidth] = -3 as Any
        }
        else
        {
            Attrs[NSAttributedString.Key.strokeColor] = NSColor.cyan.withAlphaComponent(CGFloat(Alpha)) as Any
            Attrs[NSAttributedString.Key.strokeWidth] = -3 as Any
        }
        let AString = NSAttributedString(string: String, attributes: Attrs)
        let ASize = AString.size()
        let HalfStringWidth = ASize.width / 2.0
        let HalfStringHeight = ASize.height / 2.0
        let DrawAt = NSPoint(x: To.size.width / 2 - HalfStringWidth,
                             y: To.size.height / 2 - HalfStringHeight)
        if NumberOnTop
        {
            WorkingImage.draw(in: DrawRect, from: DrawRect,
                              operation: .sourceOver, fraction: 1.0)
            AString.draw(at: DrawAt)
        }
        else
        {
            AString.draw(at: DrawAt)
            WorkingImage.draw(in: DrawRect, from: DrawRect,
                              operation: .sourceOver, fraction: 1.0)
        }
        
        NewImage.unlockFocus()
        NewImage.size = To.size
        return NSImage(data: NewImage.tiffRepresentation!)!
    }
    
    /// Create a QR barcode and return it as an image.
    /// - Note: See [How to create a QR code](https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code)
    /// - Parameter With: The text to use to create the barcode. The data must be within the ISO Latin1
    ///                   character set.
    /// - Parameter FinalSize: The returned size of the final barcode.
    /// - Parameter Digit: A value to overlay on the barcode. For best results, the value should be 9 or less. Values
    ///                    are truncated to a single trailing digit. Defaults to `nil` meaning no digits will
    ///                    be overlayed.
    /// - Parameter DigitOnTop: If true, the overlayed number will be overlayed on top of the barcode. If false,
    ///                         the barcode is on top of the number.
    /// - Parameter CorrectionLevel: Determines how the QR barcode is constructed in terms of error correction.
    ///                              Valid values are: "L", "M", "Q", and "H". Invalid values are changed to "M".
    ///                              Default value is "M".
    /// - Parameter TopSkewValue: The percent (this value *must* be normalized) to skew the top
    ///                           of the image.  Defaults to nil.
    /// - Parameter BottomSkewValue: The percent (this value *must* be normalized) to skew the bottom
    ///                              of the image.  Defaults to nil.
    /// - Returns: Image of the QR code with the specified data and attributes. Nil on error.
    public static func QRCode(With Text: String, FinalSize: NSSize, 
                              Digit: Double? = nil, DigitOnTop: Bool = true,
                              CorrectionLevel: String = "M",
                              TopSkewValue: Double? = nil, BottomSkewValue: Double? = nil) -> NSImage?
    {
        let Filter = CIFilter.qrCodeGenerator()
        guard let TextData = Text.data(using: .isoLatin1, allowLossyConversion: false) else
        {
            return nil
        }
        Filter.message = TextData
        var Correct = CorrectionLevel.uppercased()
        if !["L", "M", "Q", "H"].contains(Correct)
        {
            Correct = "M"
        }
        Filter.correctionLevel = Correct
        guard let QRImage = Filter.outputImage else
        {
            return nil
        }
        let Transform = CGAffineTransform(scaleX: 3, y: 3)
        let Rep = NSCIImageRep(ciImage: QRImage.transformed(by: Transform))
        var NImage = NSImage(size: Rep.size)
        NImage.addRepresentation(Rep)

        if let Number = Digit
        {
            NImage = AddOverlayNumber(To: NImage, Number: Number, NumberOnTop: DigitOnTop)
        }
        
        if TopSkewValue != nil || BottomSkewValue != nil
        {
            let SkewTopPercent = TopSkewValue ?? 0.0
            let SkewBottomPercent = BottomSkewValue ?? 0.0
            NImage = SkewImage(NImage, TopPercent: SkewTopPercent, BottomPercent: SkewBottomPercent)
        }
        
        return NImage
    }
}
