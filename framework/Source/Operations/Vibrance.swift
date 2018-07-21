public class Vibrance: BasicOperation {
    public var vibrance:Float = 0.0 { didSet { uniformSettings[0] = vibrance } }
    
    public init() {
        super.init(fragmentFunctionName:"vibranceFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
    }
}
