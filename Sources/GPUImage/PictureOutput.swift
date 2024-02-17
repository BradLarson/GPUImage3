#if canImport(UIKit)
import UIKit
public typealias PlatformImageType = UIImage
#else
import Cocoa
public typealias PlatformImageType = NSImage
#endif
import Metal

public enum PictureFileFormat {
    case png
    case jpeg
}

public class PictureOutput: ImageConsumer {
    public var encodedImageAvailableCallback:((Data) -> ())?
    public var encodedImageFormat:PictureFileFormat = .png
    public var imageAvailableCallback:((PlatformImageType) -> ())?
    public var onlyCaptureNextFrame:Bool = true
    public var keepImageAroundForSynchronousCapture:Bool = false
    var storedTexture:Texture?
    
    public let sources = SourceContainer()
    public let maximumInputs:UInt = 1
    var url:URL!
    
    public init() {
    }
    
    deinit {
    }
    
    public func saveNextFrameToURL(_ url:URL, format:PictureFileFormat) {
        onlyCaptureNextFrame = true
        encodedImageFormat = format
        self.url = url // Create an intentional short-term retain cycle to prevent deallocation before next frame is captured
        encodedImageAvailableCallback = {imageData in
            do {
                try imageData.write(to: self.url, options:.atomic)
            } catch {
                // TODO: Handle this better
                print("WARNING: Couldn't save image with error:\(error)")
            }
        }
    }
    
    public func newTextureAvailable(_ texture:Texture, fromSourceIndex:UInt) {
        if keepImageAroundForSynchronousCapture {
//            storedTexture?.unlock()
            storedTexture = texture
        }
        
        if let imageCallback = imageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            
            // TODO: Let people specify orientations
#if canImport(UIKit)
            let image = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)
#else
            let image = NSImage(cgImage:cgImageFromBytes, size:NSZeroSize)
#endif

            imageCallback(image)
            
            if onlyCaptureNextFrame {
                imageAvailableCallback = nil
            }
        }
        
        if let imageCallback = encodedImageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            
            let imageData:Data
#if canImport(UIKit)
            let image = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)
            switch encodedImageFormat {
            case .png: imageData = image.pngData()! // TODO: Better error handling here
                case .jpeg: imageData = image.jpegData(compressionQuality: 0.8)! // TODO: Be able to set image quality
            }
#else
            let bitmapRepresentation = NSBitmapImageRep(cgImage:cgImageFromBytes)
            switch encodedImageFormat {
                case .png: imageData = bitmapRepresentation.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey(rawValue: ""):""])!
                case .jpeg: imageData = bitmapRepresentation.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey(rawValue: ""):""])!
            }
#endif
            imageCallback(imageData)
            
            if onlyCaptureNextFrame {
                encodedImageAvailableCallback = nil
            }
        }
    }
    
//    public func synchronousImageCapture() -> UIImage {
//        var outputImage:UIImage!
//        sharedImageProcessingContext.runOperationSynchronously{
//            guard let currentFramebuffer = storedFramebuffer else { fatalError("Synchronous access requires keepImageAroundForSynchronousCapture to be set to true") }
//            
//            let cgImageFromBytes = cgImageFromFramebuffer(currentFramebuffer)
//            outputImage = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)
//        }
//        
//        return outputImage
//    }
}

public extension ImageSource {
    func saveNextFrameToURL(_ url:URL, format:PictureFileFormat) {
        let pictureOutput = PictureOutput()
        pictureOutput.saveNextFrameToURL(url, format:format)
        self --> pictureOutput
    }
}

public extension PlatformImageType {
    func filterWithOperation<T:ImageProcessingOperation>(_ operation:T) -> PlatformImageType {
        return filterWithPipeline{input, output in
            input --> operation --> output
        }
    }
    
    func filterWithPipeline(_ pipeline:(PictureInput, PictureOutput) -> ()) -> PlatformImageType {
        let picture = PictureInput(image:self)
        var outputImage:PlatformImageType?
        let pictureOutput = PictureOutput()
        pictureOutput.onlyCaptureNextFrame = true
        pictureOutput.imageAvailableCallback = {image in
            outputImage = image
        }
        pipeline(picture, pictureOutput)
        picture.processImage(synchronously:true)
        return outputImage!
    }
}
