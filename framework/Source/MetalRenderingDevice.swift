import Foundation
import Metal

public let sharedMetalRenderingDevice = MetalRenderingDevice()

public class MetalRenderingDevice {
    // MTLDevice
    // MTLCommandQueue
    
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let shaderLibrary: MTLLibrary
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {fatalError("Could not create Metal Device")}
        self.device = device
        
        guard let queue = self.device.makeCommandQueue() else {fatalError("Could not create command queue")}
        self.commandQueue = queue
        
        do {
            let frameworkBundle = Bundle(for: MetalRenderingDevice.self)
            let metalLibraryPath = frameworkBundle.path(forResource: "default", ofType: "metallib")!
            
            self.shaderLibrary = try device.makeLibrary(filepath:metalLibraryPath)
        } catch {
            fatalError("Could not load library")
        }
    }
}
