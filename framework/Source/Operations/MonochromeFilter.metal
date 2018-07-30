#include <metal_stdlib>
#include "OperationShaderTypes.h"

using namespace metal;

typedef struct
{
    float intensity;
    float3 filterColor;
} MonochromeUniform;

fragment half4 monochromeFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant MonochromeUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float luminance = dot(color.rgb, luminanceWeighting);
    half4 desat = half4(half3(luminance), 1.0);
    
    half3 filterColor = half3(uniform.filterColor);
    half4 outputColor = half4(
                            (desat.r < 0.5 ? (2.0 * desat.r * filterColor.r) : (1.0 - 2.0 * (1.0 - desat.r) * (1.0 - filterColor.r))),
                            (desat.g < 0.5 ? (2.0 * desat.g * filterColor.g) : (1.0 - 2.0 * (1.0 - desat.g) * (1.0 - filterColor.g))),
                            (desat.b < 0.5 ? (2.0 * desat.b * filterColor.b) : (1.0 - 2.0 * (1.0 - desat.b) * (1.0 - filterColor.b))),
                            1.0
                            );

    return half4(mix(color.rgb, outputColor.rgb, half(uniform.intensity)), color.a);
}
