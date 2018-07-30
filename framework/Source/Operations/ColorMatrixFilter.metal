#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float intensity;
    float4x4 colorMatrix;
} ColorMatrixUniform;

fragment half4 colorMatrixFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant ColorMatrixUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half4 outputColor = color * half4x4(uniform.colorMatrix);
    
    return half4(uniform.intensity * outputColor) + ((1.0 - uniform.intensity) * color);
}
