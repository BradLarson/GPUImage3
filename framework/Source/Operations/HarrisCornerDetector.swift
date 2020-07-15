//
//  HarrisCornerDetector.swift
//  GPUImage
//
//  Created by PavanK on 7/14/20.
//  Copyright © 2020 Red Queen Coder, LLC. All rights reserved.
//


/* Harris corner detector

 First pass: reduce to luminance and take the derivative of the luminance texture (GPUImageXYDerivativeFilter)

 Second pass: blur the derivative (GaussianBlur)

 Third pass: apply the Harris corner detection calculation

 This is the Harris corner detector, as described in
 C. Harris and M. Stephens. A Combined Corner and Edge Detector. Proc. Alvey Vision Conf., Univ. Manchester, pp. 147-151, 1988.
*/
import Metal

public class HarrisCornerDetector: OperationGroup {
    public var blurRadiusInPixels:Float = 2.0 { didSet { gaussianBlur.blurRadiusInPixels = blurRadiusInPixels } }
    public var sensitivity:Float = 5.0 { didSet { harrisCornerDetector.uniformSettings["sensitivity"] = sensitivity } }
    public var threshold:Float = 0.2 { didSet { nonMaximumSuppression.uniformSettings["threshold"] = threshold } }
    public var cornersDetectedCallback:(([Position]) -> ())?

    let xyDerivative = TextureSamplingOperation(fragmentFunctionName: "xyDerivative")
    let gaussianBlur = GaussianBlur()
    var harrisCornerDetector : TextureSamplingOperation//(fragmentFunctionName : "harrisCornerDetector")
    let nonMaximumSuppression = TextureSamplingOperation(fragmentFunctionName: "nonMaxSuppression")

    public init(fragmentShaderFunction :String = "harrisCornerDetector") {
        self.harrisCornerDetector = TextureSamplingOperation(fragmentFunctionName : fragmentShaderFunction)
        super.init()
        ({blurRadiusInPixels = 2.0})()
        ({sensitivity = 5.0})()
        ({threshold = 0.2})()
        
        outputImageRelay.newImageCallback = {[weak self] texture in
            if let cornersDetectedCallback = self?.cornersDetectedCallback {
                cornersDetectedCallback(extractCornersFromImage(texture))
            }
        }

        self.configureGroup{input, output in
            input --> self.xyDerivative --> self.gaussianBlur --> self.harrisCornerDetector --> self.nonMaximumSuppression --> output
        }
    }
}

func extractCornersFromImage(_ texture: Texture) -> [Position] {
    
//    let startTime = CFAbsoluteTimeGetCurrent()
    let imageByteSize = Int(texture.texture.height * texture.texture.width * 4)
    let rawImagePixels = UnsafeMutablePointer<UInt8>.allocate(capacity:imageByteSize)
    let region = MTLRegionMake2D(0, 0, texture.texture.width, texture.texture.height)
    texture.texture.getBytes(rawImagePixels, bytesPerRow: texture.texture.width * 4, from: region, mipmapLevel: 0)
    
    let imageWidth = Int(texture.texture.width * 4)
    var corners = [Position]()

    var currentByte = 0
    while (currentByte < imageByteSize) {
        let colorByte = rawImagePixels[currentByte]

        if (colorByte > 0) {
            let xCoordinate = currentByte % imageWidth
            let yCoordinate = currentByte / imageWidth

            corners.append(Position(((Float(xCoordinate) / 4.0) / Float(texture.texture.width)), Float(yCoordinate) / Float(texture.texture.height)))
        }
        currentByte += 4
    }

    rawImagePixels.deallocate()
//    print("Harris extraction frame time: \(CFAbsoluteTimeGetCurrent() - startTime) with total corners found = \(corners.count)")
    return corners
    
}
