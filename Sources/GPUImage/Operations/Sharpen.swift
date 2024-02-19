public class Sharpen: TextureSamplingOperation {
    public var sharpness: Float = 0.0 { didSet { uniformSettings["sharpness"] = sharpness } }

    public init() {
        super.init(fragmentFunctionName: "sharpenFragment")

        ({ sharpness = 0.0 })()
    }
}
