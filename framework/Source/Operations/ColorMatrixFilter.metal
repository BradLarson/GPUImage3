#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float intensity;
    packed_float4 m1;
    packed_float4 m2;
    packed_float4 m3;
    packed_float4 m4;
} ColorMatrixUniform;

fragment half4 colorMatrixFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant ColorMatrixUniform& uniform [[ buffer(1) ]])
{
    float4x4 colorMatrix = float4x4(float4(uniform.m1), float4(uniform.m2), float4(uniform.m3), float4(uniform.m4));
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half4 outputColor = color * half4x4(colorMatrix);
    
    return half4(uniform.intensity * outputColor) + ((1.0 - uniform.intensity) * color);
}
