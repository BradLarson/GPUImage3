#include <metal_stdlib>
#include "OperationShaderTypes.h"
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
    float2 textureCoordinate = fragmentInput.textureCoordinate;
    half4 color = inputTexture.sample(quadSampler, textureCoordinate);
    half luminance = dot(color.rgb, luminanceWeighting);
    
    half4 colorToDisplay = half4(1.0, 1.0, 1.0, 1.0);
    if (luminance < 1.00)
    {
        if (fmod(textureCoordinate.x + textureCoordinate.y, uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    if (luminance < 0.75)
    {
        if (fmod(textureCoordinate.x - textureCoordinate.y, uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    if (luminance < 0.50)
    {
        if (fmod(textureCoordinate.x + textureCoordinate.y - (uniform.crossHatchSpacing / 2.0), uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    if (luminance < 0.3)
    {
        if (fmod(textureCoordinate.x - textureCoordinate.y - (uniform.crossHatchSpacing / 2.0), uniform.crossHatchSpacing) <= uniform.lineWidth)
        {
            colorToDisplay = half4(0.0, 0.0, 0.0, 1.0);
        }
    }
    
    return colorToDisplay;
}
