//
//  ImageBlender.metal
//  Flatland
//
//  Created by Stuart Rankin on 8/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct ImageBlendParameters
{
    uint XOffset;
    uint YOffset;
};

kernel void ImageBlender(texture2d<float, access::read_write> Sprite [[texture(0)]],
                             texture2d<float, access::read_write> Background [[texture(1)]],
                             constant ImageBlendParameters &Parameters [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    uint2 BGPosition = uint2(gid.x + Parameters.XOffset, gid.y + Parameters.YOffset);
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
