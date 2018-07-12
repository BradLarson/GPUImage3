#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float contrast;
} ContrastUniform;

fragment half4 contrastFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant ContrastUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4(((color.rgb - half3(0.5)) * uniform.contrast + half3(0.5)), color.a);
}


/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float contrast;
 
 void main()
 {
 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
 
 gl_FragColor = vec4(((textureColor.rgb - vec3(0.5)) * contrast + vec3(0.5)), textureColor.w);
 }
*/
