#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float size;
    float2 center;
} ZoomBlurUniform;


fragment half4 zoomBlurFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant ZoomBlurUniform& uniform [[buffer(1)]])
{
    float2 samplingOffset = 1.0/100.0 * (uniform.center - fragmentInput.textureCoordinate) * uniform.size;
    
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate) * 0.18;
    
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (4.0h * samplingOffset)) * 0.05h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (4.0h * samplingOffset)) * 0.05h;

    return color;
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform vec2 blurCenter;
 uniform float blurSize;
 
 void main()
 {
 // TODO: Do a more intelligent scaling based on resolution here
 vec2 samplingOffset = 1.0/100.0 * (blurCenter - textureCoordinate) * blurSize;
 
 vec4 fragmentColor = texture2D(inputImageTexture, textureCoordinate) * 0.18;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate + samplingOffset) * 0.15;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate + (2.0 * samplingOffset)) *  0.12;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate + (3.0 * samplingOffset)) * 0.09;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate + (4.0 * samplingOffset)) * 0.05;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate - samplingOffset) * 0.15;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate - (2.0 * samplingOffset)) *  0.12;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate - (3.0 * samplingOffset)) * 0.09;
 fragmentColor += texture2D(inputImageTexture, textureCoordinate - (4.0 * samplingOffset)) * 0.05;
 
 gl_FragColor = fragmentColor;
 }
 */
