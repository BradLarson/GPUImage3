#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float thresholdSensitivity;
    float smoothing;
    float4 colorToReplace;
    
} ChromaKeyUniform;

fragment half4 chromaKeyBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  texture2d<half> inputTexture2 [[texture(1)]],
                                  constant ChromaKeyUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    constexpr sampler quadSampler2;
    half4 textureColor2 = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    half maskY = 0.2989h * uniform.colorToReplace.r + 0.5866h * uniform.colorToReplace.g + 0.1145h * uniform.colorToReplace.b;
    half maskCr = 0.7132h * (uniform.colorToReplace.r - maskY);
    half maskCb = 0.5647h * (uniform.colorToReplace.b - maskY);
    
    half Y = 0.2989h * textureColor.r + 0.5866h * textureColor.g + 0.1145h * textureColor.b;
    half Cr = 0.7132h * (textureColor.r - Y);
    half Cb = 0.5647h * (textureColor.b - Y);
    
    //     float blendValue = 1.0 - smoothstep(thresholdSensitivity - smoothing, thresholdSensitivity , abs(Cr - maskCr) + abs(Cb - maskCb));
    float blendValue = 1.0 - smoothstep(uniform.thresholdSensitivity, uniform.thresholdSensitivity + uniform.smoothing, distance(float2(Cr, Cb), float2(maskCr, maskCb)));
    return half4(mix(textureColor, textureColor2, half(blendValue)));
}
