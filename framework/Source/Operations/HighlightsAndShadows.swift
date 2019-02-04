public class HighlightsAndShadows: BasicOperation {
    public var shadows:Float = 0.0 { didSet { uniformSettings["shadows"] = shadows } }
    public var highlights:Float = 1.0 { didSet { uniformSettings["highlights"] = highlights } }
    
    public init() {
        super.init(fragmentFunctionName:"highlightShadowFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
        uniformSettings.appendUniform(1.0)
    }
}
