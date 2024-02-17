//
//  File.metal
//  GPUImage
//
//  Created by Mehedi Hasan on 18/5/23.
//  Copyright © 2023 Red Queen Coder, LLC. All rights reserved.
//


#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;


typedef struct {
    float time;
} TimeUniform;


fragment half4 waterEffectFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant TimeUniform& uniform [[buffer(1)]])
{
    
  //  constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
    
//    constexpr sampler quadSampler(coord::normalized,
//                                     address::repeat,
//                                     min_filter::linear,
//                                     mag_filter::linear,
//                                     mip_filter::linear );
//
    constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
    
    float2 pos = fragmentInput.textureCoordinate.xy;// / float2(inputTexture.get_width(), inputTexture.get_height());

    float xAmount = uniform.time * 0.01;
    float yAmount = uniform.time * 0.01;

    float xWavelength = uniform.time * 0.1;
    float yWavelength = uniform.time * 0.1;

    float y = pos.y + sin(pos.y / yWavelength) * yAmount;
    float x = pos.x + sin(pos.x / xWavelength) * xAmount;

    float2 upPos = float2(x, y);
    
    half4 color = inputTexture.sample(quadSampler, upPos);


    return color;
}
