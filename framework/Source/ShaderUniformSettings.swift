import Foundation
import Metal

public class ShaderUniformSettings {
    private var uniformValues:[Float] = []
    private var uniformValueOffsets:[Int] = []
    public var colorUniformsUseAlpha:Bool = false
    let shaderUniformSettingsQueue = DispatchQueue(
        label: "com.sunsetlakesoftware.GPUImage.shaderUniformSettings",
        attributes: [])
    

    private func internalIndex(for index:Int) -> Int {
        if (index == 0) {
            return 0
        } else {
            return uniformValueOffsets[index - 1]
        }
    }
    
    public subscript(index:Int) -> Float {
        get { return uniformValues[internalIndex(for:index)]}
        set(newValue) {
            shaderUniformSettingsQueue.async {
                self.uniformValues[self.internalIndex(for:index)] = newValue
            }
        }
    }

    public subscript(index:Int) -> Color {
        get {
            // TODO: Fix this
            return Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        set(newValue) {
            shaderUniformSettingsQueue.async {
                let floatArray:[Float]
                let startingIndex = self.internalIndex(for:index)
                if self.colorUniformsUseAlpha {
                    floatArray = newValue.toFloatArrayWithAlpha()
                    self.uniformValues[startingIndex] = floatArray[0]
                    self.uniformValues[startingIndex + 1] = floatArray[1]
                    self.uniformValues[startingIndex + 2] = floatArray[2]
                    self.uniformValues[startingIndex + 2] = floatArray[3]
                } else {
                    floatArray = newValue.toFloatArray()
                    self.uniformValues[startingIndex] = floatArray[0]
                    self.uniformValues[startingIndex + 1] = floatArray[1]
                    self.uniformValues[startingIndex + 2] = floatArray[2]
                }
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
        shaderUniformSettingsQueue.sync {
            guard (uniformValues.count > 0) else { return }
            let uniformBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: uniformValues,
                                                                             length: uniformValues.count * MemoryLayout<Float>.size,
                                                                             options: [])!
            renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        }
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
