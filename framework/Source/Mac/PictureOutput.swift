import Metal
import Cocoa

public enum PictureFileFormat {
    case png
    case jpeg
}

public class PictureOutput: ImageConsumer {
    public var encodedImageAvailableCallback:((Data) -> ())?
    public var encodedImageFormat:PictureFileFormat = .png
    public var imageAvailableCallback:((NSImage) -> ())?
    public var onlyCaptureNextFrame:Bool = true
    
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
        if let imageCallback = imageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            let image = NSImage(cgImage:cgImageFromBytes, size:NSZeroSize)
            
            imageCallback(image)
            
            if onlyCaptureNextFrame {
                imageAvailableCallback = nil
            }
        }
        
        if let imageCallback = encodedImageAvailableCallback {
            let cgImageFromBytes = texture.cgImage()
            let bitmapRepresentation = NSBitmapImageRep(cgImage:cgImageFromBytes)
            let imageData:Data
            switch encodedImageFormat {
                case .png: imageData = bitmapRepresentation.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey(rawValue: ""):""])!
                case .jpeg: imageData = bitmapRepresentation.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey(rawValue: ""):""])!
            }

            imageCallback(imageData)
            
            if onlyCaptureNextFrame {
                encodedImageAvailableCallback = nil
            }
        }
    }
}

public extension ImageSource {
    public func saveNextFrameToURL(_ url:URL, format:PictureFileFormat) {
        let pictureOutput = PictureOutput()
        pictureOutput.saveNextFrameToURL(url, format:format)
        self --> pictureOutput
    }
}

public extension NSImage {
    public func filterWithOperation<T:ImageProcessingOperation>(_ operation:T) -> NSImage {
        return filterWithPipeline{input, output in
            input --> operation --> output
        }
    }

    public func filterWithPipeline(_ pipeline:(PictureInput, PictureOutput) -> ()) -> NSImage {
        let picture = PictureInput(image:self)
        var outputImage:NSImage?
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
