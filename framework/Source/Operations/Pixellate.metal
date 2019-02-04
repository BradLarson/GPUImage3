#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float fractionalWidthOfPixel;
    float aspectRatio;
} PixellateUniform;

fragment half4 pixellateFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant PixellateUniform& uniform [[buffer(1)]])
{
    float2 sampleDivisor = float2(uniform.fractionalWidthOfPixel, uniform.fractionalWidthOfPixel / uniform.aspectRatio);
    
    float2 samplePos = fragmentInput.textureCoordinate - mod(fragmentInput.textureCoordinate, sampleDivisor) + float2(0.5) * sampleDivisor;
    
    constexpr sampler quadSampler;
    return half4(inputTexture.sample(quadSampler, samplePos));
}


/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float fractionalWidthOfPixel;
 uniform float aspectRatio;
 
 void main()
 {
 vec2 sampleDivisor = vec2(fractionalWidthOfPixel, fractionalWidthOfPixel / aspectRatio);
 
 vec2 samplePos = textureCoordinate - mod(textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
 gl_FragColor = texture2D(inputImageTexture, samplePos );
 }
 */
