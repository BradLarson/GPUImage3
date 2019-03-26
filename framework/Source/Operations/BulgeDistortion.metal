#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float scale;
    float2 center;
    float aspectRatio;
} BulgeDistortionUniform;

fragment half4 bulgeDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant BulgeDistortionUniform& uniform [[buffer(1)]])
{
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, ((fragmentInput.textureCoordinate.y - uniform.center.y) * uniform.aspectRatio) + uniform.center.y);
    float dist = distance(uniform.center, textureCoordinateToUse);
    textureCoordinateToUse = fragmentInput.textureCoordinate;
    
    if (dist < uniform.radius)
    {
        textureCoordinateToUse -= uniform.center;
        float percent = 1.0 - ((uniform.radius - dist) / uniform.radius) * uniform.scale;
        percent = percent * percent;
        
        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += uniform.center;
    }
    
    constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
    return inputTexture.sample(quadSampler, textureCoordinateToUse);
}
