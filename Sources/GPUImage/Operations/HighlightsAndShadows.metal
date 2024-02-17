#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float shadows;
    float highlights;
} HighlightShadowUniform;

fragment half4 highlightShadowFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant HighlightShadowUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half luminance = dot(color.rgb, luminanceWeighting);
    half shadow = clamp((pow(luminance, 1.0h/(half(uniform.shadows)+1.0h)) + (-0.76)*pow(luminance, 2.0h/(half(uniform.shadows)+1.0h))) - luminance, 0.0, 1.0);
    half highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-half(uniform.highlights))) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-half(uniform.highlights))))) - luminance, -1.0, 0.0);
    half3 result = half3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((color.rgb - half3(0.0, 0.0, 0.0))/(luminance - 0.0));
    
    return half4(result.rgb, color.a);
}
