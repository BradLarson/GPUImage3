public class OpacityAdjustment: BasicOperation {
    public var opacity:Float = 0.0 { didSet { uniformSettings[0] = opacity } }
    
    public init() {        
        super.init(fragmentFunctionName:"opacityFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
    }
}
