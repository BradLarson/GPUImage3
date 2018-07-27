// Hue blend mode based upon pseudo code from the PDF specification.

#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

fragment half4 hueBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                      texture2d<half> inputTexture [[texture(0)]],
                                      texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    return half4(base.rgb * (1.0h - overlay.a) + setlum(setsat(overlay.rgb, sat(base.rgb)), lum(base.rgb)) * overlay.a, base.a);
}

