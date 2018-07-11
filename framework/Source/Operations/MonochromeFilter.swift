public class MonochromeFilter: BasicOperation {
    public var intensity:Float = 1.0 { didSet { uniformSettings[0] = intensity } }
    public var color:Color = Color(red:0.6, green:0.45, blue:0.3, alpha:1.0) { didSet { uniformSettings[1] = color } }
    
    public init() {
        super.init(fragmentFunctionName:"monochromeFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(Color(red:0.6, green:0.45, blue:0.3, alpha:1.0))
    }
}

