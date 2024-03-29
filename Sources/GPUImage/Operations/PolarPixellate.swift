// Issues with Size not working with the compiler
public class PolarPixellate: BasicOperation {
    public var pixelSize: Size = Size(width: 0.05, height: 0.05) {
        didSet { uniformSettings["pixelSize"] = pixelSize }
    }
    public var center: Position = Position.center { didSet { uniformSettings["center"] = center } }

    public init() {
        super.init(fragmentFunctionName: "polarPixellateFragment", numberOfInputs: 1)

        ({ pixelSize = Size(width: 0.05, height: 0.05) })()
        ({ center = Position.center })()
    }
}
