public class Haze: BasicOperation {
    public var distance:Float = 0.2 { didSet { uniformSettings[0] = distance } }
    public var slope:Float = 0.0 { didSet { uniformSettings[1] = slope } }
    
    public init() {
        super.init(fragmentFunctionName:"hazeFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(0.2)
        uniformSettings.appendUniform(0.0)
    }
}
