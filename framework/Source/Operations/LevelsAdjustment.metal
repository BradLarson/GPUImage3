#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float3 minimum;
    float3 middle;
    float3 maximum;
    float3 minOutput;
    float3 maxOutput;
} LevelAdjustmentUniform;

// Possibly convert these to functions
#define LevelsControlInputRange(color, minInput, maxInput)     min(max(color - minInput, half3(0.0)) / (maxInput - minInput), half3(1.0))
#define LevelsControlInput(color, minInput, gamma, maxInput)   GammaCorrection(LevelsControlInputRange(color, minInput, maxInput), gamma)
#define LevelsControlOutputRange(color, minOutput, maxOutput)   mix(minOutput, maxOutput, color)
#define LevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput)  LevelsControlOutputRange(LevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)

 /*
 ** Gamma correction
 ** Details: http://blog.mouaif.org/2009/01/22/photoshop-gamma-correction-shader/
 */
#define GammaCorrection(color, gamma)  pow(color, 1.0 / gamma)

 
/*
 ** Levels control (input (+gamma), output)
 ** Details: http://blog.mouaif.org/2009/01/28/levels-control-shader/
 */

fragment half4 levelsFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant LevelAdjustmentUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    return half4(LevelsControl(color.rgb, half3(uniform.minimum), half3(uniform.middle), half3(uniform.maximum), half3(uniform.minOutput), half3(uniform.maxOutput)), color.a);
}
