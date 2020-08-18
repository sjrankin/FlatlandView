//
//  CircularWarp.m
//  Flatland
//
//  Created by Stuart Rankin on 8/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// Create and return an ARGB bitmap context.
/// @param pixelsWide The width of the context.
/// @param pixelsHigh The height of the context.
/// @return On success an ARGB formatted bitmap context is returned. On error, NULL is returned.
CGContextRef CreateARGBBitmapContext (size_t pixelsWide, size_t pixelsHigh)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
        }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL)
        {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
        }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
        {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
        }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

/// Converts a rectangular image to an image projected on polar coordinates.
/// @discussion Intended to be used to convert equirectangular maps to polar projected maps.
/// @see https://stackoverflow.com/questions/19345509/image-circular-wrap-in-ios Image Circular Wrap in iOS
/// @param inImage The source image to convert.
/// @param bottomRadius The bottom radius (set to 0 for south-centered maps, 360 for north-centered maps).
/// @param topRadius The top radius (set to 360 for south-centered maps, 0 for north-centered maps)
/// @param startAngle Rotate the result. Units are radians.
/// @param clockWise If true, the image is projected in a clockwise fashion. If false, it is projected in a
///                  counterclockwise fasion.
/// @param interpolate If true, missing pixels are interpolated. If false, gaps are left in the resultant image.
/// @return Returns a CGImage converted to polar coordinates from the passed image.
CGImageRef CircularWarp(CGImageRef inImage,
                        CGFloat bottomRadius,
                        CGFloat topRadius,
                        CGFloat startAngle,
                        BOOL clockWise,
                        BOOL interpolate)
{
    if (topRadius < 0 || bottomRadius < 0)
        {
        return NULL;
        }
    
    // Create the bitmap context
    int w = (int)CGImageGetWidth(inImage);
    int h = (int)CGImageGetHeight(inImage);
    
    //result image side size (always a square image)
    int resultSide = 2 * MAX(topRadius, bottomRadius);
    CGContextRef cgctx1 = CreateARGBBitmapContext(w, h);
    CGContextRef cgctx2 = CreateARGBBitmapContext(resultSide, resultSide);
    
    if (cgctx1 == NULL || cgctx2 == NULL)
        {
        return NULL;
        }
    
    // Get image width, height. We'll use the entire image.
    CGRect rect = {{0, 0}, {w, h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx1, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    int *data1 = CGBitmapContextGetData(cgctx1);
    int *data2 = CGBitmapContextGetData(cgctx2);
    
    int resultImageSize = resultSide * resultSide;
    double temp;
    for(int *p = data2, pos = 0; pos < resultImageSize; p++, pos++)
    {
    *p = 0;
    int x = pos % resultSide - resultSide / 2;
    int y = -pos / resultSide + resultSide / 2;
    CGFloat phi = modf(((atan2(x, y) + startAngle) / 2.0 / M_PI + 0.5), &temp);
    if (!clockWise) phi = 1 - phi;
    phi*=w;
    CGFloat r = ((sqrtf(x * x + y * y)) - topRadius) * h / (bottomRadius - topRadius);
    if (phi >= 0 && phi < w && r >= 0 && r < h)
        {
        if (!interpolate || phi >= w - 1 || r >= h - 1)
            {
            //pick the closest pixel
            *p = data1[(int)r * w + (int)phi];
            }
        else
            {
            double dphi = modf(phi, &temp);
            double dr = modf(r, &temp);
            
            int8_t* c00 = (int8_t*)(data1 + (int)r * w + (int)phi);
            int8_t* c01 = (int8_t*)(data1 + (int)r * w + (int)phi + 1);
            int8_t* c10 = (int8_t*)(data1 + (int)r * w + w + (int)phi);
            int8_t* c11 = (int8_t*)(data1 + (int)r * w + w + (int)phi + 1);
            
            //interpolate components separately
            for(int component = 0; component < 4; component++)
                {
                double avg = ((*c00 & 0xFF) * (1-dphi) + (*c01 & 0xff) * dphi) *
                            (1 - dr) + ((*c10 & 0xff) * (1 - dphi) + (*c11 & 0xff) * dphi) * dr;
                *p += (((int)(avg)) << (component * 8));
                c00++; c10++; c01++; c11++;
                }
            }
        }
    }
    
    CGImageRef result = CGBitmapContextCreateImage(cgctx2);
    
    // When finished, release the context
    CGContextRelease(cgctx1);
    CGContextRelease(cgctx2);
    // Free image data memory for the context
    if (data1) free(data1);
    if (data2) free(data2);
    
    return result;
}

