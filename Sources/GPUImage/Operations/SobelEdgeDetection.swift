public class SobelEdgeDetection: TextureSamplingOperation {
    public var edgeStrength: Float = 1.0 {
        didSet { uniformSettings["edgeStrength"] = edgeStrength }
    }

    public init() {
        super.init(fragmentFunctionName: "sobelEdgeDetectionFragment", numberOfInputs: 1)

        ({ edgeStrength = 1.0 })()
    }
}
