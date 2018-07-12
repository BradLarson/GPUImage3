public class ContrastAdjustment: BasicOperation {
    public var contrast:Float = 1.0 { didSet { uniformSettings[0] = contrast } }
    
    public init() {
        super.init(fragmentFunctionName:"contrastFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
    }
}
