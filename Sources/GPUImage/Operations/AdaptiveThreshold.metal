#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 adaptiveThresholdFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture1 [[texture(0)]],
                                       texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half blurredInput = inputTexture1.sample(quadSampler, fragmentInput.textureCoordinate).r;
    half localLuminance = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate).r;
    half thresholdResult = step(blurredInput - 0.05h, localLuminance);
    
    return half4(half3(thresholdResult), 1.0);
}
