#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float2 center;
    float size;
} ZoomBlurUniform;


fragment half4 zoomBlurFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant ZoomBlurUniform& uniform [[buffer(1)]])
{
    float2 samplingOffset = 1.0/100.0 * (uniform.center - fragmentInput.textureCoordinate) * uniform.size;
    
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate) * 0.18;
    
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (4.0h * samplingOffset)) * 0.05h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (4.0h * samplingOffset)) * 0.05h;

    return color;
}
