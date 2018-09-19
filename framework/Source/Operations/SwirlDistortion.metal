#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float angle;
    float2 center;
} SwirlDistortionUniform;

fragment half4 swirlFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture [[texture(0)]],
                                       constant SwirlDistortionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    float2 textureCoordinateToUse = fragmentInput.textureCoordinate;
    half dist = distance(uniform.center, fragmentInput.textureCoordinate);
    
    if (dist < uniform.radius)
    {
        textureCoordinateToUse -= uniform.center;
        half percent = (uniform.radius - dist) / uniform.radius;
        half theta = percent * percent * uniform.angle * 8.0h;
        half s = sin(theta);
        half c = cos(theta);
        textureCoordinateToUse = dot(textureCoordinateToUse, (c, -s)), dot(textureCoordinateToUse, (s, c));
        textureCoordinateToUse += uniform.center;
    }
    
    return inputTexture.sample(quadSampler, textureCoordinateToUse);
}
