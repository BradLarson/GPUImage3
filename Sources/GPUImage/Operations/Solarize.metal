#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float threshold;
} SolarizeUniform;

fragment half4 solarizeFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant SolarizeUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half luminance = dot(color.rgb, luminanceWeighting);
    half thresholdResult = step(luminance, half(uniform.threshold));
    half3 finalColor = abs(thresholdResult - color.rgb);
    return half4(finalColor, color.a);
}
