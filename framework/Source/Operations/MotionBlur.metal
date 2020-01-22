#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position [[position]];
    
    float2 textureCoordinate [[user(textureCoordinate)]];
    
    float2 oneStepBackTextureCoordinate [[user(oneStepBackTextureCoordinate)]];
    float2 twoStepsBackTextureCoordinate [[user(twoStepsBackTextureCoordinate)]];
    float2 threeStepsBackTextureCoordinate [[user(threeStepsBackTextureCoordinate)]];
    float2 fourStepsBackTextureCoordinate [[user(fourStepsBackTextureCoordinate)]];
    
    float2 oneStepForwardTextureCoordinate [[user(oneStepForwardTextureCoordinate)]];
    float2 twoStepsForwardTextureCoordinate [[user(twoStepsForwardTextureCoordinate)]];
    float2 threeStepsForwardTextureCoordinate [[user(threeStepsForwardTextureCoordinate)]];
    float2 fourStepsForwardTextureCoordinate [[user(fourStepsForwardTextureCoordinate)]];
}  MotionBlurVertexIO;

vertex MotionBlurVertexIO motionBlurVertex(const device packed_float2 *position [[buffer(0)]],
                                               const device packed_float2 *textureCoordinate [[buffer(1)]],
                                               uint vid [[vertex_id]])
{
    MotionBlurVertexIO outputVertices;
    outputVertices.position = float4(position[vid], 0, 1.0);
    
    float2 singleHeightStep = float2(0.0, 1.0);
    
    outputVertices.textureCoordinate = textureCoordinate[vid];
    outputVertices.oneStepBackTextureCoordinate = textureCoordinate[vid] - singleHeightStep;
    outputVertices.twoStepsBackTextureCoordinate = textureCoordinate[vid] - 2.0 * singleHeightStep;
    outputVertices.threeStepsBackTextureCoordinate = textureCoordinate[vid] - 3.0 * singleHeightStep;
    outputVertices.fourStepsBackTextureCoordinate = textureCoordinate[vid] - 4.0 * singleHeightStep;
    outputVertices.oneStepForwardTextureCoordinate = textureCoordinate[vid] - singleHeightStep;
    outputVertices.twoStepsForwardTextureCoordinate = textureCoordinate[vid] - 2.0 * singleHeightStep;
    outputVertices.threeStepsForwardTextureCoordinate = textureCoordinate[vid] - 3.0 * singleHeightStep;
    outputVertices.fourStepsForwardTextureCoordinate = textureCoordinate[vid] - 4.0 * singleHeightStep;
    
    return outputVertices;
}
// Vertex Shader
/*
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;

 uniform vec2 directionalTexelStep;

 varying vec2 textureCoordinate;
 varying vec2 oneStepBackTextureCoordinate;
 varying vec2 twoStepsBackTextureCoordinate;
 varying vec2 threeStepsBackTextureCoordinate;
 varying vec2 fourStepsBackTextureCoordinate;
 varying vec2 oneStepForwardTextureCoordinate;
 varying vec2 twoStepsForwardTextureCoordinate;
 varying vec2 threeStepsForwardTextureCoordinate;
 varying vec2 fourStepsForwardTextureCoordinate;

 void main()
 {
     gl_Position = position;
     
     textureCoordinate = inputTextureCoordinate.xy;
     oneStepBackTextureCoordinate = inputTextureCoordinate.xy - directionalTexelStep;
     twoStepsBackTextureCoordinate = inputTextureCoordinate.xy - 2.0 * directionalTexelStep;
     threeStepsBackTextureCoordinate = inputTextureCoordinate.xy - 3.0 * directionalTexelStep;
     fourStepsBackTextureCoordinate = inputTextureCoordinate.xy - 4.0 * directionalTexelStep;
     oneStepForwardTextureCoordinate = inputTextureCoordinate.xy + directionalTexelStep;
     twoStepsForwardTextureCoordinate = inputTextureCoordinate.xy + 2.0 * directionalTexelStep;
     threeStepsForwardTextureCoordinate = inputTextureCoordinate.xy + 3.0 * directionalTexelStep;
     fourStepsForwardTextureCoordinate = inputTextureCoordinate.xy + 4.0 * directionalTexelStep;
 }

 */

fragment half4 motionBlurFragment(MotionBlurVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half4 fragmentColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate) * 0.18;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.oneStepBackTextureCoordinate) * 0.15;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.twoStepsBackTextureCoordinate) * 0.12;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.threeStepsBackTextureCoordinate) * 0.09;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.fourStepsBackTextureCoordinate) * 0.05;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.oneStepForwardTextureCoordinate) * 0.15;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.twoStepsForwardTextureCoordinate) * 0.12;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.threeStepsForwardTextureCoordinate) * 0.09;
    fragmentColor += inputTexture.sample(quadSampler, fragmentInput.fourStepsForwardTextureCoordinate) * 0.05;
    
    return fragmentColor;
}


// Fragment Shader
/*
 uniform sampler2D inputImageTexture;
 
 varying vec2 textureCoordinate;
 varying vec2 oneStepBackTextureCoordinate;
 varying vec2 twoStepsBackTextureCoordinate;
 varying vec2 threeStepsBackTextureCoordinate;
 varying vec2 fourStepsBackTextureCoordinate;
 varying vec2 oneStepForwardTextureCoordinate;
 varying vec2 twoStepsForwardTextureCoordinate;
 varying vec2 threeStepsForwardTextureCoordinate;
 varying vec2 fourStepsForwardTextureCoordinate;
 
 void main()
 {
 vec4 fragmentColor = texture2D(inputImageTexture, textureCoordinate) * 0.18;
 fragmentColor += texture2D(inputImageTexture, oneStepBackTextureCoordinate) * 0.15;
 fragmentColor += texture2D(inputImageTexture, twoStepsBackTextureCoordinate) *  0.12;
 fragmentColor += texture2D(inputImageTexture, threeStepsBackTextureCoordinate) * 0.09;
 fragmentColor += texture2D(inputImageTexture, fourStepsBackTextureCoordinate) * 0.05;
 fragmentColor += texture2D(inputImageTexture, oneStepForwardTextureCoordinate) * 0.15;
 fragmentColor += texture2D(inputImageTexture, twoStepsForwardTextureCoordinate) *  0.12;
 fragmentColor += texture2D(inputImageTexture, threeStepsForwardTextureCoordinate) * 0.09;
 fragmentColor += texture2D(inputImageTexture, fourStepsForwardTextureCoordinate) * 0.05;
 
 gl_FragColor = fragmentColor;
 }
 */
