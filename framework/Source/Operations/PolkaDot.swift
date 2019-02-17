public class PolkaDot: BasicOperation {
    public var dotScaling:Float = 0.90 { didSet { uniformSettings["dotScaling"] = dotScaling } }
    public var fractionalWidthOfAPixel:Float = 0.01{
        didSet {
            uniformSettings["fractionalWidthOfPixel"] = max(fractionalWidthOfAPixel, 0.01)
        }
    }
    
    public init() {
        super.init(fragmentFunctionName:"polkaDotFragment", numberOfInputs:1)
        
        ({fractionalWidthOfAPixel = 0.01})()
        ({dotScaling = 0.90})()
    }
}
