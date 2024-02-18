import Foundation
import Metal
import MetalPerformanceShaders

public let sharedMetalRenderingDevice = MetalRenderingDevice()

public class MetalRenderingDevice {
    // MTLDevice
    // MTLCommandQueue

    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let shaderLibrary: MTLLibrary
    public let metalPerformanceShadersAreSupported: Bool

    lazy var passthroughRenderState: MTLRenderPipelineState = {
        let (pipelineState, _, _) = generateRenderPipelineState(
            device: self, vertexFunctionName: "oneInputVertex",
            fragmentFunctionName: "passthroughFragment", operationName: "Passthrough")
        return pipelineState
    }()

    lazy var colorSwizzleRenderState: MTLRenderPipelineState = {
        let (pipelineState, _, _) = generateRenderPipelineState(
            device: self, vertexFunctionName: "oneInputVertex",
            fragmentFunctionName: "colorSwizzleFragment", operationName: "ColorSwizzle")
        return pipelineState
    }()

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create Metal Device")
        }
        self.device = device

        guard let queue = self.device.makeCommandQueue() else {
            fatalError("Could not create command queue")
        }
        self.commandQueue = queue

        if #available(iOS 9, macOS 10.13, *) {
            self.metalPerformanceShadersAreSupported = MPSSupportsMTLDevice(device)
        } else {
            self.metalPerformanceShadersAreSupported = false
        }

        guard let defaultLibrary = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            fatalError("Could not load library")
        }

        self.shaderLibrary = defaultLibrary
    }
}
