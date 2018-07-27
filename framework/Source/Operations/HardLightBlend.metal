#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 hardLightBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                      texture2d<half> inputTexture [[texture(0)]],
                                      texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    half ra;
    if (2.0h * overlay.r < overlay.a) {
        ra = 2.0h * overlay.r * base.r + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0h * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    }
    
    half ga;
    if (2.0h * overlay.g < overlay.a) {
        ga = 2.0h * overlay.g * base.g + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0h * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    }
    
    half ba;
    if (2.0h * overlay.b < overlay.a) {
        ba = 2.0h * overlay.b * base.b + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0h * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    }
    
    return half4(ra, ga, ba, 1.0h);
}
