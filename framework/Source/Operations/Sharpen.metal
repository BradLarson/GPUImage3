#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position [[position]];
    
    float2 textureCoordinate [[user(textureCoordinate)]];
    float2 leftTextureCoordinate [[user(leftTextureCoordinate)]];
    float2 rightTextureCoordinate [[user(rightTextureCoordinate)]];
    float2 topTextureCoordinate [[user(topTextureCoordinate)]];
    float2 bottomTextureCoordinate [[user(bottomTextureCoordinate)]];
}  SharpenVertexIO;



vertex SharpenVertexIO sharpenVertex(const device packed_float2 *position [[buffer(0)]],
                                     const device packed_float2 *textureCoordinate [[buffer(1)]],
                                     uint vid [[vertex_id]])
{
    SharpenVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);
    
    float2 widthStep = float2(1.0, 0.0);
    float2 heightStep = float2(0.0, 1.0);
    
    outputVertices.textureCoordinate = textureCoordinate[vid];
    outputVertices.leftTextureCoordinate = textureCoordinate[vid] - widthStep;
    outputVertices.rightTextureCoordinate = textureCoordinate[vid] + widthStep;
    outputVertices.topTextureCoordinate = textureCoordinate[vid] + heightStep;
    outputVertices.bottomTextureCoordinate = textureCoordinate[vid] - heightStep;
    
    return outputVertices;
}


// Vertex Shader
/*
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;

 uniform float texelWidth;
 uniform float texelHeight;
 uniform float sharpness;

 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 varying vec2 topTextureCoordinate;
 varying vec2 bottomTextureCoordinate;

 varying float centerMultiplier;
 varying float edgeMultiplier;

 void main()
 {
     gl_Position = position;
     
     vec2 widthStep = vec2(texelWidth, 0.0);
     vec2 heightStep = vec2(0.0, texelHeight);
     
     textureCoordinate = inputTextureCoordinate.xy;
     leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
     rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
     topTextureCoordinate = inputTextureCoordinate.xy + heightStep;
     bottomTextureCoordinate = inputTextureCoordinate.xy - heightStep;
     
     centerMultiplier = 1.0 + 4.0 * sharpness;
     edgeMultiplier = sharpness;
 }

 */

typedef struct {
    float sharpness;
} SharpenUniform;

fragment half4 sharpenFragment(SharpenVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              constant SharpenUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    half3 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).rgb;
    half3 leftColor = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).rgb;
    half3 rightColor = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).rgb;
    half3 topColor = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).rgb;
    half3 bottomColor = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).rgb;
    
    half edgeMultiplier = half(uniform.sharpness);
    half centerMultiplier = 1.0 + 4.0 * edgeMultiplier;
    
    return half4((centerColor * centerMultiplier
                  - (leftColor * edgeMultiplier + rightColor * edgeMultiplier+ topColor * edgeMultiplier + bottomColor * edgeMultiplier)),
                 inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).w);
    
}
// Fragment Shader
/*
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 varying vec2 topTextureCoordinate;
 varying vec2 bottomTextureCoordinate;

 varying float centerMultiplier;
 varying float edgeMultiplier;

 uniform sampler2D inputImageTexture;

 void main()
 {
     vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     vec3 leftTextureColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
     vec3 rightTextureColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
     vec3 topTextureColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
     vec3 bottomTextureColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
     
     gl_FragColor = vec4((textureColor * centerMultiplier - (leftTextureColor * edgeMultiplier + rightTextureColor * edgeMultiplier + topTextureColor * edgeMultiplier + bottomTextureColor * edgeMultiplier)), texture2D(inputImageTexture, bottomTextureCoordinate).w);
 }

 */
