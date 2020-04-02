//
//  CustomBrightnessAdjustment.metal
//  SimpleImageFilter
//
//  Created by yang on 2020/4/2.
//  Copyright © 2020 Sunset Lake Software LLC. All rights reserved.
//

#include <metal_stdlib>
#include <GPUImage/OperationShaderTypes.h>

using namespace metal;

typedef struct
{
    float brightness;
} BrightnessUniform;

fragment half4 brightnessFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant BrightnessUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    return half4(color.rgb + uniform.brightness, color.a);
}
