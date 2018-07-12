#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float exposure;
} ExposureUniform;

fragment half4 exposureFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<half> inputTexture [[texture(0)]],
                                  constant ExposureUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4((color.rgb * pow(2.0, uniform.exposure)), color.a);
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform float exposure;
 
 void main()
 {
 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
 
 gl_FragColor = vec4(textureColor.rgb * pow(2.0, exposure), textureColor.w);
 }
*/
