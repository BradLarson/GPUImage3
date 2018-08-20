public class ChromaKeyBlend: BasicOperation {
    public var thresholdSensitivity:Float = 0.4 { didSet { uniformSettings[0] = thresholdSensitivity } }
    public var smoothing:Float = 0.1 { didSet { uniformSettings[1] = smoothing } }
    public var colorToReplace:Color = Color.green { didSet { uniformSettings[2] = colorToReplace } }
    
    public init() {
        super.init(fragmentFunctionName:"chromaKeyBlendFragment", numberOfInputs:2)
        
        uniformSettings.appendUniform(0.4)
        uniformSettings.appendUniform(0.1)
        uniformSettings.appendUniform(Color.green)
    }
}
