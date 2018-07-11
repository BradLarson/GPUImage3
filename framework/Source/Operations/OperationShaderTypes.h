#include <metal_stdlib>
using namespace metal;

#ifndef OPERATIONSHADERTYPES_H
#define OPERATIONSHADERTYPES_H

constant half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

#endif
