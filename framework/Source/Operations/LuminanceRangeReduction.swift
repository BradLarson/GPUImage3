public class LuminanceRangeReduction: BasicOperation {
    public var rangeReductionFactor:Float = 0.6 { didSet { uniformSettings[0] = rangeReductionFactor } }
    
    public init() {
        super.init(fragmentFunctionName: "luminanceRangeFragment", numberOfInputs: 1)
        
        uniformSettings.appendUniform(0.6)
    }
}
