public class FalseColor: BasicOperation {
    public var firstColor: Color = Color(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0) {
        didSet { uniformSettings["firstColor"] = firstColor }
    }
    public var secondColor: Color = Color.red {
        didSet { uniformSettings["secondColor"] = secondColor }
    }

    public init() {
        super.init(fragmentFunctionName: "falseColorFragment", numberOfInputs: 1)

        uniformSettings.colorUniformsUseAlpha = true
        ({ firstColor = Color(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0) })()
        ({ secondColor = Color.red })()
    }
}
