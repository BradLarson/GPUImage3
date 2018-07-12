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
        renderPipelineState = generateRenderPipelineState(device:sharedMetalRenderingDevice, vertexFunctionName:concreteVertexFunctionName, fragmentFunctionName:fragmentFunctionName, operationName:operationName)
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        // TODO: Finish implementation later
    }
    
    public func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {return}
        
        let outputWidth:Int
        let outputHeight:Int
        
        if texture.orientation.rotationNeededForOrientation(.portrait).flipsDimensions() {
            outputWidth = texture.texture.height
            outputHeight = texture.texture.width
        } else {
            outputWidth = texture.texture.width
            outputHeight = texture.texture.height
        }
        
        let outputTexture = Texture(device:sharedMetalRenderingDevice.device, orientation: .portrait, width: outputWidth, height: outputHeight)
        
        commandBuffer.renderQuad(pipelineState: renderPipelineState, uniformSettings: uniformSettings, inputTexture: texture, outputTexture: outputTexture)
        commandBuffer.commit()

        updateTargetsWithTexture(outputTexture)
    }
}
