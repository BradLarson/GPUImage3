#include <metal_stdlib>
using namespace metal;

#ifndef OPERATIONSHADERTYPES_H
#define OPERATIONSHADERTYPES_H

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

#endif
