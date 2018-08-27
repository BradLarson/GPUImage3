public class StretchDistortion: BasicOperation {
    public var center:Position = Position.center { didSet { uniformSettings[0] = center } }
    
    public init() {
        super.init(fragmentFunctionName:"stretchDistortionFragment", numberOfInputs:1)
        uniformSettings.appendUniform(Position.center)
    }
}
