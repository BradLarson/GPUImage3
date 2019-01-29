#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct
{
    float threshold;
    float quantizationLevels;
} ToonUniform;

fragment half4 toonFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(0)]],
                                     constant ToonUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler(coord::pixel);

    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    half bottomLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half bottomRightIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    half leftIntensity = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    half rightIntensity = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    half bottomIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half topIntensity = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    half topRightIntensity = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    half topLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;
    
    half h = -topLeftIntensity - 2.0h * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0h * bottomIntensity + bottomRightIntensity;
    half v = -bottomLeftIntensity - 2.0h * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0h * rightIntensity + topRightIntensity;
    
    half mag = length(half2(h, v));
    
    half3 posterizedImageColor = floor((textureColor.rgb * uniform.quantizationLevels) + 0.5h) / uniform.quantizationLevels;
    
    half thresholdTest = 1.0h - step(half(uniform.threshold), mag);
    
    return half4(posterizedImageColor * thresholdTest, textureColor.a);
}
