public class Solarize: BasicOperation {
    public var threshold:Float = 0.5 { didSet { uniformSettings["threshold"] = threshold } }
    
    public init() {
        super.init(fragmentFunctionName: "solarizeFragment", numberOfInputs:1)
        uniformSettings.appendUniform(0.5)
    }
}
