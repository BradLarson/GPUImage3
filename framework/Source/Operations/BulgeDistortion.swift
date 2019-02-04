public class BulgeDistortion: BasicOperation {
    public var radius:Float = 0.25 { didSet { uniformSettings["radius"] = radius } }
    public var scale:Float = 0.5 { didSet { uniformSettings["scale"] = scale } }
    public var center:Position = Position.center { didSet { uniformSettings["center"] = center } }
    
    public init() {
        super.init(fragmentFunctionName:"bulgeDistortionFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.25)
        uniformSettings.appendUniform(0.5)
        uniformSettings.appendUniform(Position.center)
    }
}
