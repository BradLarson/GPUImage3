public class ImageBuffer: ImageProcessingOperation {
    // TODO: Dynamically release textures on buffer resize
    public var bufferSize:UInt = 1
    public var activatePassthroughOnNextFrame = true
    
    public let maximumInputs:UInt = 1
    public let targets = TargetContainer()
    public let sources = SourceContainer()
    var bufferedTextures = [Texture]()

    public func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        bufferedTextures.append(texture)
        if (bufferedTextures.count > Int(bufferSize)) {
            let releasedTexture = bufferedTextures.removeFirst()
            updateTargetsWithTexture(releasedTexture)
        } else if activatePassthroughOnNextFrame {
            activatePassthroughOnNextFrame = false
            // Pass along the current frame to keep processing going until the buffer is built up
            updateTargetsWithTexture(texture)
        }
    }
    
    public func transmitPreviousImage(to target:ImageConsumer, atIndex:UInt) {
        // Buffers most likely won't need this
    }
}
