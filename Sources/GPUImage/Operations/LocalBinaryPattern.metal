#include <metal_stdlib>
#include "TexelSamplingTypes.h"

using namespace metal;

fragment half4 localBinaryPatternFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half centerIntensity = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r;
    half bottomLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half bottomRightIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    half leftIntensity = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    half rightIntensity = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    half bottomIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half topIntensity = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    half topRightIntensity = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    half topLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;

    half byteTally = 1.0h / 255.0h * step(centerIntensity, topRightIntensity);
    byteTally += 2.0h / 255.0h * step(centerIntensity, topIntensity);
    byteTally += 4.0h / 255.0h * step(centerIntensity, topLeftIntensity);
    byteTally += 8.0h / 255.0h * step(centerIntensity, leftIntensity);
    byteTally += 16.0h / 255.0h * step(centerIntensity, bottomLeftIntensity);
    byteTally += 32.0h / 255.0h * step(centerIntensity, bottomIntensity);
    byteTally += 64.0h / 255.0h * step(centerIntensity, bottomRightIntensity);
    byteTally += 128.0h / 255.0h * step(centerIntensity, rightIntensity);
    
    // TODO: Replace the above with a dot product and two vec4s
    // TODO: Apply step to a matrix, rather than individually
    
    return half4(byteTally, byteTally, byteTally, 1.0h);
}
