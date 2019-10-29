# GPUImage 3 #

<div style="float: right"><img src="http://sunsetlakesoftware.com/sites/default/files/GPUImageLogo.png" /></div>

Janie Clayton

http://redqueengraphics.com

[@RedQueenCoder](https://twitter.com/RedQueenCoder)

Brad Larson

http://www.sunsetlakesoftware.com

[@bradlarson](http://twitter.com/bradlarson)

contact@sunsetlakesoftware.com

## Overview ##

GPUImage 3 is the third generation of the <a href="https://github.com/BradLarson/GPUImage">GPUImage framework</a>, an open source project for performing GPU-accelerated image and video processing on Mac and iOS. The original GPUImage framework was written in Objective-C and targeted Mac and iOS, the second iteration rewritten in Swift using OpenGL to target Mac, iOS, and Linux, and now this third generation is redesigned to use Metal in place of OpenGL.

The objective of the framework is to make it as easy as possible to set up and perform realtime video processing or machine vision against image or video sources. Previous iterations of this framework wrapped OpenGL (ES), hiding much of the boilerplate code required to render images on the GPU using custom vertex and fragment shaders. This version of the framework replaces OpenGL (ES) with Metal. Largely driven by Apple's deprecation of OpenGL (ES) on their platforms in favor of Metal, it will allow for exploring performance optimizations over OpenGL and a tighter integration with Metal-based frameworks and operations.

The API is a clone of that used in <a href="https://github.com/BradLarson/GPUImage2">GPUImage 2</a>, and is intended to be a drop-in replacement for that version of the framework. Swapping between Metal and OpenGL versions of the framework should be as simple as changing which framework your application is linked against. A few low-level interfaces, such as those around texture input and output, will necessarily be Metal- or OpenGL-specific, but everything else is designed to be compatible between the two.

As of this point, we are not approving enhancement requests from outside contributors. We are actively working to port all of the functionality between this version of GPUImage adn previous versions. Once this task has been completed we will be happy to take community contributions.

## License ##

BSD-style, with the full license available with the framework in License.txt.

## Technical requirements ##

- Swift 4.2
- Xcode 10.2 or higher on Mac or iOS
- iOS: 9.0 or higher
- OSX: 10.11 or higher

## General architecture ##

The framework relies on the concept of a processing pipeline, where image sources are targeted at image consumers, and so on down the line until images are output to the screen, to image files, to raw data, or to recorded movies. Cameras, movies, still images, and raw data can be inputs into this pipeline. Arbitrarily complex processing operations can be built from a combination of a series of smaller operations.

This is an object-oriented framework, with classes that encapsulate inputs, processing operations, and outputs. The processing operations use Metal vertex and fragment shaders to perform their image manipulations on the GPU.

Examples for usage of the framework in common applications are shown below.

## Using GPUImage in a Mac or iOS application ##

To add the GPUImage framework to your Mac or iOS application, either drag the GPUImage.xcodeproj project into your application's project or add it via File | Add Files To...

After that, go to your project's Build Phases and add GPUImage_iOS or GPUImage_macOS as a Target Dependency. Add it to the Link Binary With Libraries phase. Add a new Copy Files build phase, set its destination to Frameworks, and add the upper GPUImage.framework (for iOS) or lower GPUImage.framework (for Mac) to that. That last step will make sure the framework is deployed in your application bundle.

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
    camera = try Camera(sessionPreset:.vga640x480)
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

Functionality not completed.

### Processing a still image ###

Functionality not completed.

### Filtering and re-encoding a movie ###

Functionality not completed.

### Writing a custom image processing operation ###

The framework uses a series of protocols to define types that can output images to be processed, take in an image for processing, or do both. These are the ImageSource, ImageConsumer, and ImageProcessingOperation protocols, respectively. Any type can comply to these, but typically classes are used.

Many common filters and other image processing operations can be described as subclasses of the BasicOperation class. BasicOperation provides much of the internal code required for taking in an image frame from one or more inputs, rendering a rectangular image (quad) from those inputs using a specified shader program, and providing that image to all of its targets. Variants on BasicOperation, such as TextureSamplingOperation or TwoStageOperation, provide additional information to the shader program that may be needed for certain kinds of operations.

To build a simple, one-input filter, you may not even need to create a subclass of your own. All you need to do is supply a fragment shader and the number of inputs needed when instantiating a BasicOperation:

```swift
let myFilter = BasicOperation(fragmentFunctionName:"myFilterFragmentFunction", numberOfInputs:1)
```

A shader program is composed of matched vertex and fragment shaders that are compiled and linked together into one program. By default, the framework uses a series of stock vertex shaders based on the number of input images feeding into an operation. Usually, all you'll need to do is provide the custom fragment shader that is used to perform your filtering or other processing.

Fragment shaders used by GPUImage look something like this:

```metal
#include <metal_stdlib>
#include "OperationShaderTypes.h"

using namespace metal;

fragment half4 passthroughFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);

    return color;
}
```

and are saved within .metal files that are compiled at the same time as the framework / your project.

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

Operations are currently being ported over from GPUImage 2. Here are the ones that are currently functional:

### Color adjustments ###

- **BrightnessAdjustment**: Adjusts the brightness of the image. Described in detail <a href="http://redqueengraphics.com/2018/07/29/metal-shaders-color-adjustments/">here</a>.
  - *brightness*: The adjusted brightness (-1.0 - 1.0, with 0.0 as the default)

- **ExposureAdjustment**: Adjusts the exposure of the image. Described in detail <a href="http://redqueengraphics.com/2018/07/29/metal-shaders-color-adjustments/">here</a>.
  - *exposure*: The adjusted exposure (-10.0 - 10.0, with 0.0 as the default)

- **ContrastAdjustment**: Adjusts the contrast of the image. Described in detail <a href="http://redqueengraphics.com/2018/07/29/metal-shaders-color-adjustments/">here</a>.
  - *contrast*: The adjusted contrast (0.0 - 4.0, with 1.0 as the default)

- **SaturationAdjustment**: Adjusts the saturation of an image. Described in detail <a href="http://redqueengraphics.com/2018/07/29/metal-shaders-color-adjustments/">here</a>.
  - *saturation*: The degree of saturation or desaturation to apply to the image (0.0 - 2.0, with 1.0 as the default)

- **GammaAdjustment**: Adjusts the gamma of an image. Described in detail <a href="http://redqueengraphics.com/2018/07/29/metal-shaders-color-adjustments/">here</a>.
  - *gamma*: The gamma adjustment to apply (0.0 - 3.0, with 1.0 as the default)

- **LevelsAdjustment**: Photoshop-like levels adjustment. The minimum, middle, maximum, minOutput and maxOutput parameters are floats in the range [0, 1]. If you have parameters from Photoshop in the range [0, 255] you must first convert them to be [0, 1]. The gamma/mid parameter is a float >= 0. This matches the value from Photoshop. If you want to apply levels to RGB as well as individual channels you need to use this filter twice - first for the individual channels and then for all channels.

- **ColorMatrixFilter**: Transforms the colors of an image by applying a matrix to them
  - *colorMatrix*: A 4x4 matrix used to transform each color in an image
  - *intensity*: The degree to which the new transformed color replaces the original color for each pixel

- **RGBAdjustment**: Adjusts the individual RGB channels of an image. Described in detail <a href="http://redqueengraphics.com/2018/07/29/metal-shaders-color-adjustments/">here</a>.
  - *red*: Normalized values by which each color channel is multiplied. The range is from 0.0 up, with 1.0 as the default.
  - *green*: 
  - *blue*:

- **WhiteBalance**: Adjusts the white balance of an image.
  - *temperature*: The temperature to adjust the image by, in ºK. A value of 4000 is very cool and 7000 very warm. The default value is 5000. Note that the scale between 4000 and 5000 is nearly as visually significant as that between 5000 and 7000.
  - *tint*: The tint to adjust the image by. A value of -200 is *very* green and 200 is *very* pink. The default value is 0.  

- **HighlightsAndShadows**: Adjusts the shadows and highlights of an image
  - *shadows*: Increase to lighten shadows, from 0.0 to 1.0, with 0.0 as the default.
  - *highlights*: Decrease to darken highlights, from 1.0 to 0.0, with 1.0 as the default.

- **HueAdjustment**: Adjusts the hue of an image
  - *hue*: The hue angle, in degrees. 90 degrees by default

- **ColorInversion**: Inverts the colors of an image. Described in detail <a href="http://redqueengraphics.com/2018/07/15/metal-shaders-color-inversion/">here</a>.

- **Luminance**: Reduces an image to just its luminance (greyscale). Described in detail <a href="http://redqueengraphics.com/2018/07/26/metal-shaders-luminance/">here</a>.

- **MonochromeFilter**: Converts the image to a single-color version, based on the luminance of each pixel
  - *intensity*: The degree to which the specific color replaces the normal image color (0.0 - 1.0, with 1.0 as the default)
  - *color*: The color to use as the basis for the effect, with (0.6, 0.45, 0.3, 1.0) as the default.

- **Haze**: Used to add or remove haze (similar to a UV filter)
  - *distance*: Strength of the color applied. Default 0. Values between -.3 and .3 are best.
  - *slope*: Amount of color change. Default 0. Values between -.3 and .3 are best.

- **SepiaToneFilter**: Simple sepia tone filter
  - *intensity*: The degree to which the sepia tone replaces the normal image color (0.0 - 1.0, with 1.0 as the default)

- **OpacityAdjustment**: Adjusts the alpha channel of the incoming image
  - *opacity*: The value to multiply the incoming alpha channel for each pixel by (0.0 - 1.0, with 1.0 as the default)

- **LuminanceThreshold**: Pixels with a luminance above the threshold will appear white, and those below will be black
  - *threshold*: The luminance threshold, from 0.0 to 1.0, with a default of 0.5

- **Vibrance**: Adjusts the vibrance of an image
  - *vibrance*: The vibrance adjustment to apply, using 0.0 as the default, and a suggested min/max of around -1.2 and 1.2, respectively.

- **HighlightAndShadowTint**: Allows you to tint the shadows and highlights of an image independently using a color and intensity
  - *shadowTintColor*: Shadow tint RGB color (GPUVector4). Default: `{1.0f, 0.0f, 0.0f, 1.0f}` (red).
  - *highlightTintColor*: Highlight tint RGB color (GPUVector4). Default: `{0.0f, 0.0f, 1.0f, 1.0f}` (blue).
  - *shadowTintIntensity*: Shadow tint intensity, from 0.0 to 1.0. Default: 0.0
  - *highlightTintIntensity*: Highlight tint intensity, from 0.0 to 1.0, with 0.0 as the default.
  
  ### Blending modes ###

  - **DissolveBlend**: Applies a dissolve blend of two images
    - *mix*: The degree with which the second image overrides the first (0.0 - 1.0, with 0.5 as the default)

  - **MultiplyBlend**: Applies a multiply blend of two images

  - **AddBlend**: Applies an additive blend of two images

  - **SubtractBlend**: Applies a subtractive blend of two images

  - **DivideBlend**: Applies a division blend of two images

  - **OverlayBlend**: Applies an overlay blend of two images

  - **DarkenBlend**: Blends two images by taking the minimum value of each color component between the images

  - **LightenBlend**: Blends two images by taking the maximum value of each color component between the images

  - **ColorBurnBlend**: Applies a color burn blend of two images

  - **ColorDodgeBlend**: Applies a color dodge blend of two images

  - **ScreenBlend**: Applies a screen blend of two images

  - **ExclusionBlend**: Applies an exclusion blend of two images

  - **DifferenceBlend**: Applies a difference blend of two images

  - **HardLightBlend**: Applies a hard light blend of two images

  - **SoftLightBlend**: Applies a soft light blend of two images

  - **AlphaBlend**: Blends the second image over the first, based on the second's alpha channel
    - *mix*: The degree with which the second image overrides the first (0.0 - 1.0, with 1.0 as the default)

  - **SourceOverBlend**: Applies a source over blend of two images

  - **ColorBurnBlend**: Applies a color burn blend of two images

  - **ColorDodgeBlend**: Applies a color dodge blend of two images

  - **NormalBlend**: Applies a normal blend of two images

  - **ColorBlend**: Applies a color blend of two images

  - **HueBlend**: Applies a hue blend of two images

  - **SaturationBlend**: Applies a saturation blend of two images

  - **LuminosityBlend**: Applies a luminosity blend of two images

  - **LinearBurnBlend**: Applies a linear burn blend of two images

  
