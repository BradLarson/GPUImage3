public class LevelsAdjustment: BasicOperation {
    public var minimum:Color = Color(red:0.0, green:0.0, blue:0.0) { didSet { uniformSettings[0] = minimum } }
    public var middle:Color = Color(red:1.0, green:1.0, blue:1.0) { didSet { uniformSettings[1] = middle } }
    public var maximum:Color = Color(red:1.0, green:1.0, blue:1.0) { didSet { uniformSettings[2] = maximum } }
    public var minOutput:Color = Color(red:0.0, green:0.0, blue:0.0) { didSet { uniformSettings[3] = minOutput } }
    public var maxOutput:Color = Color(red:1.0, green:1.0, blue:1.0) { didSet { uniformSettings[4] = maxOutput } }
    
    // TODO: Is this an acceptable interface, or do I need to bring this closer to the old implementation?
    
    public init() {
        super.init(fragmentFunctionName: "levelsFragment", numberOfInputs: 1)
        
        uniformSettings.appendUniform(Color(red:0.0, green:0.0, blue:0.0))
        uniformSettings.appendUniform(Color(red:1.0, green:1.0, blue:1.0))
        uniformSettings.appendUniform(Color(red:1.0, green:1.0, blue:1.0))
        uniformSettings.appendUniform(Color(red:0.0, green:0.0, blue:0.0))
        uniformSettings.appendUniform(Color(red:1.0, green:1.0, blue:1.0))
    }
}
