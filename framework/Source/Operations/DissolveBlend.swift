public class DissolveBlend: BasicOperation {
    public var mix:Float = 0.5 { didSet { uniformSettings["mixturePercent"] = mix } }

    public init() {
        super.init(fragmentFunctionName:"dissolveBlendFragment", numberOfInputs:2)
        
        ({mix = 0.5})()
    }
}
