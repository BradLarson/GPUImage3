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

/*
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
 float centerIntensity = texture2D(inputImageTexture, textureCoordinate).r;
 float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
 float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
 float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
 float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;
 float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
 float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
 float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
 float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
 
 float byteTally = 1.0 / 255.0 * step(centerIntensity, topRightIntensity);
 byteTally += 2.0 / 255.0 * step(centerIntensity, topIntensity);
 byteTally += 4.0 / 255.0 * step(centerIntensity, topLeftIntensity);
 byteTally += 8.0 / 255.0 * step(centerIntensity, leftIntensity);
 byteTally += 16.0 / 255.0 * step(centerIntensity, bottomLeftIntensity);
 byteTally += 32.0 / 255.0 * step(centerIntensity, bottomIntensity);
 byteTally += 64.0 / 255.0 * step(centerIntensity, bottomRightIntensity);
 byteTally += 128.0 / 255.0 * step(centerIntensity, rightIntensity);
 
 // TODO: Replace the above with a dot product and two vec4s
 // TODO: Apply step to a matrix, rather than individually
 
 gl_FragColor = vec4(byteTally, byteTally, byteTally, 1.0);
 }

 */
