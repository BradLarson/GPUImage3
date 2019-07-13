#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif
import MetalKit

public class PictureInput: ImageSource {
    public let targets = TargetContainer()
    var internalTexture:Texture?
    var hasProcessedImage:Bool = false
    var internalImage:CGImage?

    public init(image:CGImage, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        internalImage = image
    }
    
    #if canImport(UIKit)
    public convenience init(image:UIImage, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        self.init(image: image.cgImage!, smoothlyScaleOutput: smoothlyScaleOutput, orientation: orientation)
    }
    
    public convenience init(imageName:String, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        guard let image = UIImage(named:imageName) else { fatalError("No such image named: \(imageName) in your application bundle") }
        self.init(image:image, smoothlyScaleOutput:smoothlyScaleOutput, orientation:orientation)
    }
    #else
    public convenience init(image:NSImage, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        self.init(image:image.cgImage(forProposedRect:nil, context:nil, hints:nil)!, smoothlyScaleOutput:smoothlyScaleOutput, orientation:orientation)
    }
    
    public convenience init(imageName:String, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        let imageName = NSImage.Name(imageName)
        guard let image = NSImage(named:imageName) else { fatalError("No such image named: \(imageName) in your application bundle") }
        self.init(image:image.cgImage(forProposedRect:nil, context:nil, hints:nil)!, smoothlyScaleOutput:smoothlyScaleOutput, orientation:orientation)
    }
    #endif
    
    public func processImage(synchronously:Bool = false) {
        if let texture = internalTexture {
            if synchronously {
                self.updateTargetsWithTexture(texture)
                self.hasProcessedImage = true
            } else {
                DispatchQueue.global().async{
                    self.updateTargetsWithTexture(texture)
                    self.hasProcessedImage = true
                }
            }
        } else {
            let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
            if synchronously {
                do {
                    let imageTexture = try textureLoader.newTexture(cgImage:internalImage!, options: [MTKTextureLoader.Option.SRGB : false])
                    internalImage = nil
                    self.internalTexture = Texture(orientation: .portrait, texture: imageTexture)
                    self.updateTargetsWithTexture(self.internalTexture!)
                    self.hasProcessedImage = true
                } catch {
                    fatalError("Failed loading image texture")
                }
            } else {
                textureLoader.newTexture(cgImage: internalImage!, options: [MTKTextureLoader.Option.SRGB : false], completionHandler: { (possibleTexture, error) in
                    guard (error == nil) else { fatalError("Error in loading texture: \(error!)") }
                    guard let texture = possibleTexture else { fatalError("Nil texture received") }
                    self.internalImage = nil
                    self.internalTexture = Texture(orientation: .portrait, texture: texture)
                    DispatchQueue.global().async{
                        self.updateTargetsWithTexture(self.internalTexture!)
                        self.hasProcessedImage = true
                    }
                })
            }
        }
    }
    
    public func transmitPreviousImage(to target:ImageConsumer, atIndex:UInt) {
        if hasProcessedImage {
            target.newTextureAvailable(self.internalTexture!, fromSourceIndex:atIndex)
        }
    }
}
