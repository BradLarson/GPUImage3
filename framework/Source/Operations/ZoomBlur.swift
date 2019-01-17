public class ZoomBlur: BasicOperation {
    public var blurSize:Float = 1.0 { didSet { uniformSettings[0] = blurSize } }
    public var blurCenter:Position = Position.center { didSet { uniformSettings[1] = blurCenter } }
    
    public init() {
        super.init(fragmentFunctionName:"zoomBlurFragment", numberOfInputs:1)
        
        uniformSettings.appendUniform(1.0)
        uniformSettings.appendUniform(Position.center)
    }
}
