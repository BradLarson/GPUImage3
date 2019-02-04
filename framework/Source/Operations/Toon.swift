public class ToonFilter: TextureSamplingOperation {
    public var threshold:Float = 0.2 { didSet { uniformSettings["threshold"] = threshold } }
    public var quantizationLevels:Float = 10.0 { didSet { uniformSettings["quantizationLevels"] = quantizationLevels } }
    
    public init() {
        super.init(fragmentFunctionName:"toonFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.2)
        uniformSettings.appendUniform(10.0)
    }
}
