public class Crosshatch: BasicOperation {
    public var crossHatchSpacing:Float = 0.03 { didSet { uniformSettings[0] = crossHatchSpacing } }
    public var lineWidth:Float = 0.003 { didSet { uniformSettings[1] = lineWidth } }

    public init() {
        super.init(fragmentFunctionName: "crosshatchFragment", numberOfInputs: 1)
        uniformSettings.appendUniform(0.03)
        uniformSettings.appendUniform(0.03)
    }
}