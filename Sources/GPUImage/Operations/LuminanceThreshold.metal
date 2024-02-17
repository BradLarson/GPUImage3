#include <metal_stdlib>
#include "OperationShaderTypes.h"

using namespace metal;

typedef struct
{
    float threshold;
} ThresholdUniform;

fragment half4 thresholdFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant ThresholdUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half luminance = dot(color.rgb, luminanceWeighting);
    half thresholdResult = step(half(uniform.threshold), luminance);
    
    return half4(half3(thresholdResult), color.w);
}
