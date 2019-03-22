#include <metal_stdlib>
#include "Operations/OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float3x3 colorConversionMatrix;
} YUVConversionUniform;

fragment half4 yuvConversionFullRangeFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(0)]],
                                     texture2d<half> inputTexture2 [[texture(1)]],
                                     constant YUVConversionUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half3 yuv;
    yuv.x = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r;
    yuv.yz = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate).rg - half2(0.5, 0.5);

    half3 rgb = half3x3(uniform.colorConversionMatrix) * yuv;
    
    return half4(rgb, 1.0);
}

fragment half4 yuvConversionVideoRangeFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                              texture2d<half> inputTexture [[texture(0)]],
                                              texture2d<half> inputTexture2 [[texture(1)]],
                                              constant YUVConversionUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half3 yuv;
    yuv.x = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r - (16.0/255.0);
    yuv.yz = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate).ra - half2(0.5, 0.5);
    
    half3 rgb = half3x3(uniform.colorConversionMatrix) * yuv;
    
    return half4(rgb, 1.0);
}
