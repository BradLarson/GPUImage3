public class ColorMatrixFilter: BasicOperation {
    public var intensity:Float = 1.0 { didSet { uniformSettings[0] = intensity } }
    public var colorMatrix:Matrix4x4 = Matrix4x4.identity { didSet { uniformSettings[1] = colorMatrix } }
    
    public init() {
        
        super.init(fragmentFunctionName:"colorMatrixFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(Matrix4x4.identity)
    }
}
