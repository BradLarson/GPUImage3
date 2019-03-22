import UIKit
import Metal

public enum PictureFileFormat {
    case png
    case jpeg
}

public class PictureOutput: ImageConsumer {
    public var encodedImageAvailableCallback:((Data) -> ())?
    public var encodedImageFormat:PictureFileFormat = .png
    public var imageAvailableCallback:((UIImage) -> ())?
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
            let image = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)
            
            imageCallback(image)
            
            if onlyCaptureNextFrame {
                imageAvailableCallback = nil
            }
        }
        
        if let imageCallback = encodedImageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            let image = UIImage(cgImage:cgImageFromBytes, scale:1.0, orientation:.up)
            let imageData:Data
            switch encodedImageFormat {
                case .png: imageData = UIImagePNGRepresentation(image)! // TODO: Better error handling here
                case .jpeg: imageData = UIImageJPEGRepresentation(image, 0.8)! // TODO: Be able to set image quality
            }
            
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
    public func saveNextFrameToURL(_ url:URL, format:PictureFileFormat) {
        let pictureOutput = PictureOutput()
        pictureOutput.saveNextFrameToURL(url, format:format)
        self --> pictureOutput
    }
}

public extension UIImage {
    public func filterWithOperation<T:ImageProcessingOperation>(_ operation:T) -> UIImage {
        return filterWithPipeline{input, output in
            input --> operation --> output
        }
    }
    
    public func filterWithPipeline(_ pipeline:(PictureInput, PictureOutput) -> ()) -> UIImage {
        let picture = PictureInput(image:self)
        var outputImage:UIImage?
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
