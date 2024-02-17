#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float vibrance;
} VibranceUniform;

fragment half4 vibranceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant VibranceUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half average = (color.r + color.g + color.b) / 3.0;
    half mx = max(color.r, max(color.g, color.b));
    half amt = (mx - average) * (-uniform.vibrance * 3.0);
    color.rgb = mix(color.rgb, half3(mx), amt);
    
    return half4(color);
}
