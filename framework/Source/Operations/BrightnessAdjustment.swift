public class BrightnessAdjustment: BasicOperation {
    public var brightness:Float = 0.0 { didSet { uniformSettings["brightness"] = brightness } }
    
    public init() {
        super.init(fragmentFunctionName:"brightnessFragment", numberOfInputs:1)
        
        ({brightness = 0.0})()
    }
}
