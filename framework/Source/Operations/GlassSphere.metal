#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendShaderTypes.h"
using namespace metal;

typedef struct {
    float radius;
    float refractiveIndex;
    float2 center;
    float aspectRatio;
} GlassSphereUniform;

constant float3 lightPosition = float3(-0.5, 0.5, 1.0);
constant float3 ambientLightPosition = float3(0.0, 0.0, 1.0);

fragment half4 glassSphereFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant GlassSphereUniform& uniform [[buffer(1)]])
{
    constexpr sampler quadSampler(coord::pixel);
    float2 textureCoordinateToUse = float2(fragmentInput.textureCoordinate.x, (fragmentInput.textureCoordinate.y * uniform.aspectRatio + 0.5 - 0.5 * uniform.aspectRatio));
    float distanceFromCenter = distance(uniform.center, textureCoordinateToUse);
    float checkForPresenceWithinSphere = step(distanceFromCenter, uniform.radius);
    
    distanceFromCenter = distanceFromCenter / uniform.radius;
    
    float normalizedDepth = uniform.radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
    float3 sphereNormal = normalize(float3(textureCoordinateToUse - uniform.center, normalizedDepth));
    
    float3 refractedVector = 2.0 * refract(float3(0.0, 0.0, -1.0), sphereNormal, uniform.refractiveIndex);
    refractedVector.xy = -refractedVector.xy;
    
    half3 finalSphereColor = half3(inputTexture.sample(quadSampler, (refractedVector.xy + 1.0) * 0.5).rgb);
    
    // Grazing angle lighting
    float lightingIntensity = 2.5 * (1.0 - pow(clamp(dot(ambientLightPosition, sphereNormal), 0.0, 1.0), 0.25));
    finalSphereColor += lightingIntensity;
    
    // Specular lighting
    lightingIntensity  = clamp(dot(normalize(lightPosition), sphereNormal), 0.0, 1.0);
    lightingIntensity  = pow(lightingIntensity, 15.0);
    finalSphereColor += half3(0.8, 0.8, 0.8) * half(lightingIntensity);
    
    return half4(finalSphereColor, 1.0) * half(checkForPresenceWithinSphere);
}

/*
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform vec2 center;
 uniform float radius;
 uniform float aspectRatio;
 uniform float refractiveIndex;
 // uniform vec3 lightPosition;
 const vec3 lightPosition = vec3(-0.5, 0.5, 1.0);
 const vec3 ambientLightPosition = vec3(0.0, 0.0, 1.0);
 
 void main()
 {
 vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
 float distanceFromCenter = distance(center, textureCoordinateToUse);
 float checkForPresenceWithinSphere = step(distanceFromCenter, radius);
 
 distanceFromCenter = distanceFromCenter / radius;
 
 float normalizedDepth = radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
 vec3 sphereNormal = normalize(vec3(textureCoordinateToUse - center, normalizedDepth));
 
 vec3 refractedVector = 2.0 * refract(vec3(0.0, 0.0, -1.0), sphereNormal, refractiveIndex);
 refractedVector.xy = -refractedVector.xy;
 
 vec3 finalSphereColor = texture2D(inputImageTexture, (refractedVector.xy + 1.0) * 0.5).rgb;
 
 // Grazing angle lighting
 float lightingIntensity = 2.5 * (1.0 - pow(clamp(dot(ambientLightPosition, sphereNormal), 0.0, 1.0), 0.25));
 finalSphereColor += lightingIntensity;
 
 // Specular lighting
 lightingIntensity  = clamp(dot(normalize(lightPosition), sphereNormal), 0.0, 1.0);
 lightingIntensity  = pow(lightingIntensity, 15.0);
 finalSphereColor += vec3(0.8, 0.8, 0.8) * lightingIntensity;
 
 gl_FragColor = vec4(finalSphereColor, 1.0) * checkForPresenceWithinSphere;
 }

 */
