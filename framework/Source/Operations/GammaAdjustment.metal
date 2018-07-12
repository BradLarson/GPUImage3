#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float gamma;
} GammaUniform;

fragment half4 gammaFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant GammaUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4(pow(color.rgb, half3(uniform.gamma)), color.a);
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float gamma;
 
 void main()
 {
 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
 
 gl_FragColor = vec4(pow(textureColor.rgb, vec3(gamma)), textureColor.w);
 }

*/
