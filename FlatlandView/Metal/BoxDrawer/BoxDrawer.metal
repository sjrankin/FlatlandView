//
//  BoxDrawer.metal
//  Flatland
//
//  Created by Stuart Rankin on 8/1/20.
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

kernel void BoxDrawerKernel(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Target [[texture(1)]],
                            constant BoxData &Box [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Height = Target.get_height();
    if (gid.x >= Box.X1 && gid.x <= Box.X2 && gid.y >= Box.Y1 && gid.y <= Box.Y2)
        {
        Target.write(Box.FillColor, uint2(gid.x, Height - gid.y));
        }
    else
        {
        Target.write(Source.read(gid), uint2(gid.x, Height - gid.y));
        }
}
