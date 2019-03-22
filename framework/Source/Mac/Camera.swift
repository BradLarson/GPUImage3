import Foundation
import AVFoundation
import Metal

public protocol CameraDelegate {
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer)
}

public enum PhysicalCameraLocation {
    case backFacing
    case frontFacing
    
    func imageOrientation() -> ImageOrientation {
        switch self {
        case .backFacing: return .landscapeRight
        case .frontFacing: return .portrait
        }
    }
    
    func captureDevicePosition() -> AVCaptureDevice.Position {
        switch self {
        case .backFacing: return .back
        case .frontFacing: return .front
        }
    }
    
    func device() -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for:AVMediaType.video)
        for case let device in devices {
            if (device.position == self.captureDevicePosition()) {
                return device
            }
        }
        
        return AVCaptureDevice.default(for: AVMediaType.video)
    }
}

public struct CameraError: Error {
}

let initialBenchmarkFramesToIgnore = 5


public class Camera: NSObject, ImageSource, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public var location:PhysicalCameraLocation {
        didSet {
            // TODO: Swap the camera locations, framebuffers as needed
        }
    }
    public var runBenchmark:Bool = false
    public var logFPS:Bool = false
    
    public let targets = TargetContainer()
    public var delegate: CameraDelegate?
    public let captureSession:AVCaptureSession
    let inputCamera:AVCaptureDevice!
    let videoInput:AVCaptureDeviceInput!
    let videoOutput:AVCaptureVideoDataOutput!
    var videoTextureCache: CVMetalTextureCache?
    
    var supportsFullYUVRange:Bool = false
    let captureAsYUV:Bool
    let yuvConversionRenderPipelineState:MTLRenderPipelineState?
    var yuvLookupTable:[String:(Int, MTLDataType)] = [:]

    let frameRenderingSemaphore = DispatchSemaphore(value:1)
    let cameraProcessingQueue = DispatchQueue.global()
    let cameraFrameProcessingQueue = DispatchQueue(
        label: "com.sunsetlakesoftware.GPUImage.cameraFrameProcessingQueue",
        attributes: [])
    
    let framesToIgnore = 5
    var numberOfFramesCaptured = 0
    var totalFrameTimeDuringCapture:Double = 0.0
    var framesSinceLastCheck = 0
    var lastCheckTime = CFAbsoluteTimeGetCurrent()
    
    public init(sessionPreset:AVCaptureSession.Preset, cameraDevice:AVCaptureDevice? = nil, location:PhysicalCameraLocation = .backFacing, captureAsYUV:Bool = true) throws {
        self.location = location
        
        self.captureSession = AVCaptureSession()
        self.captureSession.beginConfiguration()
        
        self.captureAsYUV = captureAsYUV

        if let cameraDevice = cameraDevice {
            self.inputCamera = cameraDevice
        } else {
            if let device = location.device() {
                self.inputCamera = device
            } else {
                self.videoInput = nil
                self.videoOutput = nil
                self.inputCamera = nil
                self.yuvConversionRenderPipelineState = nil
                super.init()
                throw CameraError()
            }
        }
        
        do {
            self.videoInput = try AVCaptureDeviceInput(device:inputCamera)
        } catch {
            self.videoInput = nil
            self.videoOutput = nil
            self.yuvConversionRenderPipelineState = nil
            super.init()
            throw error
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }
        
        // Add the video frame output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        if captureAsYUV {
            supportsFullYUVRange = false
            let supportedPixelFormats = videoOutput.availableVideoPixelFormatTypes
            for currentPixelFormat in supportedPixelFormats {
                if ((currentPixelFormat as NSNumber).int32Value == Int32(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)) {
                    supportsFullYUVRange = true
                }
            }
            if (supportsFullYUVRange) {
                let (pipelineState, lookupTable) = generateRenderPipelineState(device:sharedMetalRenderingDevice, vertexFunctionName:"twoInputVertex", fragmentFunctionName:"yuvConversionFullRangeFragment", operationName:"YUVToRGB")
                self.yuvConversionRenderPipelineState = pipelineState
                self.yuvLookupTable = lookupTable
                videoOutput.videoSettings = [kCVPixelBufferMetalCompatibilityKey as String: true,
                                             kCVPixelBufferPixelFormatTypeKey as String:NSNumber(value:Int32(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange))]
            } else {
                let (pipelineState, lookupTable) = generateRenderPipelineState(device:sharedMetalRenderingDevice, vertexFunctionName:"twoInputVertex", fragmentFunctionName:"yuvConversionVideoRangeFragment", operationName:"YUVToRGB")
                self.yuvConversionRenderPipelineState = pipelineState
                self.yuvLookupTable = lookupTable
                videoOutput.videoSettings = [kCVPixelBufferMetalCompatibilityKey as String: true,
                                             kCVPixelBufferPixelFormatTypeKey as String:NSNumber(value:Int32(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange))]
            }
        } else {
            self.yuvConversionRenderPipelineState = nil
            videoOutput.videoSettings = [kCVPixelBufferMetalCompatibilityKey as String: true,
                                         kCVPixelBufferPixelFormatTypeKey as String:NSNumber(value:Int32(kCVPixelFormatType_32BGRA))]
        }
        
        if (captureSession.canAddOutput(videoOutput)) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.sessionPreset = sessionPreset
        captureSession.commitConfiguration()
        
        super.init()
        
        let _ = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, sharedMetalRenderingDevice.device, nil, &videoTextureCache)
        
        videoOutput.setSampleBufferDelegate(self, queue:cameraProcessingQueue)
    }
    
    deinit {
        cameraFrameProcessingQueue.sync {
            self.stopCapture()
            self.videoOutput?.setSampleBufferDelegate(nil, queue:nil)
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard (frameRenderingSemaphore.wait(timeout:DispatchTime.now()) == DispatchTimeoutResult.success) else { return }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let bufferWidth = CVPixelBufferGetWidth(cameraFrame)
        let bufferHeight = CVPixelBufferGetHeight(cameraFrame)
        let currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(cameraFrame, CVPixelBufferLockFlags(rawValue:CVOptionFlags(0)))
        
        cameraFrameProcessingQueue.async {
            self.delegate?.didCaptureBuffer(sampleBuffer)
            CVPixelBufferUnlockBaseAddress(cameraFrame, CVPixelBufferLockFlags(rawValue:CVOptionFlags(0)))
            
            let texture:Texture?
            if self.captureAsYUV {
                var luminanceTextureRef:CVMetalTexture? = nil
                var chrominanceTextureRef:CVMetalTexture? = nil
                // Luminance plane
                let _ = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.videoTextureCache!, cameraFrame, nil, .r8Unorm, bufferWidth, bufferHeight, 0, &luminanceTextureRef)
                // Chrominance plane
                let _ = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.videoTextureCache!, cameraFrame, nil, .rg8Unorm, bufferWidth / 2, bufferHeight / 2, 1, &chrominanceTextureRef)

                if let concreteLuminanceTextureRef = luminanceTextureRef, let concreteChrominanceTextureRef = chrominanceTextureRef,
                    let luminanceTexture = CVMetalTextureGetTexture(concreteLuminanceTextureRef), let chrominanceTexture = CVMetalTextureGetTexture(concreteChrominanceTextureRef) {
                    let outputTexture = Texture(device:sharedMetalRenderingDevice.device, orientation:self.location.imageOrientation(), width:bufferWidth, height:bufferHeight)
                    
                    let conversionMatrix:Matrix3x3
                    if (self.supportsFullYUVRange) {
                        conversionMatrix = colorConversionMatrix601FullRangeDefault
                    } else {
                        conversionMatrix = colorConversionMatrix601Default
                    }
                    
                    convertYUVToRGB(pipelineState:self.yuvConversionRenderPipelineState!, lookupTable:self.yuvLookupTable,
                                    luminanceTexture:Texture(orientation: self.location.imageOrientation(), texture:luminanceTexture),
                                    chrominanceTexture:Texture(orientation: self.location.imageOrientation(), texture:chrominanceTexture),
                                    resultTexture:outputTexture, colorConversionMatrix:conversionMatrix)
                    texture = outputTexture
                } else {
                    texture = nil
                }
            } else {
                var textureRef:CVMetalTexture? = nil
                let _ = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.videoTextureCache!, cameraFrame, nil, .bgra8Unorm, bufferWidth, bufferHeight, 0, &textureRef)
                if let concreteTexture = textureRef, let cameraTexture = CVMetalTextureGetTexture(concreteTexture) {
                    texture = Texture(orientation: self.location.imageOrientation(), texture: cameraTexture)
                } else {
                    texture = nil
                }
            }
            
            if texture != nil {
                self.updateTargetsWithTexture(texture!)
            }

            if self.runBenchmark {
                self.numberOfFramesCaptured += 1
                if (self.numberOfFramesCaptured > initialBenchmarkFramesToIgnore) {
                    let currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime)
                    self.totalFrameTimeDuringCapture += currentFrameTime
                    print("Average frame time : \(1000.0 * self.totalFrameTimeDuringCapture / Double(self.numberOfFramesCaptured - initialBenchmarkFramesToIgnore)) ms")
                    print("Current frame time : \(1000.0 * currentFrameTime) ms")
                }
            }
            
            if self.logFPS {
                if ((CFAbsoluteTimeGetCurrent() - self.lastCheckTime) > 1.0) {
                    self.lastCheckTime = CFAbsoluteTimeGetCurrent()
                    print("FPS: \(self.framesSinceLastCheck)")
                    self.framesSinceLastCheck = 0
                }
                
                self.framesSinceLastCheck += 1
            }
            
            self.frameRenderingSemaphore.signal()
        }
    }
    
    public func startCapture() {

        let _ = frameRenderingSemaphore.wait(timeout:DispatchTime.distantFuture)
        self.numberOfFramesCaptured = 0
        self.totalFrameTimeDuringCapture = 0
        self.frameRenderingSemaphore.signal()

        if (!captureSession.isRunning) {
            captureSession.startRunning()
        }
    }
    
    public func stopCapture() {
        if (captureSession.isRunning) {
            let _ = frameRenderingSemaphore.wait(timeout:DispatchTime.distantFuture)

            captureSession.stopRunning()
            self.frameRenderingSemaphore.signal()
        }
    }
    
    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        // Not needed for camera
    }
}
