#include <metal_stdlib>
using namespace metal;


typedef struct
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
}  ColourFASTVertexIO;

vertex ColourFASTVertexIO colourFASTDecriptorVertex(const device packed_float2 *position [[buffer(0)]],
                                               const device packed_float2 *textureCoordinate [[buffer(1)]],
                                               const device packed_float2 *textureCoordinate2 [[buffer(2)]],
                                               uint vid [[vertex_id]])
{
    ColourFASTVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);

    float2 singleWidthStep = float2(1.0, 0.0);
    float2 singleHeightStep = float2(0.0, 1.0);
    float2 tripleWidthStep = float2(3.0, 0.0);
    float2 tripleHeightStep = float2(0.0, 3.0);
    
    outputVertices.textureCoordinate = textureCoordinate[vid];
    outputVertices.leftTextureCoordinate = textureCoordinate[vid] + tripleWidthStep + singleHeightStep;
    outputVertices.rightTextureCoordinate = textureCoordinate[vid] + singleWidthStep + tripleHeightStep;
    
    outputVertices.topTextureCoordinate = textureCoordinate[vid] - singleWidthStep + tripleHeightStep;
    outputVertices.topLeftTextureCoordinate = textureCoordinate[vid] - tripleWidthStep + singleHeightStep;
    outputVertices.topRightTextureCoordinate = textureCoordinate[vid] - tripleWidthStep - singleHeightStep;
    
    outputVertices.bottomTextureCoordinate = textureCoordinate[vid] - singleWidthStep - tripleHeightStep;
    outputVertices.bottomLeftTextureCoordinate = textureCoordinate[vid] + singleWidthStep - tripleHeightStep;
    outputVertices.bottomRightTextureCoordinate = textureCoordinate[vid] + tripleWidthStep - singleHeightStep;

    return outputVertices;
}


fragment half4 colourFASTDecriptorFragment(ColourFASTVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    
    half3 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).rgb;
    half3 leftColor = inputTexture2.sample(quadSampler, fragmentInput.leftTextureCoordinate).rgb;
    half3 rightColor = inputTexture2.sample(quadSampler, fragmentInput.rightTextureCoordinate).rgb;
    
    half3 topColor = inputTexture2.sample(quadSampler, fragmentInput.topTextureCoordinate).rgb;
    half3 topLeftColor = inputTexture2.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).rgb;
    half3 topRightColor = inputTexture2.sample(quadSampler, fragmentInput.topRightTextureCoordinate).rgb;
    
    half3 bottomColor = inputTexture2.sample(quadSampler, fragmentInput.bottomTextureCoordinate).rgb;
    half3 bottomLeftColor = inputTexture2.sample(quadSampler, fragmentInput.bottomLeftTextureCoordinate).rgb;
    half3 bottomRightColor = inputTexture2.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).rgb;
    
    half3 colorComparison = ((leftColor + rightColor + topColor + topLeftColor + topRightColor + bottomColor + bottomLeftColor + bottomRightColor) * 0.125) - centerColor;
    
    // Direction calculation drawn from Appendix B of Seth Hall's Ph.D. thesis
    half3 dirX = (leftColor * 0.94868) + (rightColor * 0.316227)
        - (topColor * 0.316227) - (topLeftColor * 0.94868)
        - (topRightColor * 0.94868) - (bottomColor * 0.316227)
        + (bottomLeftColor * 0.316227) + (bottomRightColor * 0.94868);
    
    half3 dirY = (leftColor * 0.316227) + (rightColor * 0.94868)
        + (topColor * 0.94868) + (topLeftColor * 0.316227)
        - (topRightColor * 0.316227) - (bottomColor * 0.94868)
        - (bottomLeftColor * 0.94868) - (bottomRightColor * 0.316227);
    
    half3 absoluteDifference = abs(colorComparison);
    half componentLength = length(colorComparison);
    half avgX = dot(absoluteDifference, dirX) / componentLength;
    half avgY = dot(absoluteDifference, dirY) / componentLength;
    half angle = atan2(avgY, avgX);
    
    half3 normalizedColorComparison = (colorComparison + 1.0) * 0.5;
    
    return half4(normalizedColorComparison, (angle + M_PI_F) / M_2_PI_F);
}
