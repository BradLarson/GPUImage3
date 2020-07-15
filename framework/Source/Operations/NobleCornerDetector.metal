//
//  NobleCornerDetector.metal
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
} NobleCornerUniform;

fragment half4 nobleCornerDetector(NearbyTexelVertexIO fragmentInput [[stage_in]],
                            texture2d<half> inputTexture [[texture(0)]],
                            constant NobleCornerUniform& uniform [[ buffer(1) ]]) {
    
    constexpr sampler quadSampler(coord::pixel);
    half3 derivativeElements = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).rgb;
    float derivativeSum = derivativeElements.x + derivativeElements.y;
    float zElement = (derivativeElements.z * 2.0) - 1.0;
    
    // R = Ix^2 * Iy^2 - Ixy * Ixy - k * (Ix^2 + Iy^2)^2
    float cornerness = (derivativeElements.x * derivativeElements.y - (zElement * zElement)) / (derivativeSum);
    
    return half4(half3(cornerness * uniform.sensitivity), 1.0);
    
}
