import Foundation
import Metal

public class ShaderUniformSettings {
    private var uniformValues:[Float] = []
    
    public subscript(index:Int) -> Float {
        get { return uniformValues[index]}
        set(newValue) { uniformValues[index] = newValue }
    }
    
    public func appendUniform(_ value:[Float]) {
        uniformValues.append(contentsOf:value)
    }
    
    public func restoreShaderSettings(renderEncoder:MTLRenderCommandEncoder) {
        guard (uniformValues.count > 0) else { return }
        
        let uniformBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: uniformValues,
                                                                         length: uniformValues.count * MemoryLayout<Float>.size,
                                                                         options: [])!
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
    }
}
