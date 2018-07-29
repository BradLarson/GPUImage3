#include <metal_stdlib>
#include "TexelSamplingTypes.h"

using namespace metal;

typedef struct
{
    float3x3 convolutionKernel;
} Convolution3x3Uniform;

fragment half4 convolution3x3(NearbyTexelVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              constant Convolution3x3Uniform& uniform [[ buffer(1) ]])
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
    
    half3 resultColor = topLeftColor * uniform.convolutionKernel[0][0] + topColor * uniform.convolutionKernel[0][1] + topRightColor * uniform.convolutionKernel[0][2];
    resultColor += leftColor * uniform.convolutionKernel[1][0] + centerColor.rgb * uniform.convolutionKernel[1][1] + rightColor * uniform.convolutionKernel[1][2];
    resultColor += bottomLeftColor * uniform.convolutionKernel[2][0] + bottomColor * uniform.convolutionKernel[2][1] + bottomRightColor * uniform.convolutionKernel[2][2];
    
    return half4(resultColor, centerColor.a);
}
