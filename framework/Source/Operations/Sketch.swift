public class SketchFilter: TextureSamplingOperation {
    public var edgeStrength:Float = 1.0 { didSet { uniformSettings[0] = edgeStrength } }
    
    public init() {
        super.init(fragmentFunctionName:"sketchFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
    }
}
