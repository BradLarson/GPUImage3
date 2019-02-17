#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float scale;
    float2 center;
    float aspectRatio;
} PinchDistortionUniform;

fragment half4 pinchDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant PinchDistortionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float dist = distance(uniform.center, textureCoordinateToUse);
    textureCoordinateToUse = fragmentInput.textureCoordinate;
    
    if (dist < uniform.radius)
    {
        textureCoordinateToUse -= uniform.center;
        float percent = 1.0 + ((0.5 - dist) / 0.5) * uniform.scale;
        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += uniform.center;
        
        return half4(inputTexture.sample(quadSampler, textureCoordinateToUse ));
//        return half4(1.0, 0.0, 0.0, 1.0);
    }
    else
    {
        return half4(inputTexture.sample(quadSampler, fragmentInput.textureCoordinate ));
    }
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float aspectRatio;
 uniform vec2 center;
 uniform float radius;
 uniform float scale;
 
 void main()
 {
 vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 float dist = distance(center, textureCoordinateToUse);
 textureCoordinateToUse = textureCoordinate;
 
 if (dist < radius)
 {
 textureCoordinateToUse -= center;
 float percent = 1.0 + ((0.5 - dist) / 0.5) * scale;
 textureCoordinateToUse = textureCoordinateToUse * percent;
 textureCoordinateToUse += center;
 
 gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse );
 }
 else
 {
 gl_FragColor = texture2D(inputImageTexture, textureCoordinate );
 }
 }
 */

