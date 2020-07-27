//
//  SolidColorKernel.metal
//  Flatland
//
//  Created by Stuart Rankin on 7/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct FillColor
{
    float4 Fill;
};

kernel void SolidColorKernel(texture2d<float, access::write> Target [[texture(0)]],
                             constant FillColor &Color [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    Target.write(Color.Fill, gid);
}
