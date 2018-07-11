import UIKit

public class PictureInput: ImageSource {
    public let targets = TargetContainer()
    
    public init(image:CGImage, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
    }
    
    public convenience init(image:UIImage, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        self.init(image:image.cgImage!, smoothlyScaleOutput:smoothlyScaleOutput, orientation:orientation)
    }
    
    public convenience init(imageName:String, smoothlyScaleOutput:Bool = false, orientation:ImageOrientation = .portrait) {
        guard let image = UIImage(named:imageName) else { fatalError("No such image named: \(imageName) in your application bundle") }
        self.init(image:image.cgImage!, smoothlyScaleOutput:smoothlyScaleOutput, orientation:orientation)
    }
    
    public func processImage(synchronously:Bool = false) {
    }
    
    public func transmitPreviousImage(to target:ImageConsumer, atIndex:UInt) {
    }
}
