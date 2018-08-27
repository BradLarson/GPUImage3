#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct {
    float threshold;
    float quantizationLevels;
} ToonUniform;

fragment half4 toonFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                            texture2d<half> inputTexture [[texture(0)]],
                            constant ToonUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half bottomIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half bottomLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomLeftTextureCoordinate).r;
    half bottomRightIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    half4 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half leftIntensity = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    half rightIntensity = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    half topIntensity = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    half topRightIntensity = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    half topLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;
    
    half h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
    half v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
    
    float mag = length(float2(h, v));
    
    half3 posterizedImageColor = floor((centerColor.rgb * uniform.quantizationLevels) + 0.5) / uniform.quantizationLevels;
    
    float thresholdTest = 1.0 - step(uniform.threshold, mag);
    
    return half4(half3(posterizedImageColor * thresholdTest), centerColor.a);
}
