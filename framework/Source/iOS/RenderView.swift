import Foundation
import MetalKit

public class RenderView: MTKView, ImageConsumer {
    
    public let sources = SourceContainer()
    public let maximumInputs: UInt = 1
    var currentTexture: Texture?
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        commonInit()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        framebufferOnly = false
        autoResizeDrawable = true
        contentMode = .scaleToFill
        self.layer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0)
        self.device = sharedMetalRenderingDevice.device
        
        enableSetNeedsDisplay = false
        isPaused = true
    }
    
    public func newTextureAvailable(_ texture:Texture, fromSourceIndex:UInt) {
        self.drawableSize = CGSize(width: texture.texture.width, height: texture.texture.height)
        currentTexture = texture
        self.draw()
    }
    
    public override func draw(_ rect:CGRect) {
        if let currentDrawable = self.currentDrawable,
            let imageTexture = currentTexture?.texture {
            let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer()
            
            let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
            blitEncoder?.copy(from: imageTexture,
                              sourceSlice: 0,
                              sourceLevel: 0,
                              sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                              sourceSize: MTLSizeMake(imageTexture.width, imageTexture.height, imageTexture.depth),
                              to: currentDrawable.texture,
                              destinationSlice: 0,
                              destinationLevel: 0,
                              destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
            blitEncoder?.endEncoding()
            
            commandBuffer?.present(currentDrawable)
            commandBuffer?.commit()
        }
    }
    
}
