public class ZoomBlur: BasicOperation {
    public var blurSize:Float = 1.0 { didSet { uniformSettings["size"] = blurSize } }
    public var blurCenter:Position = Position.center { didSet { uniformSettings["center"] = blurCenter } }
    
    public init() {
        super.init(fragmentFunctionName:"zoomBlurFragment", numberOfInputs:1)
        
        ({blurSize = 1.0})()
        ({blurCenter = Position.center})()
    }
}
