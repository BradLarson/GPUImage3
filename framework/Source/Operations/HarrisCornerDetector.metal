//
//  HarrisCornerDetector.metal
//  GPUImage
//
//  Created by PavanK on 7/15/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct
{
    float sensitivity;
} HarrisCornerUniform;

fragment half4 harrisCornerDetector(NearbyTexelVertexIO fragmentInput [[stage_in]],
                            texture2d<half> inputTexture [[texture(0)]],
                            constant HarrisCornerUniform& uniform [[ buffer(1) ]]) {
    
    const float harrisConstant = 0.04;
    constexpr sampler quadSampler(coord::pixel);
    half3 derivativeElements = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).rgb;
    float derivativeSum = derivativeElements.x + derivativeElements.y;
    float zElement = (derivativeElements.z * 2.0) - 1.0;
    
    // R = Ix^2 * Iy^2 - Ixy * Ixy - k * (Ix^2 + Iy^2)^2
    float cornerness = derivativeElements.x * derivativeElements.y - (zElement * zElement) - harrisConstant * derivativeSum * derivativeSum;
    
    return half4(half3(cornerness * uniform.sensitivity), 1.0);
    
}
