public class ChromaKeying: BasicOperation {
    public var thresholdSensitivity:Float = 0.4 { didSet { uniformSettings[0] = thresholdSensitivity } }
    public var smoothing:Float = 0.1 { didSet { uniformSettings[1] = smoothing } }
    public var colorToReplace:Color = Color.green { didSet { uniformSettings[2] = colorToReplace } }
    
    public init() {
        super.init(fragmentFunctionName:"ChromaKeyFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.04)
        uniformSettings.appendUniform(0.01)
        uniformSettings.appendUniform(Color.green)
    }
}
