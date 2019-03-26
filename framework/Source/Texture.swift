import Foundation
import Metal
#if os(iOS)
import UIKit
#endif

public enum TextureTimingStyle {
    case stillImage
    case videoFrame(timestamp:Timestamp)
    
    func isTransient() -> Bool {
        switch self {
        case .stillImage: return false
        case .videoFrame: return true
        }
    }
    
    var timestamp:Timestamp? {
        get {
            switch self {
            case .stillImage: return nil
            case let .videoFrame(timestamp): return timestamp
            }
        }
    }
}

public class Texture {
    public var timingStyle: TextureTimingStyle
    public var orientation: ImageOrientation
    
    public let texture: MTLTexture
    
    public init(orientation: ImageOrientation, texture: MTLTexture, timingStyle: TextureTimingStyle  = .stillImage) {
        self.orientation = orientation
        self.texture = texture
        self.timingStyle = timingStyle
    }
    
    public init(device:MTLDevice, orientation: ImageOrientation, pixelFormat: MTLPixelFormat = .bgra8Unorm, width: Int, height: Int, mipmapped:Bool = false, timingStyle: TextureTimingStyle  = .stillImage) {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                         width: width,
                                                                         height: height,
                                                                         mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let newTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: textureDescriptor) else {
            fatalError("Could not create texture of size: (\(width), \(height))")
        }

        self.orientation = orientation
        self.texture = newTexture
        self.timingStyle = timingStyle
    }
}

extension Texture {
    func textureCoordinates(for outputOrientation:ImageOrientation, normalized:Bool) -> [Float] {
        let inputRotation = self.orientation.rotationNeeded(for:outputOrientation)

        let xLimit:Float
        let yLimit:Float
        if normalized {
            xLimit = 1.0
            yLimit = 1.0
        } else {
            xLimit = Float(self.texture.width)
            yLimit = Float(self.texture.height)
        }
        
        switch inputRotation {
        case .noRotation: return [0.0, 0.0, xLimit, 0.0, 0.0, yLimit, xLimit, yLimit]
        case .rotateCounterclockwise: return [0.0, yLimit, 0.0, 0.0, xLimit, yLimit, xLimit, 0.0]
        case .rotateClockwise: return [xLimit, 0.0, xLimit, yLimit, 0.0, 0.0, 0.0, yLimit]
        case .rotate180: return [xLimit, yLimit, 0.0, yLimit, xLimit, 0.0, 0.0, 0.0]
        case .flipHorizontally: return [xLimit, 0.0, 0.0, 0.0, xLimit, yLimit, 0.0, yLimit]
        case .flipVertically: return [0.0, yLimit, xLimit, yLimit, 0.0, 0.0, xLimit, 0.0]
        case .rotateClockwiseAndFlipVertically: return [0.0, 0.0, 0.0, yLimit, xLimit, 0.0, xLimit, yLimit]
        case .rotateClockwiseAndFlipHorizontally: return [xLimit, yLimit, xLimit, 0.0, 0.0, yLimit, 0.0, 0.0]
        }
    }
    
    func aspectRatio(for rotation:Rotation) -> Float {
        // TODO: Figure out why my logic was failing on this
        return Float(self.texture.height) / Float(self.texture.width)
//        if rotation.flipsDimensions() {
//            return Float(self.texture.width) / Float(self.texture.height)
//        } else {
//            return Float(self.texture.height) / Float(self.texture.width)
//        }
    }

    
//    func croppedTextureCoordinates(offsetFromOrigin:Position, cropSize:Size) -> [Float] {
//        let minX = offsetFromOrigin.x
//        let minY = offsetFromOrigin.y
//        let maxX = offsetFromOrigin.x + cropSize.width
//        let maxY = offsetFromOrigin.y + cropSize.height
//
//        switch self {
//        case .noRotation: return [minX, minY, maxX, minY, minX, maxY, maxX, maxY]
//        case .rotateCounterclockwise: return [minX, maxY, minX, minY, maxX, maxY, maxX, minY]
//        case .rotateClockwise: return [maxX, minY, maxX, maxY, minX, minY, minX, maxY]
//        case .rotate180: return [maxX, maxY, minX, maxY, maxX, minY, minX, minY]
//        case .flipHorizontally: return [maxX, minY, minX, minY, maxX, maxY, minX, maxY]
//        case .flipVertically: return [minX, maxY, maxX, maxY, minX, minY, maxX, minY]
//        case .rotateClockwiseAndFlipVertically: return [minX, minY, minX, maxY, maxX, minY, maxX, maxY]
//        case .rotateClockwiseAndFlipHorizontally: return [maxX, maxY, maxX, minY, minX, maxY, minX, minY]
//        }
//    }
}

extension Texture {
    func cgImage() -> CGImage {
        // Flip and swizzle image
        guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else { fatalError("Could not create command buffer on image rendering.")}
        let outputTexture = Texture(device:sharedMetalRenderingDevice.device, orientation:self.orientation, width:self.texture.width, height:self.texture.height)
        commandBuffer.renderQuad(pipelineState:sharedMetalRenderingDevice.colorSwizzleRenderState, uniformSettings:nil, inputTextures:[0:self], useNormalizedTextureCoordinates:true, outputTexture:outputTexture)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // Grab texture bytes, generate CGImageRef from them
        let imageByteSize = texture.height * texture.width * 4
        let outputBytes = UnsafeMutablePointer<UInt8>.allocate(capacity:imageByteSize)
        outputTexture.texture.getBytes(outputBytes, bytesPerRow: MemoryLayout<UInt8>.size * texture.width * 4, bytesPerImage:0, from: MTLRegionMake2D(0, 0, texture.width, texture.height), mipmapLevel: 0, slice: 0)
        
        guard let dataProvider = CGDataProvider(dataInfo:nil, data:outputBytes, size:imageByteSize, releaseData:dataProviderReleaseCallback) else {fatalError("Could not create CGDataProvider")}
        let defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB()
        return CGImage(width:texture.width, height:texture.height, bitsPerComponent:8, bitsPerPixel:32, bytesPerRow:4 * texture.width, space:defaultRGBColorSpace, bitmapInfo:CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider:dataProvider, decode:nil, shouldInterpolate:false, intent:.defaultIntent)!
    }
}

func dataProviderReleaseCallback(_ context:UnsafeMutableRawPointer?, data:UnsafeRawPointer, size:Int) {
    data.deallocate()
}
