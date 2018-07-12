#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment half4 luminanceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]])
//                                  constant BrightnessUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float luminance = dot(color.rgb, luminanceWeighting);
    
    return half4(half3(luminance), color.a);
}

/*
 uniform sampler2D inputImageTexture;
 
 // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
 const vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
 float luminance = dot(textureColor.rgb, W);
 
 gl_FragColor = vec4(vec3(luminance), textureColor.a);
 }
*/
