//
//  ImageShifter.metal
//  Flatland
//
//  Created by Stuart Rankin on 10/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ParameterBlock
{
    uint XOffset;
    uint YOffset;
};

kernel void ImageShift(texture2d<float, access::read> Source [[texture(0)]],
                       texture2d<float, access::write> Target [[texture(1)]],
                       constant ParameterBlock &Parameters [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint Height = Source.get_height();
    float4 Pixel = Source.read(gid);
    uint NewX = gid.x + Parameters.XOffset;
    if (NewX < 0)
        {
        uint HDelta = gid.x - Parameters.XOffset;
        NewX = (Width - 1) + HDelta;
        }
    if (NewX > Width - 1)
        {
        uint HDelta = (Width - 1) - Parameters.XOffset;
        NewX = HDelta;
        }
    uint NewY = gid.y + Parameters.YOffset;
    if (NewY < 0)
        {
        uint VDelta = gid.y - Parameters.YOffset;
        NewY = (Height - 1) + VDelta;
        }
    if (NewY > Height - 1)
        {
        uint VDelta = (Height - 1) - Parameters.YOffset;
        NewY = VDelta;
        }
    uint2 TargetLocation = uint2(NewX, NewY);
    Target.write(Pixel, TargetLocation);
}
