import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet weak var renderView: RenderView!

    var picture:PictureInput!
    var filter:SaturationAdjustment!
    var customFilter: CustomBrightnessAdjustment!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Filtering image for saving
        let testImage = UIImage(named:"WID-small.jpg")!
        let toonFilter = ToonFilter()
        let filteredImage = testImage.filterWithOperation(toonFilter)
        
        let pngImage = UIImagePNGRepresentation(filteredImage)!
        do {
            let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            let fileURL = URL(string:"test.png", relativeTo:documentsDir)!
            try pngImage.write(to:fileURL, options:.atomic)
        } catch {
            print("Couldn't write to file with error: \(error)")
        }
        
        // Filtering image for display
        picture = PictureInput(image:UIImage(named:"WID-small.jpg")!)
        filter = SaturationAdjustment()
        // demo for define custom filter outside GPUImage framework bundle
        customFilter = CustomBrightnessAdjustment()
        customFilter.brightness = 0.5
        picture --> filter --> customFilter --> renderView
        picture.processImage()
    }
}

