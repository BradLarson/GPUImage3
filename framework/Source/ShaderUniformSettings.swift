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

    public subscript(index:Int) -> Position {
        get {
            // TODO: Fix this
            return Position(0.0, 0.0)
        }
        set(newValue) {
            shaderUniformSettingsQueue.async {
                let floatArray = newValue.toFloatArray()
                var currentIndex = self.internalIndex(for:index)
                for floatValue in floatArray {
                    self.uniformValues[currentIndex] = floatValue
                    currentIndex += 1
                }
            }
        }
    }

    public subscript(index:Int) -> Matrix3x3 {
        get {
            // TODO: Fix this
            return Matrix3x3.identity
        }
        set(newValue) {
            shaderUniformSettingsQueue.async {
                let floatArray = newValue.toFloatArray()
                var currentIndex = self.internalIndex(for:index)
                for floatValue in floatArray {
                    self.uniformValues[currentIndex] = floatValue
                    currentIndex += 1
                }
            }
        }
    }

    public subscript(index:Int) -> Matrix4x4 {
        get {
            // TODO: Fix this
            return Matrix4x4.identity
        }
        set(newValue) {
            shaderUniformSettingsQueue.async {
                let floatArray = newValue.toFloatArray()
                var currentIndex = self.internalIndex(for:index)
                for floatValue in floatArray {
                    self.uniformValues[currentIndex] = floatValue
                    currentIndex += 1
                }
            }
        }
    }
    
    func alignPackingForOffset(uniformSize:Int, lastOffset:Int) -> Int {
        let floatAlignment = lastOffset % 4
        if (uniformSize > 1) && (floatAlignment != 0) {
            let paddingToAlignment = 4 - floatAlignment
            uniformValues.append(contentsOf:[Float](repeating:0.0, count:paddingToAlignment))
            uniformValueOffsets[uniformValueOffsets.count - 1] = lastOffset + paddingToAlignment
            return lastOffset + paddingToAlignment
        } else {
            return lastOffset
        }
    }

    public func appendUniform(_ value:UniformConvertible) {
        let lastOffset = alignPackingForOffset(uniformSize:value.uniformSize(), lastOffset:uniformValueOffsets.last ?? 0)
        
        uniformValues.append(contentsOf:value.toFloatArray())
        uniformValueOffsets.append(lastOffset + value.uniformSize())
    }

    public func appendUniform(_ value:Color) {
        let colorSize = 4
        let lastOffset = alignPackingForOffset(uniformSize:colorSize, lastOffset:uniformValueOffsets.last ?? 0)

        if colorUniformsUseAlpha {
            uniformValues.append(contentsOf:value.toFloatArrayWithAlpha())
        } else {
            uniformValues.append(contentsOf:value.toFloatArray())
        }
        uniformValueOffsets.append(lastOffset + colorSize)
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
        return [self.redComponent, self.greenComponent, self.blueComponent, 0.0]
    }

    func toFloatArrayWithAlpha() -> [Float] {
        return [self.redComponent, self.greenComponent, self.blueComponent, self.alphaComponent]
    }
}

extension Position:UniformConvertible {
    public func uniformSize() -> Int {
        return 4
    }
    
    public func toFloatArray() -> [Float] {
        if let z = self.z {
            return [self.x, self.y, z, 0.0]
        } else {
            return [self.x, self.y, 0.0, 0.0]
        }
    }
}

extension Matrix3x3:UniformConvertible {
    public func uniformSize() -> Int {
        return 12
    }
    
    public func toFloatArray() -> [Float] {
        // Row major, with zero-padding
        return [m11, m12, m13, 0.0, m21, m22, m23, 0.0, m31, m32, m33, 0.0]
//        return [m11, m12, m13, m21, m22, m23, m31, m32, m33]
    }
}

extension Matrix4x4:UniformConvertible {
    public func uniformSize() -> Int {
        return 16
    }
    
    public func toFloatArray() -> [Float] {
        // Row major
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
//        return [m11, m21, m31, m41, m12, m22, m32, m42, m13, m23, m33, m43, m14, m24, m34, m44]
    }
}

