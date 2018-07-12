public class GammaAdjustment: BasicOperation {
    public var gamma:Float = 1.0 { didSet { uniformSettings[0] = gamma } }
    
    public init() {
        super.init(fragmentFunctionName:"gammaFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
    }
}
