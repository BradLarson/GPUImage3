public class HighlightAndShadowTint: BasicOperation {
    public var shadowTintIntensity:Float = 0.0 { didSet { uniformSettings[0] = shadowTintIntensity } }
    public var highlightTintIntensity:Float = 0.0 { didSet { uniformSettings[1] = highlightTintIntensity } }
    public var shadowTintColor:Color = Color.red { didSet { uniformSettings[2] = shadowTintColor } }
    public var highlightTintColor:Color = Color.blue { didSet { uniformSettings[3] = highlightTintColor } }
    
    public init() {
        super.init(fragmentFunctionName:"highlightShadowTintFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.0)
        uniformSettings.appendUniform(0.0)
        uniformSettings.appendUniform(Color.red)
        uniformSettings.appendUniform(Color.blue)
    }
}
