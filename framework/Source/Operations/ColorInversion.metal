/*
 For a complete explanation behind the math of this shader, read this blog post:
 http://redqueengraphics.com/2018/07/15/metal-shaders-color-inversion/
*/

#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 colorInversionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4((1.0 - color.rgb), color.a);
}
