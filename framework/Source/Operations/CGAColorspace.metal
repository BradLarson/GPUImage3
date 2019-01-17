#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

fragment half4 CGAColorspaceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]])
{
    float2 sampleDivisor = float2(1.0 / 200.0, 1.0 / 320.0);
    
    constexpr sampler quadSampler;
    float2 samplePos = fragmentInput.textureCoordinate - mod(fragmentInput.textureCoordinate, sampleDivisor);
    half4 color = inputTexture.sample(quadSampler, samplePos);
    
    half4 colorCyan = half4(85.0h / 255.0h, 1.0h, 1.0h, 1.0h);
    half4 colorMagenta = half4(1.0h, 85.0h / 255.0h, 1.0h, 1.0h);
    half4 colorWhite = half4(1.0h);
    half4 colorBlack = half4(0.0h, 0.0h, 0.0h, 1.0h);
    
    half4 endColor;
    half blackDistance = distance(color, colorBlack);
    half whiteDistance = distance(color, colorWhite);
    half magentaDistance = distance(color, colorMagenta);
    half cyanDistance = distance(color, colorCyan);
    
    half4 finalColor;
    
    half colorDistance = min(magentaDistance, cyanDistance);
    colorDistance = min(colorDistance, whiteDistance);
    colorDistance = min(colorDistance, blackDistance);
    
    if (colorDistance == blackDistance) {
        finalColor = colorBlack;
    } else if (colorDistance == whiteDistance) {
        finalColor = colorWhite;
    } else if (colorDistance == cyanDistance) {
        finalColor = colorCyan;
    } else {
        finalColor = colorMagenta;
    }
    
    return finalColor;
}
/*
 void main()
 {
 vec2 sampleDivisor = vec2(1.0 / 200.0, 1.0 / 320.0);
 //highp vec4 colorDivisor = vec4(colorDepth);
 
 vec2 samplePos = textureCoordinate - mod(textureCoordinate, sampleDivisor);
 vec4 color = texture2D(inputImageTexture, samplePos );
 
 //gl_FragColor = texture2D(inputImageTexture, samplePos );
 vec4 colorCyan = vec4(85.0 / 255.0, 1.0, 1.0, 1.0);
 vec4 colorMagenta = vec4(1.0, 85.0 / 255.0, 1.0, 1.0);
 vec4 colorWhite = vec4(1.0, 1.0, 1.0, 1.0);
 vec4 colorBlack = vec4(0.0, 0.0, 0.0, 1.0);
 
 vec4 endColor;
 float blackDistance = distance(color, colorBlack);
 float whiteDistance = distance(color, colorWhite);
 float magentaDistance = distance(color, colorMagenta);
 float cyanDistance = distance(color, colorCyan);
 
 vec4 finalColor;
 
 float colorDistance = min(magentaDistance, cyanDistance);
 colorDistance = min(colorDistance, whiteDistance);
 colorDistance = min(colorDistance, blackDistance);
 
 if (colorDistance == blackDistance) {
 finalColor = colorBlack;
 } else if (colorDistance == whiteDistance) {
 finalColor = colorWhite;
 } else if (colorDistance == cyanDistance) {
 finalColor = colorCyan;
 } else {
 finalColor = colorMagenta;
 }
 
 gl_FragColor = finalColor;
 }
 */
