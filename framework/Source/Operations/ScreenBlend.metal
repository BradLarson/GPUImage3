#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 screenBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                      texture2d<half> inputTexture [[texture(0)]],
                                      texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    half4 whiteColor = half4(1.0);
    
    return whiteColor - ((whiteColor - textureColor2) * (whiteColor - textureColor));
}
