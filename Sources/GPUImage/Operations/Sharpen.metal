#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct {
    float sharpness;
} SharpenUniform;

fragment half4 sharpenFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              constant SharpenUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half4 centerColorWithAlpha = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half3 centerColor = centerColorWithAlpha.rgb;
    half3 leftColor = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).rgb;
    half3 rightColor = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).rgb;
    half3 topColor = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).rgb;
    half3 bottomColor = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).rgb;
    
    half edgeMultiplier = half(uniform.sharpness);
    half centerMultiplier = 1.0 + 4.0 * edgeMultiplier;
    
    return half4((centerColor * centerMultiplier
                  - (leftColor * edgeMultiplier + rightColor * edgeMultiplier + topColor * edgeMultiplier + bottomColor * edgeMultiplier)),
                 centerColorWithAlpha.a);
    
}
