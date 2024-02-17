#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 colorDodgeBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                      texture2d<half> inputTexture [[texture(0)]],
                                      texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 base = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 overlay = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    half3 baseOverlayAlphaProduct = half3(overlay.a * base.a);
    half3 rightHandProduct = overlay.rgb * (1.0h - base.a) + base.rgb * (1.0h - overlay.a);
    
    half3 firstBlendColor = baseOverlayAlphaProduct + rightHandProduct;
    half3 overlayRGB = clamp((overlay.rgb / clamp(overlay.a, 0.01h, 1.0h)) * step(0.0h, overlay.a), 0.0h, 0.99h);
    
    half3 secondBlendColor = (base.rgb * overlay.a) / (1.0h - overlayRGB) + rightHandProduct;
    
    half3 colorChoice = step((overlay.rgb * base.a + base.rgb * overlay.a), baseOverlayAlphaProduct);
    
    return half4(mix(firstBlendColor, secondBlendColor, colorChoice), 1.0h);
}
