public class ContrastAdjustment: BasicOperation {
    public var contrast:Float = 1.0 { didSet { uniformSettings["contrast"] = contrast } }
    
    public init() {
        super.init(fragmentFunctionName:"contrastFragment", numberOfInputs:1)
        
        ({contrast = 1.0})()
    }
}
