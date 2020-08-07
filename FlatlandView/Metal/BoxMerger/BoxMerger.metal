//
//  BoxMerger.metal
//  Flatland
//
//  Created by Stuart Rankin on 8/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct BoxData
{
    float4 FillColor;
    uint X1;
    uint Y1;
    uint X2;
    uint Y2;
};

struct ImageMergeParameters
{
    uint XOffset;
    uint YOffset;
};

kernel void ImageMergeKernel2(texture2d<float, access::read> Sprite [[texture(0)]],
                             texture2d<float, access::read_write> Background [[texture(1)]],
                             constant ImageMergeParameters &Parameters [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    uint2 BGPosition = uint2(gid.x + Parameters.XOffset, gid.y + Parameters.YOffset);
    Background.write(float4(1.0,0.5,0.25,1.0), gid);
    return;
    float4 BGPixel = Background.read(BGPosition);
    float4 SpPixel = Sprite.read(gid);
    float SpriteAlpha = SpPixel.a;
    if (SpriteAlpha == 0.0)
        {
        return;
        }
    if (SpriteAlpha == 1.0)
        {
        Background.write(SpPixel, BGPosition);
        }
    else
        {
        float FinalRed = (SpPixel.r * SpriteAlpha) + (BGPixel.r * (1.0 - SpriteAlpha));
        float FinalGreen = (SpPixel.g * SpriteAlpha) + (BGPixel.g * (1.0 - SpriteAlpha));
        float FinalBlue = (SpPixel.b * SpriteAlpha) + (BGPixel.b * (1.0 - SpriteAlpha));
        Background.write(float4(FinalRed, FinalGreen, FinalBlue, 1.0), BGPosition);
        }
}

kernel void BoxMergerKernelBad(texture2d<float, access::read_write> Target [[texture(0)]],
                            constant BoxData &Box [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Height = Target.get_height();

    if (Box.Y1 > Box.Y2)
        {
        Target.write(float4(1.0,0.0,0.0,1.0), gid);
        return;
        }

    if (gid.x < Box.X1)
        {
        Target.write(float4(0.5,0.45,0.05, 1.0), gid);
        return;
        }
    
    if (gid.x >= Box.X1 && gid.x <= Box.X2 && gid.y >= Box.Y1 && gid.y <= Box.Y2)
        {
        //We are inside of a target region so depending on the alpha level of the color,
        //do different things.
        if (Box.FillColor.a == 1.0)
            {
            //If alpha is 1.0, just draw the color.
            Target.write(Box.FillColor, uint2(gid.x, Height - gid.y));
            }
        else
            {
            if (Box.FillColor.a == 0.0)
                {
                //If alpha is 0.0, nothing to do.
                return;
                }
            else
                {
                //If alpha is between 0.0 and 1.0, blend the target and source pixels.
                float4 ReplacementColor = Target.read(gid);
                float4 TargetColor = Target.read(uint2(gid.x, Height - gid.y));
                float RegionAlpha = Box.FillColor.a;
                float FinalRed = (Box.FillColor.r * RegionAlpha) + (TargetColor.r * (1.0 - RegionAlpha));
                float FinalGreen = (Box.FillColor.g * RegionAlpha) + (TargetColor.g * (1.0 - RegionAlpha));
                float FinalBlue = (Box.FillColor.b * RegionAlpha) + (TargetColor.b * (1.0 - RegionAlpha));
                //Target.write(float4(FinalRed, FinalGreen, FinalBlue, 1.0), gid);
                //Target.write(ReplacementColor, uint2(gid.x, Height - gid.y));
                Target.write(float4(1.0,1.0,1.0,1.0), uint2(gid.x, Height - gid.y));
                }
            }
        }
    else
        {
        //We are not in a target region - nothing to do.
        //return;
//        Target.write(Source.read(gid), uint2(gid.x, Height - gid.y));
        Target.write(float4(0.7,0.3,0.7,1.0), uint2(gid.x, Height - gid.y));
        }
}
