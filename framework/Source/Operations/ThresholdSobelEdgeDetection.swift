public class ThresholdSobelEdgeDetection: TextureSamplingOperation {
    public var edgeStrength:Float = 1.0 { didSet { uniformSettings[0] = edgeStrength } }
    public var threshold:Float = 0.25 { didSet { uniformSettings[1] = threshold } }
    
    public init() {
        super.init(fragmentFunctionName:"thresholdSobelEdgeDetectionFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(0.25)
    }
}
