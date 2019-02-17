#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float refractiveIndex;
    float2 center;
    float aspectRatio;
} SphereRefractionUniform;

fragment half4 sphereRefractionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                 texture2d<half> inputTexture [[texture(0)]],
                                 constant SphereRefractionUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float distanceFromCenter = distance(uniform.center, textureCoordinateToUse);
    float checkForPresenceWithinSphere = step(distanceFromCenter, uniform.radius);
    
    distanceFromCenter = distanceFromCenter / uniform.radius;
    
    float normalizedDepth = uniform.radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
    float3 sphereNormal = normalize(float3(textureCoordinateToUse - uniform.center, normalizedDepth));
    
    float3 refractedVector = refract(float3(0.0, 0.0, -1.0), sphereNormal, uniform.refractiveIndex);
    
    return half4(inputTexture.sample(quadSampler, (refractedVector.xy + 1.0) * 0.5) * checkForPresenceWithinSphere);
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform vec2 center;
 uniform float radius;
 uniform float aspectRatio;
 uniform float refractiveIndex;
 
 void main()
 {
 vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 float distanceFromCenter = distance(center, textureCoordinateToUse);
 float checkForPresenceWithinSphere = step(distanceFromCenter, radius);
 
 distanceFromCenter = distanceFromCenter / radius;
 
 float normalizedDepth = radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
 vec3 sphereNormal = normalize(vec3(textureCoordinateToUse - center, normalizedDepth));
 
 vec3 refractedVector = refract(vec3(0.0, 0.0, -1.0), sphereNormal, refractiveIndex);
 
 gl_FragColor = texture2D(inputImageTexture, (refractedVector.xy + 1.0) * 0.5) * checkForPresenceWithinSphere;
 }

 */
