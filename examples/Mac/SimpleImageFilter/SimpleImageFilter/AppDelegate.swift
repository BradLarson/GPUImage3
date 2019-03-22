import Cocoa
import GPUImage

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var renderView: RenderView!

    var image:PictureInput!
    var filter:SaturationAdjustment!

    @objc dynamic var filterValue = 1.0 {
        didSet {
            filter.saturation = GLfloat(filterValue)
            image.processImage()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Filtering image for saving
        let testImage = NSImage(named:NSImage.Name(rawValue: "WID-small.jpg"))!
//        let toonFilter = ToonFilter()
        let toonFilter = SaturationAdjustment()
        let inputImageForSaving = PictureInput(image:testImage)
        let pictureOutput = PictureOutput()
        pictureOutput.encodedImageAvailableCallback = { imageData in
            do {
                let fileURL = URL(fileURLWithPath:"test.png")
                try imageData.write(to:fileURL, options:.atomic)
            } catch {
                print("Couldn't write to file with error: \(error)")
            }
        }
        
        inputImageForSaving --> toonFilter --> pictureOutput
        inputImageForSaving.processImage(synchronously:true)

        // Filtering image for display
        let inputImage = NSImage(named:NSImage.Name(rawValue: "Lambeau.jpg"))!
        image = PictureInput(image:inputImage)
        
        filter = SaturationAdjustment()

        image --> filter --> renderView
        image.processImage()
    }
}

