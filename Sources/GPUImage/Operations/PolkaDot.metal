#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float dotScaling;
    float fractionalWidthOfPixel;
    float aspectRatio;
} PolkaDotUniform;

fragment half4 polkaDotFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant PolkaDotUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    float2 sampleDivisor = float2(uniform.fractionalWidthOfPixel, uniform.fractionalWidthOfPixel / uniform.aspectRatio);
    float2 samplePos = fragmentInput.textureCoordinate - mod(fragmentInput.textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float2 adjustedSamplePos = float2(samplePos.x, (samplePos.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
    float checkForPresenceWithinDot = step(distanceFromSamplePoint, (uniform.fractionalWidthOfPixel * 0.5) * uniform.dotScaling);
    half4 color = inputTexture.sample(quadSampler, samplePos);
    return half4(color.rgb * half(checkForPresenceWithinDot), color.a);
}


/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float fractionalWidthOfPixel;
 uniform float aspectRatio;
 uniform float dotScaling;
 
 void main()
 {
 vec2 sampleDivisor = vec2(fractionalWidthOfPixel, fractionalWidthOfPixel / aspectRatio);
 
 vec2 samplePos = textureCoordinate - mod(textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
 vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 vec2 adjustedSamplePos = vec2(samplePos.x, (samplePos.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 float distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
 float checkForPresenceWithinDot = step(distanceFromSamplePoint, (fractionalWidthOfPixel * 0.5) * dotScaling);
 
 vec4 inputColor = texture2D(inputImageTexture, samplePos);
 
 gl_FragColor = vec4(inputColor.rgb * checkForPresenceWithinDot, inputColor.a);
 }
 */
