#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float radius;
    float angle;
    float2 center;
} SwirlDistortionUniform;

fragment half4 swirlDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture [[texture(0)]],
                                       constant SwirlDistortionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    float2 textureCoordinateToUse = fragmentInput.textureCoordinate;
    float dist = distance(uniform.center, textureCoordinateToUse);
    if (dist < uniform.radius)
    {
        textureCoordinateToUse -= uniform.center;
        float percent = (uniform.radius - dist) / uniform.radius;
        float theta = percent * percent * uniform.angle * 8.0;
        float s = sin(theta);
        float c = cos(theta);
        textureCoordinateToUse = float2(dot(textureCoordinateToUse, float2(c, -s)), dot(textureCoordinateToUse, float2(s, c)));
        textureCoordinateToUse += uniform.center;
    }
    
    return inputTexture.sample(quadSampler, textureCoordinateToUse);
}
