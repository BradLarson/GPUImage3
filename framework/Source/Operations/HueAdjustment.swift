public class HueAdjustment: BasicOperation {
    public var hue:Float = 90.0 { didSet { uniformSettings[0] = hue } }
    
    public init() {
        super.init(fragmentFunctionName:"hueFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(90.0)
    }
}
