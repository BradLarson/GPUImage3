#include <metal_stdlib>
#include "TexelSamplingTypes.h"

using namespace metal;

typedef struct
{
    float sharpen;
} SharpenUniform;

fragment half4 sharpenFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                               texture2d<half> inputTexture [[texture(0)]],
                               constant SharpenUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::pixel);

    half4 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half3 leftColor = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).rgb;
    half3 rightColor = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).rgb;
    half3 topColor = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).rgb;
    half3 bottomColor = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).rgb;
    
    half3 resultColor = centerColor.rgb * (1 + 4 * uniform.sharpen) - (leftColor * uniform.sharpen + rightColor * uniform.sharpen + topColor * uniform.sharpen + bottomColor * uniform.sharpen);
    
    return half4(resultColor, centerColor.a);
}

