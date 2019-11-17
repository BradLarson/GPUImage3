#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float scale;
    float2 center;
    float aspectRatio;
} PinchDistortionUniform;

fragment half4 pinchDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant PinchDistortionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float dist = distance(uniform.center, textureCoordinateToUse);
    textureCoordinateToUse = fragmentInput.textureCoordinate;
    
    if (dist < uniform.radius)
    {
        textureCoordinateToUse -= uniform.center;
        float percent = 1.0 + ((0.5 - dist) / 0.5) * uniform.scale;
        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += uniform.center;
        
        return half4(inputTexture.sample(quadSampler, textureCoordinateToUse ));
    }
    else
    {
        return half4(inputTexture.sample(quadSampler, fragmentInput.textureCoordinate ));
    }
}
