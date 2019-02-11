public class HueAdjustment: BasicOperation {
    public var hue:Float = 90.0 { didSet { uniformSettings["hue"] = hue } }
    
    public init() {
        super.init(fragmentFunctionName:"hueFragment", numberOfInputs:1)
        
        ({hue = 90.0})()
    }
}
