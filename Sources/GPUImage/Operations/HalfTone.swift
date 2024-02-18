public class Halftone: BasicOperation {
    public var fractionalWidthOfAPixel: Float = 0.01 {
        didSet {
            uniformSettings["fractionalWidthOfPixel"] = max(fractionalWidthOfAPixel, 0.01)
        }
    }

    public init() {
        super.init(fragmentFunctionName: "halftoneFragment", numberOfInputs: 1)

        ({ fractionalWidthOfAPixel = 0.01 })()
    }
}
