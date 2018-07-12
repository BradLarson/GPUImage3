public class SaturationAdjustment: BasicOperation {
    public var saturation:Float = 1.0 { didSet { uniformSettings[0] = saturation } }
    
    public init() {
        super.init(fragmentFunctionName:"saturationFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
    }
}
