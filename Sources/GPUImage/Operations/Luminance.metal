/*
 For a complete explanation behind the math of this shader, read this blog post:
 http://redqueengraphics.com/2018/07/26/metal-shaders-luminance/
 */

#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 luminanceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half luminance = dot(color.rgb, luminanceWeighting);
    
    return half4(half3(luminance), color.a);
}
