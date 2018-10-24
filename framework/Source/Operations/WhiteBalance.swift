public class WhiteBalance: BasicOperation {
    public var temperature:Float = 5000.0 { didSet { uniformSettings[0] = temperature < 5000.0 ? 0.0004 * (temperature - 5000.0) : 0.00006 * (temperature - 5000.0) } }
    public var tint:Float = 0.0 { didSet { uniformSettings[1] = tint / 100.0 } }

    public init() {
        super.init(fragmentFunctionName:"whiteBalanceFragmentShader", numberOfInputs:1)

        uniformSettings.appendUniform(5000.0)
        uniformSettings.appendUniform(0.0)
    }
}
