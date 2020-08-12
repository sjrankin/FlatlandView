//
//  SolidColorKernel.metal
//  Flatland
//
//  Created by Stuart Rankin on 7/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ParameterBlock
{
    bool DrawBorder;
    uint BorderThickness;
    float4 BorderColor;
    float4 Fill;
};

kernel void SolidColorKernel(texture2d<float, access::write> Target [[texture(0)]],
                             constant ParameterBlock &Parameters [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    if ((Parameters.DrawBorder) && (Parameters.BorderThickness > 0))
        {
        if (gid.x < Parameters.BorderThickness)
            {
            Target.write(Parameters.BorderColor, gid);
            return;
            }
        if (gid.x > Target.get_width() - Parameters.BorderThickness - 1)
            {
            Target.write(Parameters.BorderColor, gid);
            return;
            }
        if (gid.y < Parameters.BorderThickness)
            {
            Target.write(Parameters.BorderColor, gid);
            return;
            }
        if (gid.y > Target.get_height() - Parameters.BorderThickness - 1)
            {
            Target.write(Parameters.BorderColor, gid);
            return;
            }
        }
    Target.write(Parameters.Fill, gid);
}
