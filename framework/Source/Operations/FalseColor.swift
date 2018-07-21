public class FalseColor: BasicOperation {
    public var firstColor:Color = Color(red:0.0, green:0.0, blue:0.5, alpha:1.0) { didSet { uniformSettings[0] = firstColor } }
    public var secondColor:Color = Color.red { didSet { uniformSettings[1] = secondColor } }
    
    public init() {
        super.init(fragmentFunctionName:"falseColorFragment", numberOfInputs:1)
        
        uniformSettings.colorUniformsUseAlpha = true
        uniformSettings.appendUniform(Color(red:0.0, green:0.0, blue:0.5, alpha:1.0))
        uniformSettings.appendUniform(Color.red)
    }
}
