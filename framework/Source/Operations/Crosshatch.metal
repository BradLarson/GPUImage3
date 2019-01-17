#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float crossHatchSpacing;
    float lineWidth;
} CrosshatchUniform;

fragment half4 crosshatchFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant CrosshatchUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate); // Do we use these? How??
    
    half luminance = dot(color.rgb, luminanceWeighting);
    
    half4 colorToDisplay = half4(1.0); // I think you only need one value if they're all the same
    
    if (luminance < 1.00)
    {
        if (mod(fragmentInput.textureCoordinate.x + fragmentInput.textureCoordinate.y, uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    if (luminance < 0.75)
    {
        if (mod(fragmentInput.textureCoordinate.x - fragmentInput.textureCoordinate.y, uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    if (luminance < 0.50)
    {
        if (mod(fragmentInput.textureCoordinate.x + fragmentInput.textureCoordinate.y - (uniform.crossHatchSpacing / 2.0), uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    if (luminance < 0.3)
    {
        if (mod(fragmentInput.textureCoordinate.x - fragmentInput.textureCoordinate.y - (uniform.crossHatchSpacing / 2.0), uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    return colorToDisplay;
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float crossHatchSpacing;
 uniform float lineWidth;
 
 const vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
 float luminance = dot(texture2D(inputImageTexture, textureCoordinate).rgb, W);
 
 vec4 colorToDisplay = vec4(1.0, 1.0, 1.0, 1.0);
 if (luminance < 1.00)
 {
 if (mod(textureCoordinate.x + textureCoordinate.y, crossHatchSpacing) <= lineWidth)
 {
 colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
 }
 }
 if (luminance < 0.75)
 {
 if (mod(textureCoordinate.x - textureCoordinate.y, crossHatchSpacing) <= lineWidth)
 {
 colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
 }
 }
 if (luminance < 0.50)
 {
 if (mod(textureCoordinate.x + textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth)
 {
 colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
 }
 }
 if (luminance < 0.3)
 {
 if (mod(textureCoordinate.x - textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth)
 {
 colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
 }
 }
 
 gl_FragColor = colorToDisplay;
 }

 */
