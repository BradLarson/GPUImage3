public class KuwaharaFilter: BasicOperation {
    public var radius:Float = 3.0 { didSet { uniformSettings["radius"] = radius } }
    
    public init() {
        super.init(fragmentFunctionName:"kuwaharaFragment", numberOfInputs:1)
        
        ({radius = 3.0})()
    }
}
