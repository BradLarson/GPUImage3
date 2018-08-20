#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float intensity;
} IntensityUniform;

fragment half4 lookupFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                texture2d<half> inputTexture2 [[texture(1)]],
                                constant IntensityUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half blueColor = base.b * 63.0h;
    
    half2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0h);
    quad1.x = floor(blueColor) - (quad1.y * 8.0h);
    
    half2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0h);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0h);
    
    float2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);
    
    float2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * base.g);
    
    constexpr sampler quadSampler3;
    half4 newColor1 = inputTexture2.sample(quadSampler3, texPos1);
    constexpr sampler quadSampler4;
    half4 newColor2 = inputTexture2.sample(quadSampler4, texPos2);
    
    half4 newColor = mix(newColor1, newColor2, fract(blueColor));
    return half4(mix(base, half4(newColor.rgb, base.w), half(uniform.intensity)));
}
