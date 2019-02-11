public class Pixellate: BasicOperation {
    public var fractionalWidthOfAPixel:Float = 0.01 {
        didSet {
            uniformSettings["fractionalWidthOfPixel"] = max(fractionalWidthOfAPixel, 0.01)
        }
    }
    
    public init() {
        super.init(fragmentFunctionName:"pixellateFragment", numberOfInputs:1)
        
        ({fractionalWidthOfAPixel = 0.01})()
    }
}
