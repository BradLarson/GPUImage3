#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float fractionalWidthOfPixel;
} PixellateUniform;

fragment half4 pixellateFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant PixellateUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half2 sampleDivisor = half2(uniform.fractionalWidthOfPixel, uniform.fractionalWidthOfPixel / aspectRatio); // TODO: Figure out aspect ratio
    
    half2 samplePos = fragmentInput.textureCoordinate - mod(fragmentInput.textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
    
    return inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
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
