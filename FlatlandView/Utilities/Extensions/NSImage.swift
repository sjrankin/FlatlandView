//
//  NSImage.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/30/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreImage.CIFilterBuiltins

// MARK: - NSImage extensions.

/// Extension methods for UIImage.
extension NSImage
{
    /// Initializer that creates a solid color image of the passed size.
    /// - Note: Do *not* use the draw swatch function as it incorrectly draws transparent colors.
    /// - Parameter Color: The color to use to create the image.
    /// - Parameter Size: The size of the image.
    convenience init(Color: NSColor, Size: NSSize)
    {
        self.init(size: Size)
        lockFocus()
        let FinalColor = Color.usingColorSpace(.sRGB)!
        FinalColor.setFill()
        unlockFocus()
    }
    
    #if false
    /// Rotate the instance image to the number of passed radians.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Radians: Number of radians to rotate the image to.
    /// - Returns: Rotated image.
    func Rotate(Radians: CGFloat) -> NSImage
    {
        var NewSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: Radians)).size
        NewSize.width = floor(NewSize.width)
        NewSize.height = floor(NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, self.scale)
        let Context = UIGraphicsGetCurrentContext()
        Context?.translateBy(x: NewSize.width / 2, y: NewSize.height / 2)
        Context?.rotate(by: Radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))
        let Rotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Rotated!
    }
    #else
    //https://stackoverflow.com/questions/31699235/rotate-nsimage-in-swift-cocoa-mac-osx
    func Rotate(Radians: CGFloat) -> NSImage
    {
        let SinDegrees = abs(Radians)
        let CosDegrees = abs(Radians)
        let newSize = CGSize(width: size.height * SinDegrees + size.width * CosDegrees,
                             height: size.width * SinDegrees + size.height * CosDegrees)
        
        let imageBounds = NSRect(x: (newSize.width - size.width) / 2,
                                 y: (newSize.height - size.height) / 2,
                                 width: size.width, height: size.height)
        
        let otherTransform = NSAffineTransform()
        otherTransform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
        otherTransform.rotate(byRadians: Radians)
        otherTransform.translateX(by: -newSize.width / 2, yBy: -newSize.height / 2)
        
        let rotatedImage = NSImage(size: newSize)
        rotatedImage.lockFocus()
        otherTransform.concat()
        draw(in: imageBounds, from: CGRect.zero, operation: NSCompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    #endif
    
    /// Rotate the instance image of the number of passed degrees.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Degrees: Number of degrees to rotate the image to.
    /// - Returns: Rotated image.
    func Rotate(Degrees: CGFloat) -> NSImage
    {
        return Rotate(Radians: Degrees.Radians)
    }
    
    /// Set's the instance image's alpha value (for all pixels).
    /// - Notes: See [Set alpha of image programmatically](https://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-an-uiimage-in-swift-programmatically).
    /// - Parameter Value: The new alpha value.
    /// - Returns: New image with all pixels set to the passed alpha value.
    func Alpha(_ Value: CGFloat) -> NSImage
    {
        let ImageRect = NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let ImageRep = self.bestRepresentation(for: ImageRect, context: nil, hints: nil) else
        {
            fatalError("Error creating image representation.")
        }
        let Image = NSImage(size: self.size, flipped: false, drawingHandler:
                                {
                                    _ in
                                    return ImageRep.draw(in: NSRect(origin: NSPoint.zero, size: self.size),
                                                         from: NSRect(origin: NSPoint.zero, size: self.size),
                                                         operation: .copy, fraction: Value, respectFlipped: false,
                                                         hints: nil)
                                }
        )
        return Image
    }
    
    /// Write the instance image to a file.
    /// - Note: See [How to save an NSImage as a file.](https://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file)
    /// - Parameter ToURL: The URL where to save the image.
    /// - Returns: True on success, false if the image cannot be saved.
    public func WritePNG(ToURL: URL) -> Bool
    {
        guard let Data = tiffRepresentation,
              let Rep = NSBitmapImageRep(data: Data),
              let ImgData = Rep.representation(using: .png, properties: [.compressionFactor: NSNumber(floatLiteral: 1.0)]) else
        {
            print("Error getting data for image to save.")
            return false
        }
        do
        {
            try ImgData.write(to: ToURL)
        }
        catch
        {
            print("Error writing data: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Write the instance image as a .png to the specified URL.
    /// - Parameter ToURL: Where to write the instance image.
    /// - Parameter With: The color of the background.
    /// - Returns: True on success, false on failure.
    public func WritePNG(ToURL: URL, With BackgroundColor: NSColor) -> Bool
    {
        let BlackImage = NSImage(Color: NSColor.black, Size: self.size)
        BlackImage.lockFocus()
        let SelfRect = NSRect(origin: CGPoint.zero, size: self.size)
        self.draw(at: NSPoint.zero, from: SelfRect, operation: .overlay, fraction: 1.0)
        BlackImage.unlockFocus()
        return BlackImage.WritePNG(ToURL: ToURL)
    }
    
    /// Returns an image based on the instance with a new brightness level.
    /// - Parameter To: The new brightness level.
    /// - Returns: New image with the adjusted brightness. Same image is returned on error.
    public func SetImageBrightness(To NewLevel: Double) -> NSImage
    {
        let SourceData = self.tiffRepresentation!
        let Source = CIImage(data: SourceData)
        let ColorControl = CIFilter.colorControls()
        ColorControl.inputImage = Source
        ColorControl.brightness = Float(NewLevel)
        if let Changed = ColorControl.outputImage
        {
            let Rep = NSCIImageRep(ciImage: Changed)
            let Final = NSImage(size: Rep.size)
            Final.addRepresentation(Rep)
            return Final
        }
        else
        {
            print("Error changing brightness level to \(NewLevel) - unchanged image returned")
            return self
        }
    }
    
    /// Crop the instance image to the passed rectangle.
    /// - Parameter To: The rectangle in the image to return.
    /// - Returns: Cropped image from the instance image. Nil on error.
    public func Crop(To: CGRect) -> NSImage?
    {
        let SourceData = self.tiffRepresentation!
        let Source = CIImage(data: SourceData)
        if let Cropped = Source?.cropped(to: To)
        {
            let Rep = NSCIImageRep(ciImage: Cropped)
            let Final = NSImage(size: Rep.size)
            Final.addRepresentation(Rep)
            return Final
        }
        else
        {
            return nil
        }
    }
    
    /// Split the instance image into two horizontal pieces.
    /// - Parameter At: The X coordinate where the split will take place. If this value
    ///                 is invalid, nil will be returned.
    /// - Returns: Tuple of the left image and the right image. Nil on error.
    public func SplitHorizontally(At: Int) -> (Left: NSImage, Right: NSImage)?
    {
        if At < 0
        {
            return nil
        }
        if At > Int(self.size.width - 1)
        {
            return nil
        }
        let LeftWidth = CGFloat(At - 1)
        let RightWidth = self.size.width - LeftWidth
        let LeftRect = CGRect(x: 0, y: 0,
                              width: LeftWidth,
                              height: self.size.height)
        let RightRect = CGRect(x: CGFloat(At), y: 0,
                               width: RightWidth,
                               height: self.size.height)
        let LeftImage = self.Crop(To: LeftRect)!
        let RightImage = self.Crop(To: RightRect)!
        return (LeftImage, RightImage)
    }
    
    /// Split the instance image into two vertical pieces.
    /// - Parameter At: The Y coordinate where the split will take place. If this value
    ///                 is invalid, nil will be returned.
    /// - Returns: Tuple of the top image and the bottom image. Nil on error.
    public func SplitVertically(At: Int) -> (Top: NSImage, Bottom: NSImage)?
    {
        if At < 0
        {
            return nil
        }
        if At > Int(self.size.height - 1)
        {
            return nil
        }
        let TopHeight = CGFloat(At - 1)
        let BottomHeight = self.size.height - TopHeight
        let TopRect = CGRect(x: 0, y: 0,
                             width: self.size.width,
                             height: TopHeight)
        let BottomRect = CGRect(x: 0, y: CGFloat(At),
                                width: self.size.width,
                                height: BottomHeight)
        let TopImage = self.Crop(To: TopRect)!
        let BottomImage = self.Crop(To: BottomRect)!
        return (TopImage, BottomImage)
    }
}

