public class Vibrance: BasicOperation {
    public var vibrance: Float = 0.0 { didSet { uniformSettings["vibrance"] = vibrance } }

    public init() {
        super.init(fragmentFunctionName: "vibranceFragment", numberOfInputs: 1)

        ({ vibrance = 0.0 })()
    }
}
