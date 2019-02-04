public class SwirlDistortion: BasicOperation {
    public var radius:Float = 0.5 { didSet { uniformSettings["radius"] = radius } }
    public var angle:Float = 1.0 { didSet { uniformSettings["angle"] = angle } }
    public var center:Position = Position.center { didSet { uniformSettings["center"] = center } }
    
    public init() {
        super.init(fragmentFunctionName:"swirlFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.5)
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(Position.center)
    }
}
