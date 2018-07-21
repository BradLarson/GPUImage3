public class LuminanceThreshold: BasicOperation {
    public var threshold:Float = 0.5 { didSet { uniformSettings[0] = threshold } }
    
    public init() {
        super.init(fragmentFunctionName: "thresholdFragment", numberOfInputs:1)
         uniformSettings.appendUniform(0.5)
    }
}
