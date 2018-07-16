public class RGBAdjustment: BasicOperation {
    public var red:Float = 1.0 { didSet { uniformSettings[0] = red } }
    public var blue:Float = 1.0 { didSet { uniformSettings[1] = blue } }
    public var green:Float = 1.0 { didSet { uniformSettings[2] = green } }
    
    public init() {
        super.init(fragmentFunctionName:"rgbAdjustmentFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(1.0)
    }
}
