public class Vignette: BasicOperation {
    public var center:Position = Position.center { didSet { uniformSettings[0] = center } }
    public var color:Color = Color.black { didSet { uniformSettings[1] = color } }
    public var start:Float = 0.3 { didSet { uniformSettings[2] = start } }
    public var end:Float = 0.75 { didSet { uniformSettings[3] = end } }
    
    public init() {
        super.init(fragmentFunctionName:"vignetteFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(Position.center)
        uniformSettings.appendUniform(Color.black)
        uniformSettings.appendUniform(0.3)
        uniformSettings.appendUniform(0.75)
    }
}
