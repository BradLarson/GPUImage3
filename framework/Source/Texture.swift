import Foundation
import Metal

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
    public var timingStyle: TextureTimingStyle = .stillImage
    public var orientation: ImageOrientation
    
    public let texture: MTLTexture
    
    public init(orientation: ImageOrientation, texture: MTLTexture) {
        self.orientation = orientation
        self.texture = texture
    }
    
    public init(device:MTLDevice, orientation: ImageOrientation, pixelFormat: MTLPixelFormat = .bgra8Unorm, width: Int, height: Int, mipmapped:Bool = false) {
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
    }
}

extension Rotation {
    func textureCoordinates() -> [Float] {
        switch self {
        case .noRotation: return [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
        case .rotateCounterclockwise: return [0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0]
        case .rotateClockwise: return [1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0]
        case .rotate180: return [1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0]
        case .flipHorizontally: return [1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0]
        case .flipVertically: return [0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0]
        case .rotateClockwiseAndFlipVertically: return [0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0]
        case .rotateClockwiseAndFlipHorizontally: return [1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0]
        }
    }
    
    func croppedTextureCoordinates(offsetFromOrigin:Position, cropSize:Size) -> [Float] {
        let minX = offsetFromOrigin.x
        let minY = offsetFromOrigin.y
        let maxX = offsetFromOrigin.x + cropSize.width
        let maxY = offsetFromOrigin.y + cropSize.height
        
        switch self {
        case .noRotation: return [minX, minY, maxX, minY, minX, maxY, maxX, maxY]
        case .rotateCounterclockwise: return [minX, maxY, minX, minY, maxX, maxY, maxX, minY]
        case .rotateClockwise: return [maxX, minY, maxX, maxY, minX, minY, minX, maxY]
        case .rotate180: return [maxX, maxY, minX, maxY, maxX, minY, minX, minY]
        case .flipHorizontally: return [maxX, minY, minX, minY, maxX, maxY, minX, maxY]
        case .flipVertically: return [minX, maxY, maxX, maxY, minX, minY, maxX, minY]
        case .rotateClockwiseAndFlipVertically: return [minX, minY, minX, maxY, maxX, minY, maxX, maxY]
        case .rotateClockwiseAndFlipHorizontally: return [maxX, maxY, maxX, minY, minX, maxY, minX, minY]
        }
    }
}
