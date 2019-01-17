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


/*
 uniform sampler2D inputImageTexture;
 
 uniform mat3 convolutionMatrix;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 void main()
 {
 vec3 bottomColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
 vec3 bottomLeftColor = texture2D(inputImageTexture, bottomLeftTextureCoordinate).rgb;
 vec3 bottomRightColor = texture2D(inputImageTexture, bottomRightTextureCoordinate).rgb;
 vec4 centerColor = texture2D(inputImageTexture, textureCoordinate);
 vec3 leftColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
 vec3 rightColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
 vec3 topColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
 vec3 topRightColor = texture2D(inputImageTexture, topRightTextureCoordinate).rgb;
 vec3 topLeftColor = texture2D(inputImageTexture, topLeftTextureCoordinate).rgb;
 
 vec3 resultColor = topLeftColor * 0.5 + topColor * 1.0 + topRightColor * 0.5;
 resultColor += leftColor * 1.0 + centerColor.rgb * (-6.0) + rightColor * 1.0;
 resultColor += bottomLeftColor * 0.5 + bottomColor * 1.0 + bottomRightColor * 0.5;
 
 // Normalize the results to allow for negative gradients in the 0.0-1.0 colorspace
 resultColor = resultColor + 0.5;
 
 gl_FragColor = vec4(resultColor, centerColor.a);
 }
 */
