public class LuminanceRangeReduction: BasicOperation {
    public var rangeReductionFactor:Float = 0.6 { didSet { uniformSettings["rangeReduction"] = rangeReductionFactor } }
    
    public init() {
        super.init(fragmentFunctionName: "luminanceRangeFragment", numberOfInputs: 1)
        
        ({rangeReductionFactor = 0.6})()
    }
}
