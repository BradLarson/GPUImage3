//
//  ThresholdNonMaximumSuppresssion.metal
//  GPUImage
//
//  Created by PavanK on 7/15/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//

#include <metal_stdlib>
#include "TexelSamplingTypes.h"
using namespace metal;

typedef struct
{
    float threshold;
} NonMaxSuppressionUniform;

fragment half4 nonMaxSuppression(NearbyTexelVertexIO fragmentInput [[stage_in]],
                                    texture2d<half> inputTexture [[texture(0)]],
                                    constant NonMaxSuppressionUniform& uniform [[ buffer(1) ]]) {
    
    constexpr sampler quadSampler(coord::pixel);

    float bottomColor = inputTexture.sample(quadSampler, fragmentInput.bottomTextureCoordinate).r;
    float bottomLeftColor = inputTexture.sample(quadSampler, fragmentInput.bottomLeftTextureCoordinate).r;
    float bottomRightColor = inputTexture.sample(quadSampler, fragmentInput.bottomRightTextureCoordinate).r;
    float centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r;
    float leftColor = inputTexture.sample(quadSampler, fragmentInput.leftTextureCoordinate).r;
    float rightColor = inputTexture.sample(quadSampler, fragmentInput.rightTextureCoordinate).r;
    float topColor = inputTexture.sample(quadSampler, fragmentInput.topTextureCoordinate).r;
    float topRightColor = inputTexture.sample(quadSampler, fragmentInput.topRightTextureCoordinate).r;
    float topLeftColor = inputTexture.sample(quadSampler, fragmentInput.topLeftTextureCoordinate).r;

    // Use a tiebreaker for pixels to the left and immediately above this one
    float multiplier = 1.0 - step(centerColor, topColor);
    multiplier = multiplier * (1.0 - step(centerColor, topLeftColor));
    multiplier = multiplier * (1.0 - step(centerColor, leftColor));
    multiplier = multiplier * (1.0 - step(centerColor, bottomLeftColor));

    float maxValue = max(centerColor, bottomColor);
    maxValue = max(maxValue, bottomRightColor);
    maxValue = max(maxValue, rightColor);
    maxValue = max(maxValue, topRightColor);

    float finalValue = centerColor * step(maxValue, centerColor) * multiplier;
    finalValue = step(uniform.threshold, finalValue);

    return half4(finalValue, finalValue, finalValue, 1.0);
}
