import Foundation
import Metal

public func defaultVertexFunctionNameForInputs(_ inputCount:UInt) -> String {
    switch inputCount {
    case 1:
        return "oneInputVertex"
    default:
        return "oneInputVertex"
    }
}

open class BasicOperation: ImageProcessingOperation {
    
    public let maximumInputs: UInt
    public let targets = TargetContainer()
    public let sources = SourceContainer()
    
    public var uniformSettings = ShaderUniformSettings()

    let renderPipelineState: MTLRenderPipelineState
    let operationName: String
    
    public init(vertexFunctionName: String? = nil,
                fragmentFunctionName: String,
                numberOfInputs: UInt = 1,
                operationName: String = #file) {
        self.maximumInputs = numberOfInputs
        self.operationName = operationName
        
        let concreteVertexFunctionName = vertexFunctionName ?? defaultVertexFunctionNameForInputs(numberOfInputs)
        
        guard let vertexFunction = sharedMetalRenderingDevice.shaderLibrary.makeFunction(name: concreteVertexFunctionName) else {
            fatalError("\(operationName): could not compile vertex function \(concreteVertexFunctionName)")
        }
        
        guard let fragmentFunction = sharedMetalRenderingDevice.shaderLibrary.makeFunction(name: fragmentFunctionName) else {
            fatalError("\(operationName): could not compile fragment function \(fragmentFunctionName)")
        }
                
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
        descriptor.sampleCount = 1
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        
        do {
            renderPipelineState = try sharedMetalRenderingDevice.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError("\(operationName): could not create render pipeline state")
        }
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        // TODO: Finish implementation later
    }
    
    public func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        
        guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {return}
        
        let vertexBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: standardImageVertices,
                                                                        length: standardImageVertices.count * MemoryLayout<Float>.size,
                                                                        options: [])!
        vertexBuffer.label = "\(operationName) Vertices"
        
        let firstInputRotation = texture.orientation.rotationNeededForOrientation(.portrait)
        let firstInputTextureCoordinates = firstInputRotation.textureCoordinates()
        let textureBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: firstInputTextureCoordinates,
                                                                         length: firstInputTextureCoordinates.count * MemoryLayout<Float>.size,
                                                                         options: [])!
        textureBuffer.label = "Texture Coordinates"
        
        let outputWidth:Int
        let outputHeight:Int
        
        if firstInputRotation.flipsDimensions() {
            outputWidth = texture.texture.height
            outputHeight = texture.texture.width
        } else {
            outputWidth = texture.texture.width
            outputHeight = texture.texture.height
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                         width: outputWidth,
                                                                         height: outputHeight,
                                                                         mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let internalOutputTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("\(operationName): could not create texture")
        }
        
        let outputTexture = Texture(orientation: .portrait, texture: internalOutputTexture)
        
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = outputTexture.texture
        renderPass.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 0, 1)
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = .clear
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            fatalError("\(operationName): could not create render encoder")
        }
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
        uniformSettings.restoreShaderSettings(renderEncoder: renderEncoder)
        renderEncoder.setFragmentTexture(texture.texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        updateTargetsWithTexture(outputTexture)
    }
}
