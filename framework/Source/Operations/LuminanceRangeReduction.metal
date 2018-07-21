#include <metal_stdlib>
#include "OperationShaderTypes.h"

using namespace metal;

typedef struct
{
    float rangeReduction;
} RangeReductionUniform;

fragment half4 luminanceRangeFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant RangeReductionUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half luminance = dot(color.rgb, luminanceWeighting);
    half luminanceRatio = ((0.5 - luminance) * uniform.rangeReduction);
    
    return half4(half3((color.rgb) + (luminanceRatio)), color.w);
}
