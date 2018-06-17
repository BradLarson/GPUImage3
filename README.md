# GPUImage 3 #

<div style="float: right"><img src="http://sunsetlakesoftware.com/sites/default/files/GPUImageLogo.png" /></div>

Brad Larson

http://www.sunsetlakesoftware.com

[@bradlarson](http://twitter.com/bradlarson)

contact@sunsetlakesoftware.com

Janie Clayton

http://redqueengraphics.com

[@RedQueenCoder](https://twitter.com/RedQueenCoder)

## Overview ##

GPUImage 3 is the third generation of the <a href="https://github.com/BradLarson/GPUImage">GPUImage framework</a>, an open source project for performing GPU-accelerated image and video processing on Mac and iOS. The original GPUImage framework was written in Objective-C and targeted Mac and iOS, the second iteration rewritten in Swift using OpenGL to target Mac, iOS, and Linux, and now this third generation is redesigned to use Metal in place of OpenGL.

The objective of the framework is to make it as easy as possible to set up and perform realtime video processing or machine vision against image or video sources. [Something about Metal here]

## License ##

BSD-style, with the full license available with the framework in License.txt.

## Technical requirements ##

- Swift 4
- Xcode 9.0 on Mac or iOS
- iOS: 8.0 or higher (Swift is supported on 7.0, but not Mac-style frameworks)
- OSX: 10.9 or higher

## General architecture ##

The framework relies on the concept of a processing pipeline, where image sources are targeted at image consumers, and so on down the line until images are output to the screen, to image files, to raw data, or to recorded movies. Cameras, movies, still images, and raw data can be inputs into this pipeline. Arbitrarily complex processing operations can be built from a combination of a series of smaller operations.

This is an object-oriented framework, with classes that encapsulate inputs, processing operations, and outputs. The processing operations use Metal vertex and fragment shaders to perform their image manipulations on the GPU.

Examples for usage of the framework in common applications are shown below.

## Using GPUImage in a Mac or iOS application ##

To add the GPUImage framework to your Mac or iOS application, either drag the GPUImage.xcodeproj project into your application's project or add it via File | Add Files To...

After that, go to your project's Build Phases and add GPUImage_iOS or GPUImage_macOS as a Target Dependency. Add it to the Link Binary With Libraries phase. Add a new Copy Files build phase, set its destination to Frameworks, and add the upper GPUImage.framework (for Mac) or lower GPUImage.framework (for iOS) to that. That last step will make sure the framework is deployed in your application bundle. 

In any of your Swift files that reference GPUImage classes, simply add

```swift
import GPUImage
```

and you should be ready to go.

Note that you may need to build your project once to parse and build the GPUImage framework in order for Xcode to stop warning you about the framework and its classes being missing.

## Performing common tasks ##

### Filtering live video ###

To filter live video from a Mac or iOS camera, you can write code like the following:

```swift
do {
    camera = try Camera(sessionPreset:AVCaptureSessionPreset640x480)
    filter = SaturationAdjustment()
    camera --> filter --> renderView
    camera.startCapture()
} catch {
    fatalError("Could not initialize rendering pipeline: \(error)")
}
```

where renderView is an instance of RenderView that you've placed somewhere in your view hierarchy. The above instantiates a 640x480 camera instance, creates a saturation filter, and directs camera frames to be processed through the saturation filter on their way to the screen. startCapture() initiates the camera capture process.

The --> operator chains an image source to an image consumer, and many of these can be chained in the same line.

### Capturing and filtering a still photo ###

Functionality not completed.

### Capturing an image from video ###

(Not currently available on Linux.)

To capture a still image from live video, you need to set a callback to be performed on the next frame of video that is processed. The easiest way to do this is to use the convenience extension to capture, encode, and save a file to disk:

```swift
filter.saveNextFrameToURL(url, format:.PNG)
```

Under the hood, this creates a PictureOutput instance, attaches it as a target to your filter, sets the PictureOutput's encodedImageFormat to PNG files, and sets the encodedImageAvailableCallback to a closure that takes in the data for the filtered image and saves it to a URL.

You can set this up manually to get the encoded image data (as NSData):

```swift
let pictureOutput = PictureOutput()
pictureOutput.encodedImageFormat = .JPEG
pictureOutput.encodedImageAvailableCallback = {imageData in
    // Do something with the NSData
}
filter --> pictureOutput
```

You can also get the filtered image in a platform-native format (NSImage, UIImage) by setting the imageAvailableCallback:

```swift
let pictureOutput = PictureOutput()
pictureOutput.encodedImageFormat = .JPEG
pictureOutput.imageAvailableCallback = {image in
    // Do something with the image
}
filter --> pictureOutput
```

### Processing a still image ###

(Not currently available on Linux.)

There are a few different ways to approach filtering an image. The easiest are the convenience extensions to UIImage or NSImage that let you filter that image and return a UIImage or NSImage:

```swift
let testImage = UIImage(named:"WID-small.jpg")!
let toonFilter = SmoothToonFilter()
let filteredImage = testImage.filterWithOperation(toonFilter)
```

for a more complex pipeline:

```swift
let testImage = UIImage(named:"WID-small.jpg")!
let toonFilter = SmoothToonFilter()
let luminanceFilter = Luminance()
let filteredImage = testImage.filterWithPipeline{input, output in
    input --> toonFilter --> luminanceFilter --> output
}
```

One caution: if you want to display an image to the screen or repeatedly filter an image, don't use these methods. Going to and from Core Graphics adds a lot of overhead. Instead, I recommend manually setting up a pipeline and directing it to a RenderView for display in order to keep everything on the GPU.

Both of these convenience methods wrap several operations. To feed a picture into a filter pipeline, you instantiate a PictureInput. To capture a picture from the pipeline, you use a PictureOutput. To manually set up processing of an image, you can use something like the following:

```swift
let toonFilter = SmoothToonFilter()
let testImage = UIImage(named:"WID-small.jpg")!
let pictureInput = PictureInput(image:testImage)
let pictureOutput = PictureOutput()
pictureOutput.imageAvailableCallback = {image in
    // Do something with image
}
pictureInput --> toonFilter --> pictureOutput
pictureInput.processImage(synchronously:true)
```

In the above, the imageAvailableCallback will be triggered right at the processImage() line. If you want the image processing to be done asynchronously, leave out the synchronously argument in the above.

### Filtering and re-encoding a movie ###

To filter an existing movie file, you can write code like the following:

```swift

do {
	let bundleURL = Bundle.main.resourceURL!
	let movieURL = URL(string:"sample_iPod.m4v", relativeTo:bundleURL)!
	movie = try MovieInput(url:movieURL, playAtActualSpeed:true)
    filter = SaturationAdjustment()
    movie --> filter --> renderView
    movie.start()
} catch {
    fatalError("Could not initialize rendering pipeline: \(error)")
}
```

where renderView is an instance of RenderView that you've placed somewhere in your view hierarchy. The above loads a movie named "sample_iPod.m4v" from the application's bundle, creates a saturation filter, and directs movie frames to be processed through the saturation filter on their way to the screen. start() initiates the movie playback.

### Writing a custom image processing operation ###

The framework uses a series of protocols to define types that can output images to be processed, take in an image for processing, or do both. These are the ImageSource, ImageConsumer, and ImageProcessingOperation protocols, respectively. Any type can comply to these, but typically classes are used.

Many common filters and other image processing operations can be described as subclasses of the BasicOperation class. BasicOperation provides much of the internal code required for taking in an image frame from one or more inputs, rendering a rectangular image (quad) from those inputs using a specified shader program, and providing that image to all of its targets. Variants on BasicOperation, such as TextureSamplingOperation or TwoStageOperation, provide additional information to the shader program that may be needed for certain kinds of operations.

To build a simple, one-input filter, you may not even need to create a subclass of your own. All you need to do is supply a fragment shader and the number of inputs needed when instantiating a BasicOperation:

```swift
let myFilter = BasicOperation(fragmentShaderFile:MyFilterFragmentShaderURL, numberOfInputs:1)
```

A shader program is composed of matched vertex and fragment shaders that are compiled and linked together into one program. By default, the framework uses a series of stock vertex shaders based on the number of input images feeding into an operation. Usually, all you'll need to do is provide the custom fragment shader that is used to perform your filtering or other processing.

Fragment shaders used by GPUImage look something like this:

[TODO: Rework for Metal operations]

### Grouping operations ###

If you wish to group a series of operations into a single unit to pass around, you can create a new instance of OperationGroup. OperationGroup provides a configureGroup property that takes a closure which specifies how the group should be configured:

```swift
let boxBlur = BoxBlur()
let contrast = ContrastAdjustment()

let myGroup = OperationGroup()

myGroup.configureGroup{input, output in
    input --> self.boxBlur --> self.contrast --> output
}
```

Frames coming in to the OperationGroup are represented by the input in the above closure, and frames going out of the entire group by the output. After setup, myGroup in the above will appear like any other operation, even though it is composed of multiple sub-operations. This group can then be passed or worked with like a single operation.

### Interacting with Metal ###

[TODO: Rework for Metal]

## Common types ##

The framework uses several platform-independent types to represent common values. Generally, floating-point inputs are taken in as Floats. Sizes are specified using Size types (constructed by initializing with width and height). Colors are handled via the Color type, where you provide the normalized-to-1.0 color values for red, green, blue, and optionally alpha components.

Positions can be provided in 2-D and 3-D coordinates. If a Position is created by only specifying X and Y values, it will be handled as a 2-D point. If an optional Z coordinate is also provided, it will be dealt with as a 3-D point.

Matrices come in Matrix3x3 and Matrix4x4 varieties. These matrices can be build using a row-major array of Floats, or can be initialized from CATransform3D or CGAffineTransform structs.

## Built-in operations ##

[TODO: Fill in with operations as they are added]