#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 softLightBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<half> inputTexture [[texture(0)]],
                                       texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    half alphaDivisor = base.a + step(base.a, 0.0h); // Protect against a divide-by-zero blacking out things in the output
    
    return base * (overlay.a * (base / alphaDivisor) + (2.0h * overlay * (1.0h - (base / alphaDivisor)))) + overlay * (1.0h - base.a) + base * (1.0h - overlay.a);
}
