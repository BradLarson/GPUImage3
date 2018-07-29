public class Convolution3x3: TextureSamplingOperation {
    public var convolutionKernel:Matrix3x3 = Matrix3x3.centerOnly { didSet { uniformSettings[0] = convolutionKernel } }
    
    public init() {
        super.init(fragmentFunctionName:"convolution3x3")
        
        uniformSettings.appendUniform(Matrix3x3.centerOnly)
    }
}
