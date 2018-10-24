#include <metal_stdlib>
#include "OperationShaderTypes.h"
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
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    half2 sampleDivisor = half2(uniform.fractionalWidthOfPixel, uniform.fractionalWidthOfPixel / uniform.aspectRatio); // TODO: Figure out aspect ratio

    half2 samplePos = fragmentInput.textureCoordinate - mod(fragmentInput.textureCoordinate, sampleDivisor) + 0.5h * sampleDivisor;
    half2 textureCoordinateToUse = half2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5h - 0.5h * uniform.aspectRatio)); // TODO: Figure out aspect ratio
    half2 adjustedSamplePos = half2(samplePos.x, (samplePos.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio)); // TODO: Figure out aspect ratio
    half distanceFromSamplePoint = distance(adjustedSamplePos, textureCoordinateToUse);
    half checkForPresenceWithinDot = step(distanceFromSamplePoint, (half(uniform.fractionalWidthOfPixel) * 0.5) * half(uniform.dotScaling));

    return half4(color.rgb * checkForPresenceWithinDot, color.a);
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
