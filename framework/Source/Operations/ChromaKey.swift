public class ChromaKeying: BasicOperation {
    public var thresholdSensitivity:Float = 0.4 { didSet { uniformSettings["thresholdSensitivity"] = thresholdSensitivity } }
    public var smoothing:Float = 0.1 { didSet { uniformSettings["smoothing"] = smoothing } }
    public var colorToReplace:Color = Color.green { didSet { uniformSettings["colorToReplace"] = colorToReplace } }
    
    public init() {
        super.init(fragmentFunctionName:"ChromaKeyFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.04)
        uniformSettings.appendUniform(0.01)
        uniformSettings.appendUniform(Color.green)
    }
}
