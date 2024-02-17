import MetalPerformanceShaders

func roundToOdd(_ number: Float) -> Int {
    return 2 * Int(floor(number / 2.0)) + 1
}

public class BoxBlur: BasicOperation {
    public var blurRadiusInPixels:Float = 2.0 {
        didSet
        {
            if self.useMetalPerformanceShaders, #available(iOS 9, macOS 10.13, *) {
                let kernelSize = roundToOdd(blurRadiusInPixels) // MPS box blur kernels need to be odd
                internalMPSImageBox = MPSImageBox(device: sharedMetalRenderingDevice.device, kernelWidth: kernelSize, kernelHeight: kernelSize)
            } else {
                fatalError("Box blur not yet implemented on pre-MPS OS versions")
//                uniformSettings["convolutionKernel"] = convolutionKernel
            }
        }
    }
    var internalMPSImageBox: NSObject?
    
    public init() {
        super.init(fragmentFunctionName:"passthroughFragment")
        
        self.useMetalPerformanceShaders = true
        
        ({blurRadiusInPixels = 2.0})()
        
        if #available(iOS 9, macOS 10.13, *) {
            self.metalPerformanceShaderPathway = usingMPSImageBox
        } else {
            fatalError("Box blur not yet implemented on pre-MPS OS versions")
        }
    }
    
    @available(iOS 9, macOS 10.13, *) func usingMPSImageBox(commandBuffer:MTLCommandBuffer, inputTextures:[UInt:Texture], outputTexture:Texture) {
        (internalMPSImageBox as? MPSImageBox)?.encode(commandBuffer:commandBuffer, sourceTexture:inputTextures[0]!.texture, destinationTexture:outputTexture.texture)
    }
    
}
