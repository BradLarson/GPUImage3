#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float shadowTintIntensity;
    float highlightTintIntensity;
    float3 shadowTintColor;
    float3 highlightTintColor;
} HighlightShadowTintUniform;

fragment half4 highlightShadowTintFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant HighlightShadowTintUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half luminance = dot(color.rgb, luminanceWeighting);
    
    half4 shadowResult = mix(color, max(color, half4( mix(half3(uniform.shadowTintColor), color.rgb, luminance), color.a)), half(uniform.shadowTintIntensity));
    half4 highlightResult = mix(color, min(shadowResult, half4( mix(shadowResult.rgb, half3(uniform.highlightTintColor), luminance), color.a)), half(uniform.highlightTintIntensity));
    
    return half4(mix(shadowResult.rgb, highlightResult.rgb, luminance), color.a);
}
