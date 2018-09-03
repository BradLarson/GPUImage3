public class Sharpen: TextureSamplingOperation {
    public var sharpness:Float = 0.0 { didSet { uniformSettings[0] = sharpness } }
    
    public init() {
        super.init(fragmentFunctionName:"sharpenFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
    }
}

