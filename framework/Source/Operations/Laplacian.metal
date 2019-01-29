#include <metal_stdlib>
#include "TexelSamplingTypes.h"

using namespace metal;

fragment half4 laplacianFilter(NearbyTexelVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half3 bottomColor = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).rgb;
    half3 bottomLeftColor = inputTexture.sample(quadSampler, fragmentInput.bottomLeftTextureCoordinate).rgb;
    half3 bottomRightColor = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).rgb;
    half4 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half3 leftColor = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).rgb;
    half3 rightColor = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).rgb;
    half3 topColor = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).rgb;
    half3 topRightColor = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).rgb;
    half3 topLeftColor = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).rgb;
    
    half3 resultColor = topLeftColor * 0.5h + topColor * 1.0h + topRightColor * 0.5h;
    resultColor += leftColor * 1.0h + centerColor.rgb * (-6.0h) + rightColor * 1.0h;
    resultColor += bottomLeftColor * 0.5h + bottomColor * 1.0h + bottomRightColor * 0.5h;
    
    // Normalize the results to allow for negative gradients in the 0.0-1.0 colorspace
    resultColor = resultColor + 0.5h;
    
    return half4(resultColor, centerColor.a);
}
