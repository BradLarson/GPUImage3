/*
 This equation is a simplification of the general blending equation. It assumes the destination color is opaque, and therefore drops the destination color's alpha term.
 
 D = C1 * C1a + C2 * C2a * (1 - C1a)
 where D is the resultant color, C1 is the color of the first element, C1a is the alpha of the first element, C2 is the second element color, C2a is the alpha of the second element. The destination alpha is calculated with:
 
 Da = C1a + C2a * (1 - C1a)
 The resultant color is premultiplied with the alpha. To restore the color to the unmultiplied values, just divide by Da, the resultant alpha.
 
 http://stackoverflow.com/questions/1724946/blend-mode-on-a-transparent-and-semi-transparent-background
 
 For some reason Photoshop behaves
 D = C1 + C2 * C2a * (1 - C1a)
 */

#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 normalBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  texture2d<half> inputTexture2 [[texture(1)]])
{
    constexpr sampler quadSampler;
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler2, fragmentInput.textureCoordinate2);
    
    half4 outputColor;
    
    half a = textureColor.a + textureColor2.a * (1.0h - textureColor.a);
    half alphaDivisor = a + step(a, 0.0h); // Protect against a divide-by-zero blacking out things in the output
    
    outputColor.r = (textureColor.r * textureColor.a + textureColor2.r * textureColor2.a * (1.0h - textureColor.a))/alphaDivisor;
    outputColor.g = (textureColor.g * textureColor.a + textureColor2.g * textureColor2.a * (1.0h - textureColor.a))/alphaDivisor;
    outputColor.b = (textureColor.b * textureColor.a + textureColor2.b * textureColor2.a * (1.0h - textureColor.a))/alphaDivisor;
    outputColor.a = a;
    
    return outputColor;
}
