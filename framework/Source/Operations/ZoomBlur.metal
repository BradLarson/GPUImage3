#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float blurSize;
    float2 blurCenter;
} ZoomBlurUniform;

fragment half4 zoomBlurFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant ZoomBlurUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    // TODO: Do a more intelligent scaling based on resolution here
    float2 textureCoordinate = fragmentInput.textureCoordinate;
    float2 samplingOffset = 1.0/100.0 * (uniform.blurCenter - textureCoordinate) * uniform.blurSize;
    
    half4 fragmentColor = inputTexture.sample(quadSampler, textureCoordinate) * 0.18;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate + samplingOffset) * 0.15;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate + (2.0 * samplingOffset)) *  0.12;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate + (3.0 * samplingOffset)) * 0.09;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate + (4.0 * samplingOffset)) * 0.05;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate - samplingOffset) * 0.15;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate - (2.0 * samplingOffset)) *  0.12;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate - (3.0 * samplingOffset)) * 0.09;
    fragmentColor += inputTexture.sample(quadSampler, textureCoordinate - (4.0 * samplingOffset)) * 0.05;
    
    return fragmentColor;
}
