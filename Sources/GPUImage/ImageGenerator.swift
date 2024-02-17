public class ImageGenerator: ImageSource {
    public var size:Size

    public let targets = TargetContainer()
    var internalTexture:Texture!

    public init(size:Size) {
        self.size = size
        internalTexture = Texture(device:sharedMetalRenderingDevice.device, orientation:.portrait, width:Int(size.width), height:Int(size.height), timingStyle:.stillImage)
    }
    
    public func transmitPreviousImage(to target:ImageConsumer, atIndex:UInt) {
        target.newTextureAvailable(internalTexture, fromSourceIndex:atIndex)
    }
    
    func notifyTargets() {
        updateTargetsWithTexture(internalTexture)
    }
}
