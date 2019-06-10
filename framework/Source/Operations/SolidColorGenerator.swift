public class SolidColorGenerator: ImageGenerator {

    public func renderColor(_ color:Color) {
        guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {return}

        commandBuffer.clear(with: color, outputTexture: internalTexture)
        
        notifyTargets()
    }
}
