public class Posterize: BasicOperation {
    public var colorLevels:Float = 10.0 { didSet { uniformSettings["colorLevels"] = colorLevels } }
    
    public init() {
        super.init(fragmentFunctionName: "posterizeFragment", numberOfInputs: 1)
        
        uniformSettings.appendUniform(10.0)
    }
}
