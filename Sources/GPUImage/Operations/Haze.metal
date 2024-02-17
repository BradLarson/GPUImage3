#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float hazeDistance;
    float slope;
} HazeUniform;

fragment half4 hazeFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(0)]],
                                     constant HazeUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 white = half4(1.0);
    
    half d = fragmentInput.textureCoordinate.y * uniform.slope + uniform.hazeDistance;
    
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    color = (color - d * white) / (1.0 - d);
    
    return color;
}
