#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

half lum(half3 c) {
    return dot(c, half3(0.3, 0.59, 0.11));
}

half3 clipcolor(half3 c) {
    half l = lum(c);
    half n = min(min(c.r, c.g), c.b);
    half x = max(max(c.r, c.g), c.b);
    
    if (n < 0.0h) {
        c.r = l + ((c.r - l) * l) / (l - n);
        c.g = l + ((c.g - l) * l) / (l - n);
        c.b = l + ((c.b - l) * l) / (l - n);
    }
    if (x > 1.0h) {
        c.r = l + ((c.r - l) * (1.0h - l)) / (x - l);
        c.g = l + ((c.g - l) * (1.0h - l)) / (x - l);
        c.b = l + ((c.b - l) * (1.0h - l)) / (x - l);
    }
    
    return c;
}

half3 setlum(half3 c, half l) {
    half d = l - lum(c);
    c = c + half3(d);
    return clipcolor(c);
}

fragment half4 colorBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    return half4(base.rgb * (1.0h - overlay.a) + setlum(overlay.rgb, lum(base.rgb)) * overlay.a, base.a);
}
