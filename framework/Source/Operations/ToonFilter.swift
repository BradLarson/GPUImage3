public class ToonFilter: TextureSamplingOperation {
    public var threshold:Float = 0.2 { didSet { uniformSettings[0] = threshold } }
    public var quantizationLevels:Float = 10.0 { didSet { uniformSettings[1] = quantizationLevels } }

    public init() {
        super.init(fragmentFunctionName: "toonFragment")
        uniformSettings.appendUniform(0.2)
        uniformSettings.appendUniform(10.0)
    }
}