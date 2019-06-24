public class ToonFilter: TextureSamplingOperation {
    public var threshold:Float = 0.2 { didSet { uniformSettings["threshold"] = threshold } }
    public var quantizationLevels:Float = 10.0 { didSet { uniformSettings["quantizationLevels"] = quantizationLevels } }
    
    public init() {
        super.init(fragmentFunctionName:"toonFragment", numberOfInputs:1)
        
        ({threshold = 0.2})()
        ({quantizationLevels = 10.0})()
    }
}
