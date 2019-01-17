#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float thresholdSensitivity;
    float smoothing;
    float4 colorToReplace;
} ChromaKeyUniform;

fragment half4 ChromaKeyFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant ChromaKeyUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half maskY = 0.2989h * uniform.colorToReplace.r + 0.5866h * uniform.colorToReplace.g + 0.1145h * uniform.colorToReplace.b;
    half maskCr = 0.7132h * (uniform.colorToReplace.r - maskY);
    half maskCb = 0.5647h * (uniform.colorToReplace.b - maskY);
    
    half Y = 0.2989h * color.r + 0.5866h * color.g + 0.1145h * color.b;
    half Cr = 0.7132h * (color.r - Y);
    half Cb = 0.5647h * (color.b - Y);
    
    half blendValue = smoothstep(half(uniform.thresholdSensitivity), half(uniform.thresholdSensitivity + uniform.smoothing), distance(half2(Cr, Cb), half2(maskCr, maskCb)));
    
    return half4(color.rgb, color.a * blendValue);
}

/*
 void main()
 {
 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
 
 float maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
 float maskCr = 0.7132 * (colorToReplace.r - maskY);
 float maskCb = 0.5647 * (colorToReplace.b - maskY);
 
 float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
 float Cr = 0.7132 * (textureColor.r - Y);
 float Cb = 0.5647 * (textureColor.b - Y);
 
 //     float blendValue = 1.0 - smoothstep(thresholdSensitivity - smoothing, thresholdSensitivity , abs(Cr - maskCr) + abs(Cb - maskCb));
 float blendValue = smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
 gl_FragColor = vec4(textureColor.rgb, textureColor.a * blendValue);
 }
 */
