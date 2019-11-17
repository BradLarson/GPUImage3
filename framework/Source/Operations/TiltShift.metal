#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
//    float blurRadiusInPixels;
    float topFocusLevel;
    float bottomFocusLevel;
    float focusFallOffRate;
} TiltShiftUniform;

fragment half4 tiltShiftFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture1 [[texture(0)]],
                                       texture2d<half> inputTexture2 [[texture(1)]],
                                       constant TiltShiftUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 sharpImageColor = inputTexture1.sample(quadSampler, fragmentInput.textureCoordinate);
    half4 blurredImageColor = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float blurIntensity = 1.0h - smoothstep(uniform.topFocusLevel - uniform.focusFallOffRate, uniform.topFocusLevel, fragmentInput.textureCoordinate2.y);
    blurIntensity += smoothstep(uniform.bottomFocusLevel, uniform.bottomFocusLevel + uniform.focusFallOffRate, fragmentInput.textureCoordinate2.y);
    
    return half4(mix(sharpImageColor, blurredImageColor, half(blurIntensity)));
}
