#include <metal_stdlib>
using namespace metal;

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

vertex SingleInputVertexIO oneInputVertex(device packed_float2 *position [[buffer(0)]],
                                          device packed_float2 *texturecoord [[buffer(1)]],
                                          uint vid [[vertex_id]])
{
    SingleInputVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vid];
    
    return outputVertices;
}

fragment half4 passthroughFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
//    half4 color = half4(0.0, 0.0, 1.0, 1.0);
    
    return color;
}
