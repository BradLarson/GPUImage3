import Foundation
import Metal

public class ShaderUniformSettings {
    private var uniformValues:[Float] = []
    private var uniformValueOffsets:[Int] = []
    public var colorUniformsUseAlpha:Bool = false
    
    private func internalIndex(for index:Int) -> Int {
        if (index == 0) {
            return 0
        } else {
            return uniformValueOffsets[index - 1]
        }
    }
    
    public subscript(index:Int) -> Float {
        get { return uniformValues[internalIndex(for:index)]}
        set(newValue) { uniformValues[internalIndex(for:index)] = newValue }
    }

    public subscript(index:Int) -> Color {
        get {
            // TODO: Fix this
            return Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        set(newValue) {
            let floatArray:[Float]
            let startingIndex = internalIndex(for:index)
            if colorUniformsUseAlpha {
                floatArray = newValue.toFloatArrayWithAlpha()
                uniformValues[startingIndex] = floatArray[0]
                uniformValues[startingIndex + 1] = floatArray[1]
                uniformValues[startingIndex + 2] = floatArray[2]
                uniformValues[startingIndex + 2] = floatArray[3]
            } else {
                floatArray = newValue.toFloatArray()
                uniformValues[startingIndex] = floatArray[0]
                uniformValues[startingIndex + 1] = floatArray[1]
                uniformValues[startingIndex + 2] = floatArray[2]
            }
        }
    }

    public func appendUniform(_ value:UniformConvertible) {
        uniformValues.append(contentsOf:value.toFloatArray())
        let lastOffset = uniformValueOffsets.last ?? 0
        uniformValueOffsets.append(lastOffset + value.uniformSize())
    }

    public func appendUniform(_ value:Color) {
        let lastOffset = uniformValueOffsets.last ?? 0

        if colorUniformsUseAlpha {
            uniformValues.append(contentsOf:value.toFloatArrayWithAlpha())
            uniformValueOffsets.append(lastOffset + 4)
        } else {
            uniformValues.append(contentsOf:value.toFloatArray())
            uniformValueOffsets.append(lastOffset + 3)
        }
    }

    public func restoreShaderSettings(renderEncoder:MTLRenderCommandEncoder) {
        guard (uniformValues.count > 0) else { return }
        
        let uniformBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: uniformValues,
                                                                         length: uniformValues.count * MemoryLayout<Float>.size,
                                                                         options: [])!
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
    }
}

public protocol UniformConvertible {
    func toFloatArray() -> [Float]
    func uniformSize() -> Int
}

extension Float:UniformConvertible {
    public func toFloatArray() -> [Float] {
        return [self]
    }
    
    public func uniformSize() -> Int {
        return 1
    }
}

extension Double:UniformConvertible {
    public func toFloatArray() -> [Float] {
        return [Float(self)]
    }
    
    public func uniformSize() -> Int {
        return 1
    }
}

extension Color {
    func toFloatArray() -> [Float] {
        return [self.redComponent, self.greenComponent, self.blueComponent]
    }

    func toFloatArrayWithAlpha() -> [Float] {
        return [self.redComponent, self.greenComponent, self.blueComponent, self.alphaComponent]
    }
}

extension Position:UniformConvertible {
    public func uniformSize() -> Int {
        if (self.z != nil) {
            return 3
        } else {
            return 2
        }
    }
    
    public func toFloatArray() -> [Float] {
        if let z = self.z {
            return [self.x, self.y, z]
        } else {
            return [self.x, self.y]
        }
    }
}
