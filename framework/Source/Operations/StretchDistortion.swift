public class StretchDistortion: BasicOperation {
    public var center:Position = Position.center { didSet { uniformSettings["center"] = center } }
    
    public init() {
        super.init(fragmentFunctionName:"stretchDistortionFragment", numberOfInputs:1)

        ({center = Position.center})()
    }
}
