#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float colorLevels;
} PosterizeUniform;

fragment half4 posterizeFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant PosterizeUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half colorLevels = half(uniform.colorLevels);
    return floor((color * colorLevels) + half4(0.5)) / colorLevels;
}
