public class LevelsAdjustment: BasicOperation {
    public var minimum:Color = Color(red:0.0, green:0.0, blue:0.0) { didSet { uniformSettings["minimum"] = minimum } }
    public var middle:Color = Color(red:1.0, green:1.0, blue:1.0) { didSet { uniformSettings["middle"] = middle } }
    public var maximum:Color = Color(red:1.0, green:1.0, blue:1.0) { didSet { uniformSettings["maximum"] = maximum } }
    public var minOutput:Color = Color(red:0.0, green:0.0, blue:0.0) { didSet { uniformSettings["minOutput"] = minOutput } }
    public var maxOutput:Color = Color(red:1.0, green:1.0, blue:1.0) { didSet { uniformSettings["maxOutput"] = maxOutput } }
    
    // TODO: Is this an acceptable interface, or do I need to bring this closer to the old implementation?
    
    public init() {
        super.init(fragmentFunctionName: "levelsFragment", numberOfInputs: 1)
        
        ({minimum = Color(red:0.0, green:0.0, blue:0.0)})()
        ({middle = Color(red:1.0, green:1.0, blue:1.0)})()
        ({maximum = Color(red:1.0, green:1.0, blue:1.0)})()
        ({minOutput = Color(red:0.0, green:0.0, blue:0.0)})()
        ({maxOutput = Color(red:1.0, green:1.0, blue:1.0)})()
    }
}
