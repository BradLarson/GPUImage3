public class ThresholdSketchFilter: TextureSamplingOperation {
    public var edgeStrength: Float = 1.0 {
        didSet { uniformSettings["edgeStrength"] = edgeStrength }
    }
    public var threshold: Float = 0.25 { didSet { uniformSettings["threshold"] = threshold } }

    public init() {
        super.init(fragmentFunctionName: "thresholdSketchFragment", numberOfInputs: 1)

        ({ edgeStrength = 1.0 })()
        ({ threshold = 0.25 })()
    }
}
