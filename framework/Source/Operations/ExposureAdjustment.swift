public class ExposureAdjustment: BasicOperation {
    public var exposure:Float = 0.0 { didSet { uniformSettings["exposure"] = exposure } }
    
    public init() {
        super.init(fragmentFunctionName:"exposureFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
    }
}
