#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct {
    float edgeStrength;
} SketchUniform;

fragment half4 sketchFragment(NearbyTexelVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant SketchUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half bottomLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half bottomRightIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    half leftIntensity = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    half rightIntensity = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    half bottomIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half topIntensity = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    half topRightIntensity = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    half topLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;

    half h = -topLeftIntensity - 2.0h * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0h * bottomIntensity + bottomRightIntensity;
    half v = -bottomLeftIntensity - 2.0h * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0h * rightIntensity + topRightIntensity;
    
    half mag = 1.0h - (length(half2(h, v)) * uniform.edgeStrength);
    return half4(half3(mag), 1.0h);
}

/*
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 uniform float edgeStrength;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
 float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
 float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
 float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
 float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;
 float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
 float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
 float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
 float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
 float h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
 float v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
 
 float mag = 1.0 - (length(vec2(h, v)) * edgeStrength);
 
 gl_FragColor = vec4(vec3(mag), 1.0);
 }

 */
