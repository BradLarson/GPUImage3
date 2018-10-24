#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float scale;
    float2 center;
} BulgeDistortionUniform;

fragment half4 bulgeDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant BulgeDistortionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    half2 textureCoordinateToUse = half2(color.x, ((color.y - uniform.center.y) * aspectRatio) + uniform.center.y); // TODO: Aspect ratio!!! Will break!
    half dist = distance(center, textureCoordinateToUse);
    textureCoordinateToUse = fragmentInput.textureCoordinate;

    if (dist < uniform.radius)
    {
        textureCoordinateToUse -= uniform.center;
        half percent = 1.0h - ((uniform.radius - dist) / uniform.radius) * uniform.scale;
        percent = percent * percent;

        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += uniform.center;
    }

    return inputTexture.sample(quadSampler, textureCoordinateToUse);
}
