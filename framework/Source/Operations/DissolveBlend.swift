public class DissolveBlend: BasicOperation {
    public var mix:Float = 0.5 { didSet { uniformSettings[0] = mix } }

    public init() {
        super.init(fragmentFunctionName:"dissolveBlendFragment", numberOfInputs:2)
        
        uniformSettings.appendUniform(0.5)
    }
}
