#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct {
    float edgeStrength;
    float threshold;
} ThresholdSobelEdgeUniform;

fragment half4 thresholdSobelEdgeDetectionFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant ThresholdSobelEdgeUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    
    half bottomLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half bottomRightIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    half leftIntensity = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    half rightIntensity = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    half bottomIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half topIntensity = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    half topRightIntensity = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    half topLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;

    half2 gradientDirection;
    gradientDirection.x = -bottomLeftIntensity - 2.0h * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0h * rightIntensity + topRightIntensity;
    gradientDirection.y = -topLeftIntensity - 2.0h * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0h * bottomIntensity + bottomRightIntensity;
    
    half gradientMagnitude = length(gradientDirection);
    half2 normalizedDirection = normalize(gradientDirection);
    normalizedDirection = sign(normalizedDirection) * floor(abs(normalizedDirection) + 0.617316h); // Offset by 1-sin(pi/8) to set to 0 if near axis, 1 if away
    normalizedDirection = (normalizedDirection + 1.0h) * 0.5h; // Place -1.0 - 1.0 within 0 - 1.0
    
    return half4(gradientMagnitude, normalizedDirection.x, normalizedDirection.y, 1.0h);
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
 float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
 float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
 float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
 float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;
 float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
 float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
 float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
 float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
 
 vec2 gradientDirection;
 gradientDirection.x = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
 gradientDirection.y = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
 
 float gradientMagnitude = length(gradientDirection);
 vec2 normalizedDirection = normalize(gradientDirection);
 normalizedDirection = sign(normalizedDirection) * floor(abs(normalizedDirection) + 0.617316); // Offset by 1-sin(pi/8) to set to 0 if near axis, 1 if away
 normalizedDirection = (normalizedDirection + 1.0) * 0.5; // Place -1.0 - 1.0 within 0 - 1.0
 
 gl_FragColor = vec4(gradientMagnitude, normalizedDirection.x, normalizedDirection.y, 1.0);
 }
 */
