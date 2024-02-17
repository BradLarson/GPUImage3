#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 addBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(0)]],
                                     texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    half r;
    if (overlay.r * base.a + base.r * overlay.a >= overlay.a * base.a) {
        r = overlay.a * base.a + overlay.r * (1.0h - base.a) + base.r * (1.0h - overlay.a);
    } else {
        r = overlay.r + base.r;
    }
    
    half g;
    if (overlay.g * base.a + base.g * overlay.a >= overlay.a * base.a) {
        g = overlay.a * base.a + overlay.g * (1.0h - base.a) + base.g * (1.0h - overlay.a);
    } else {
        g = overlay.g + base.g;
    }
    
    half b;
    if (overlay.b * base.a + base.b * overlay.a >= overlay.a * base.a) {
        b = overlay.a * base.a + overlay.b * (1.0h- base.a) + base.b * (1.0h - overlay.a);
    } else {
        b = overlay.b + base.b;
    }
    
    half a = overlay.a + base.a - overlay.a * base.a;
    
    return half4(r, g, b, a);
}
