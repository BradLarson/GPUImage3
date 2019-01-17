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

/*
 
 Constants:
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
 
 uniform float intensity;
 uniform float threshold;
 uniform float quantizationLevels;
 
 const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 
 // Beginning of Function
 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
 
 float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
 float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
 float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
 float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;
 float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
 float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
 float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
 float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
 float h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
 float v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
 
 float mag = length(vec2(h, v));
 
 vec3 posterizedImageColor = floor((textureColor.rgb * quantizationLevels) + 0.5) / quantizationLevels;
 
 float thresholdTest = 1.0 - step(threshold, mag);
 
 gl_FragColor = vec4(posterizedImageColor * thresholdTest, textureColor.a);
 */
