//
//  XYDerivative.metal
//  GPUImage
//
//  Created by PavanK on 7/15/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//


#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;


fragment half4 xyDerivative(NearbyTexelVertexIO fragmentInput [[stage_in]],
                            texture2d<half> inputTexture [[texture(0)]]) {
    
    constexpr sampler quadSampler(coord::pixel);
    
    half bottomLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half bottomRightIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    half leftIntensity = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    half rightIntensity = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    half bottomIntensity = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    half topIntensity = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    half topRightIntensity = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    half topLeftIntensity = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;
    
   
    
    half verticalDerivative = -topLeftIntensity - topIntensity - topRightIntensity + bottomLeftIntensity + bottomIntensity + bottomRightIntensity;
    half horizontalDerivative = -bottomLeftIntensity - leftIntensity - topLeftIntensity + bottomRightIntensity + rightIntensity + topRightIntensity;
    verticalDerivative = verticalDerivative;
    horizontalDerivative = horizontalDerivative;
    
    return half4(horizontalDerivative * horizontalDerivative, verticalDerivative * verticalDerivative, ((verticalDerivative * horizontalDerivative) + 1.0) / 2.0, 1.0);
}
