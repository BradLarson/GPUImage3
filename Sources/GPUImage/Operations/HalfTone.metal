#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float fractionalWidthOfPixel;
    float aspectRatio;
} HalfToneUniform;

fragment half4 halftoneFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant HalfToneUniform& uniform [[buffer(1)]])
{
    float2 sampleDivisor = float2(uniform.fractionalWidthOfPixel, uniform.fractionalWidthOfPixel / uniform.aspectRatio);
    
    float2 samplePos = fragmentInput.textureCoordinate - mod(fragmentInput.textureCoordinate, sampleDivisor) + float2(0.5) * sampleDivisor;
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float2 adjustedSamplePos = float2(samplePos.x, (samplePos.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
    
    constexpr sampler quadSampler;
    float3 sampledColor = float3(inputTexture.sample(quadSampler, samplePos ).rgb);
    float dotScaling = 1.0 - dot(sampledColor, float3(luminanceWeighting));
    
    float checkForPresenceWithinDot = 1.0 - step(distanceFromSamplePoint, (uniform.fractionalWidthOfPixel * 0.5) * dotScaling);
    return half4(half3(checkForPresenceWithinDot), 1.0h);
}


/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float fractionalWidthOfPixel;
 uniform float aspectRatio;
 
 const vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
 vec2 sampleDivisor = vec2(fractionalWidthOfPixel, fractionalWidthOfPixel / aspectRatio);
 
 vec2 samplePos = textureCoordinate - mod(textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
 vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 vec2 adjustedSamplePos = vec2(samplePos.x, (samplePos.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 float distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
 
 vec3 sampledColor = texture2D(inputImageTexture, samplePos ).rgb;
 float dotScaling = 1.0 - dot(sampledColor, W);
 
 float checkForPresenceWithinDot = 1.0 - step(distanceFromSamplePoint, (fractionalWidthOfPixel * 0.5) * dotScaling);
 
 gl_FragColor = vec4(vec3(checkForPresenceWithinDot), 1.0);
 }
 */

