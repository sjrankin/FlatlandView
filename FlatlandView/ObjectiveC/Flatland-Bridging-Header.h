//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

CGImageRef CircularWarp(CGImageRef inImage,
                        CGFloat bottomRadius,
                        CGFloat topRadius,
                        CGFloat startAngle,
                        BOOL clockWise,
                        BOOL interpolate);
