public class BulgeDistortion: BasicOperation {
    public var radius:Float = 0.25 { didSet { uniformSettings[0] = radius } }
    public var scale:Float = 0.5 { didSet { uniformSettings[1] = scale } }
    public var center:Position = .center { didSet { uniformSettings[2] = center } }

    public init() {
        super.init(fragmentFunctionName:"bulgeDistortionFragment", numberOfInputs:1)

        uniformSettings.appendUniform(0.25)
        uniformSettings.appendUniform(0.5)
        uniformSettings.appendUniform(Position.center)
    }
}
