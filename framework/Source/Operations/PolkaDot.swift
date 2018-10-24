public class PolkaDot: BasicOperation {
    public var dotScaling:Float = 0.90 { didSet { uniformSettings[0] = dotScaling } }
    public var fractionalWidthOfAPixel:Float = 0.01 {
        didSet {
            uniformSettings[1] = max(fractionalWidthOfAPixel, 0.01)
        }
    }

    public init() {
        super.init(fragmentFunctionName:"polkaDotFragment", numberOfInputs:1)

        uniformSettings.appendUniform(0.01)
        uniformSettings.appendUniform(0.90)
    }
}
