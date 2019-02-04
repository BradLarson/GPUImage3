public class Vignette: BasicOperation {
    public var center:Position = Position.center { didSet { uniformSettings["vignetteCenter"] = center } }
    public var color:Color = Color.black { didSet { uniformSettings["vignetteColor"] = color } }
    public var start:Float = 0.3 { didSet { uniformSettings["vignetteStart"] = start } }
    public var end:Float = 0.75 { didSet { uniformSettings["vignetteEnd"] = end } }
    
    public init() {
        super.init(fragmentFunctionName:"vignetteFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(Position.center)
        uniformSettings.appendUniform(Color.black)
        uniformSettings.appendUniform(0.3)
        uniformSettings.appendUniform(0.75)
    }
}
