#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 luminanceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float luminance = dot(color.rgb, luminanceWeighting);
    
    return half4(half3(luminance), color.a);
}
