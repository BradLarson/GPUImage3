import MetalPerformanceShaders

public class Convolution3x3: TextureSamplingOperation {
    public var convolutionKernel:Matrix3x3 = Matrix3x3.centerOnly {
        didSet
        {
            if self.useMetalPerformanceShaders, #available(iOS 9, macOS 10.13, *) {
                internalMPSConvolution = MPSImageConvolution(device: sharedMetalRenderingDevice.device, kernelWidth: 3, kernelHeight: 3, weights: convolutionKernel.toMPSFloatArray())
                (internalMPSConvolution as! MPSImageConvolution).edgeMode = .clamp
            } else {
                uniformSettings["convolutionKernel"] = convolutionKernel
            }
        }
    }
    var internalMPSConvolution: NSObject?
    
    public init() {
        super.init(fragmentFunctionName:"convolution3x3")
        
//        self.useMetalPerformanceShaders = true
        ({convolutionKernel = Matrix3x3.centerOnly})()

        if #available(iOS 9, macOS 10.13, *) {
            self.metalPerformanceShaderPathway = usingMPSImageConvolution
        }
    }

    @available(iOS 9, macOS 10.13, *) func usingMPSImageConvolution(commandBuffer:MTLCommandBuffer, inputTextures:[UInt:Texture], outputTexture:Texture) {
        (internalMPSConvolution as? MPSImageConvolution)?.encode(commandBuffer:commandBuffer, sourceTexture:inputTextures[0]!.texture, destinationTexture:outputTexture.texture)
    }

}


extension Matrix3x3 {
    public func toMPSFloatArray() -> [Float] {
        // Row major
        return [m11, m12, m13, m21, m22, m23, m31, m32, m33]
    }
}
