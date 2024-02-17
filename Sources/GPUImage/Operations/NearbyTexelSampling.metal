#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

vertex NearbyTexelVertexIO nearbyTexelSampling(const device packed_float2 *position [[buffer(0)]],
                                               const device packed_float2 *textureCoordinate [[buffer(1)]],
                                               uint vid [[vertex_id]])
{
    NearbyTexelVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);

    float2 widthStep = float2(1.0, 0.0);
    float2 heightStep = float2(0.0, 1.0);
    float2 widthHeightStep = float2(1.0, 1.0);
    float2 widthNegativeHeightStep = float2(1.0, -1.0);

    outputVertices.textureCoordinate = textureCoordinate[vid];
    outputVertices.leftTextureCoordinate = textureCoordinate[vid] - widthStep;
    outputVertices.rightTextureCoordinate = textureCoordinate[vid] + widthStep;
    
    outputVertices.topTextureCoordinate = textureCoordinate[vid] - heightStep;
    outputVertices.topLeftTextureCoordinate = textureCoordinate[vid] - widthHeightStep;
    outputVertices.topRightTextureCoordinate = textureCoordinate[vid] + widthNegativeHeightStep;
    
    outputVertices.bottomTextureCoordinate = textureCoordinate[vid] + heightStep;
    outputVertices.bottomLeftTextureCoordinate = textureCoordinate[vid] - widthNegativeHeightStep;
    outputVertices.bottomRightTextureCoordinate = textureCoordinate[vid] + widthHeightStep;

    return outputVertices;
}
