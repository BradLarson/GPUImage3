// Issues with Size not working with the compiler
public class PolarPixellate: BasicOperation {
    public var pixelSize:Size = Size(width:0.05, height:0.05) { didSet { uniformSettings[0] = pixelSize } }
    public var center:Position = Position.center { didSet { uniformSettings[1] = center } }
    
    public init() {
        super.init(fragmentFunctionName:"polarPixellateFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(pixelSize)
        uniformSettings.appendUniform(center)
    }
}
