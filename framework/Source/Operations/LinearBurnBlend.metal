#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 linearBurnBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                    texture2d<half> inputTexture [[texture(0)]],
                                    texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    return half4(clamp(textureColor.rgb + textureColor2.rgb - half3(1.0h), half3(0.0h), half3(1.0h)), textureColor.a);
}
