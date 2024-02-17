public class LuminanceThreshold: BasicOperation {
    public var threshold:Float = 0.5 { didSet { uniformSettings["threshold"] = threshold } }
    
    public init() {
        super.init(fragmentFunctionName: "thresholdFragment", numberOfInputs:1)
        
        ({threshold = 0.5})()
    }
}
