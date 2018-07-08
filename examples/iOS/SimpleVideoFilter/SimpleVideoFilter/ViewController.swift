import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet weak var renderView: RenderView!
    var camera:Camera!
    var operation:BasicOperation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            operation = BasicOperation(fragmentFunctionName: "passthroughFragment")
            camera = try Camera(sessionPreset: .vga640x480)
            camera.runBenchmark = true
            camera --> operation --> renderView
            camera.startCapture()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

