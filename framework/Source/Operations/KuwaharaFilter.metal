// Sourced from Kyprianidis, J. E., Kang, H., and Doellner, J. "Anisotropic Kuwahara Filtering on the GPU," GPU Pro p.247 (2010).
//
// Original header:
//
// Anisotropic Kuwahara Filtering on the GPU
// by Jan Eric Kyprianidis <www.kyprianidis.com>

#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
} KuwaharaUniform;

constant float2 src_size = float2(1.0 / 768.0, 1.0 / 1024.0);

fragment half4 kuwaharaFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]],
                             constant KuwaharaUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler;
    float2 textureCoordinateToUse = fragmentInput.textureCoordinate;
    float n = float((uniform.radius + 1.0) * (uniform.radius + 1.0));
    
    int i;
    int j;
    
    float3 m0 = float3(0.0);
    float3 m1 = float3(0.0);
    float3 m2 = float3(0.0);
    float3 m3 = float3(0.0);
    
    float3 s0 = float3(0.0);
    float3 s1 = float3(0.0);
    float3 s2 = float3(0.0);
    float3 s3 = float3(0.0);
    
    float3 c;
    
    for (j = -float(uniform.radius); j <= 0; ++j)  {
        for (i = -float(uniform.radius); i <= 0; ++i)  {
            c = float3(inputTexture.sample(quadSampler, textureCoordinateToUse + float2(float(i),float(j)) * src_size).rgb);
            m0 += c;
            s0 += c * c;
        }
    }
    
    for (j = -float(uniform.radius); j <= 0; ++j)  {
        for (i = 0; i <= float(uniform.radius); ++i)  {
            c = float3(inputTexture.sample(quadSampler, textureCoordinateToUse + float2(float(i),float(j)) * src_size).rgb);
            m1 += c;
            s1 += c * c;
        }
    }
    
    for (j = 0; j <= float(uniform.radius); ++j)  {
        for (i = 0; i <= float(uniform.radius); ++i)  {
            c = float3(inputTexture.sample(quadSampler, textureCoordinateToUse + float2(float(i),float(j)) * src_size).rgb);
            m2 += c;
            s2 += c * c;
        }
    }
    
    for (j = 0; j <= float(uniform.radius); ++j)  {
        for (i = -float(uniform.radius); i <= 0; ++i)  {
            c = float3(inputTexture.sample(quadSampler, textureCoordinateToUse + float2(float(i),float(j)) * src_size).rgb);
            m3 += c;
            s3 += c * c;
        }
    }
    
    float min_sigma2 = 100;
    m0 /= n;
    s0 = abs(s0 / n - m0 * m0);
    
    float sigma2 = s0.r + s0.g + s0.b;
    
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        return half4(half3(m0), 1.0);
    }
    
    m1 /= n;
    s1 = abs(s1 / n - m1 * m1);
    
    sigma2 = s1.r + s1.g + s1.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        return half4(half3(m1), 1.0);
    }
    
    m2 /= n;
    s2 = abs(s2 / n - m2 * m2);
    
    sigma2 = s2.r + s2.g + s2.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        return half4(half3(m2), 1.0);
    }
    
    m3 /= n;
    s3 = abs(s3 / n - m3 * m3);
    
    sigma2 = s3.r + s3.g + s3.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        return half4(half3(m3), 1.0);
    }
    
    // In the original Kuwahara filter, there was no default return value if the entire filter executes without returning
    // To avoid a crash, a default value of the original pixel color will be returned.
    return inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
}
