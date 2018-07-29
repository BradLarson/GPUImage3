#include <metal_stdlib>
using namespace metal;

#ifndef TexelSamplingTypes_h
#define TexelSamplingTypes_h

struct NearbyTexelVertexIO
{
    float4 position [[position]];
    
    float2 textureCoordinate [[user(textureCoordinate)]];
    float2 leftTextureCoordinate [[user(leftTextureCoordinate)]];
    float2 rightTextureCoordinate [[user(rightTextureCoordinate)]];

    float2 topTextureCoordinate [[user(topTextureCoordinate)]];
    float2 topLeftTextureCoordinate [[user(topLeftTextureCoordinate)]];
    float2 topRightTextureCoordinate [[user(topRightTextureCoordinate)]];

    float2 bottomTextureCoordinate [[user(bottomTextureCoordinate)]];
    float2 bottomLeftTextureCoordinate [[user(bottomLeftTextureCoordinate)]];
    float2 bottomRightTextureCoordinate [[user(bottomRightTextureCoordinate)]];
};

#endif /* TexelSamplingTypes_h */
