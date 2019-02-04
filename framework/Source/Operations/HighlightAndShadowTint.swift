public class HighlightAndShadowTint: BasicOperation {
    public var shadowTintIntensity:Float = 0.0 { didSet { uniformSettings["shadowTintIntensity"] = shadowTintIntensity } }
    public var highlightTintIntensity:Float = 0.0 { didSet { uniformSettings["highlightTintIntensity"] = highlightTintIntensity } }
    public var shadowTintColor:Color = Color.red { didSet { uniformSettings["shadowTintColor"] = shadowTintColor } }
    public var highlightTintColor:Color = Color.blue { didSet { uniformSettings["highlightTintColor"] = highlightTintColor } }
    
    public init() {
        super.init(fragmentFunctionName:"highlightShadowTintFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
        uniformSettings.appendUniform(0.0)
        uniformSettings.appendUniform(Color.red)
        uniformSettings.appendUniform(Color.blue)
    }
}
