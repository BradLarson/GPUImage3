#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 divideBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    half ra;
    if (overlay.a == 0.0h || ((base.r / overlay.r) > (base.a / overlay.a)))
        ra = overlay.a * base.a + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    else
        ra = (base.r * overlay.a * overlay.a) / overlay.r + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    
    half ga;
    if (overlay.a == 0.0h || ((base.g / overlay.g) > (base.a / overlay.a)))
        ga = overlay.a * base.a + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    else
        ga = (base.g * overlay.a * overlay.a) / overlay.g + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    
    half ba;
    if (overlay.a == 0.0h || ((base.b / overlay.b) > (base.a / overlay.a)))
        ba = overlay.a * base.a + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    else
        ba = (base.b * overlay.a * overlay.a) / overlay.b + overlay.b * (1.0h - base.a) + base.b * (1.0h - overlay.a);
    
    half a = overlay.a + base.a - overlay.a * base.a;
    
    return half4(ra, ga, ba, a);
}
