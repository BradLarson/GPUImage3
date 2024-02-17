#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float2 center;
} StretchDistortionUniform;

fragment half4 stretchDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant StretchDistortionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    float2 normCoord = 2.0 * fragmentInput.textureCoordinate - 1.0;
    float2 normCenter = 2.0 * uniform.center - 1.0;

    normCoord -= normCenter;
    float2 s = sign(normCoord);
    normCoord = abs(normCoord);
    normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
    normCoord = s * normCoord;

    normCoord += normCenter;

    float2 textureCoordinateToUse = normCoord / 2.0 + 0.5;

    return inputTexture.sample(quadSampler, textureCoordinateToUse );
}