# GPUImage 3 #

<div style="float: right"><img src="http://sunsetlakesoftware.com/sites/default/files/GPUImageLogo.png" /></div>

Janie Larson

http://redqueencoder.com

[@RedQueenCoder](https://twitter.com/RedQueenCoder)
[@RedQueenCoder@appdot.net](https://appdot.net/@RedQueenCoder)

Brad Larson

http://www.sunsetlakesoftware.com

[@bradlarson@hachyderm.io](https://hachyderm.io/@bradlarson)

contact@sunsetlakesoftware.com

## Overview ##

GPUImage 3 is the third generation of the <a href="https://github.com/BradLarson/GPUImage">GPUImage framework</a>, an open source project for performing GPU-accelerated image and video processing on Mac and iOS. The original GPUImage framework was written in Objective-C and targeted Mac and iOS, the second iteration rewritten in Swift using OpenGL to target Mac, iOS, and Linux, and now this third generation is redesigned to use Metal in place of OpenGL.

The objective of the framework is to make it as easy as possible to set up and perform realtime video processing or machine vision against image or video sources. Previous iterations of this framework wrapped OpenGL (ES), hiding much of the boilerplate code required to render images on the GPU using custom vertex and fragment shaders. This version of the framework replaces OpenGL (ES) with Metal. Largely driven by Apple's deprecation of OpenGL (ES) on their platforms in favor of Metal, it will allow for exploring performance optimizations over OpenGL and a tighter integration with Metal-based frameworks and operations.

The API is a clone of that used in <a href="https://github.com/BradLarson/GPUImage2">GPUImage 2</a>, and is intended to be a drop-in replacement for that version of the framework. Swapping between Metal and OpenGL versions of the framework should be as simple as changing which framework your application is linked against. A few low-level interfaces, such as those around texture input and output, will necessarily be Metal- or OpenGL-specific, but everything else is designed to be compatible between the two.

As of this point, we are not approving enhancement requests from outside contributors. We are actively working to port all of the functionality between this version of GPUImage and previous versions. Once this task has been completed we will be happy to take community contributions.

## License ##

BSD-style, with the full license available with the framework in License.txt.

## Technical requirements ##

- Swift 5.5
- Xcode 13.0 or higher on Mac or iOS
- iOS: 10.0 or higher
- OSX: 10.13 or higher

## General architecture ##

The framework relies on the concept of a processing pipeline, where image sources are targeted at image consumers, and so on down the line until images are output to the screen, to image files, to raw data, or to recorded movies. Cameras, movies, still images, and raw data can be inputs into this pipeline. Arbitrarily complex processing operations can be built from a combination of a series of smaller operations.

This is an object-oriented framework, with classes that encapsulate inputs, processing operations, and outputs. The processing operations use Metal vertex and fragment shaders to perform their image manipulations on the GPU.

Examples for usage of the framework in common applications are shown below.

## Using GPUImage in a Mac or iOS application ##

GPUImage is provided as a Swift package. To add it to your Mac or iOS application, go to your project
settings, choose Package Dependencies, and click the plus button. Enter this repository's URL in the
upper-right and hit enter. GPUImage will appear as a package dependency of your project.

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

- **LookupFilter**: Uses an RGB color lookup image to remap the colors in an image. First, use your favourite photo editing application to apply a filter to lookup.png from framework/Operations/LookupImages. For this to work properly each pixel color must not depend on other pixels (e.g. blur will not work). If you need a more complex filter you can create as many lookup tables as required. Once ready, use your new lookup.png file as  the basis of a PictureInput that you provide for the lookupImage property.
  - *intensity*: The intensity of the applied effect, from 0.0 (stock image) to 1.0 (fully applied effect).
  - *lookupImage*: The image to use as the lookup reference, in the form of a PictureInput.

- **AmatorkaFilter**: A photo filter based on a Photoshop action by Amatorka: http://amatorka.deviantart.com/art/Amatorka-Action-2-121069631 . If you want to use this effect you have to add lookup_amatorka.png from the GPUImage framework/Operations/LookupImages folder to your application bundle.

- **MissEtikateFilter**: A photo filter based on a Photoshop action by Miss Etikate: http://miss-etikate.deviantart.com/art/Photoshop-Action-15-120151961 . If you want to use this effect you have to add lookup_miss_etikate.png from the GPUImage framework/Operations/LookupImages folder to your application bundle.

- **SoftElegance**: Another lookup-based color remapping filter. If you want to use this effect you have to add lookup_soft_elegance_1.png and lookup_soft_elegance_2.png from the GPUImage framework/Operations/LookupImages folder to your application bundle.

- **ColorInversion**: Inverts the colors of an image

- **Luminance**: Reduces an image to just its luminance (greyscale).

- **MonochromeFilter**: Converts the image to a single-color version, based on the luminance of each pixel
  - *intensity*: The degree to which the specific color replaces the normal image color (0.0 - 1.0, with 1.0 as the default)
  - *color*: The color to use as the basis for the effect, with (0.6, 0.45, 0.3, 1.0) as the default.

- **FalseColor**: Uses the luminance of the image to mix between two user-specified colors
  - *firstColor*: The first and second colors specify what colors replace the dark and light areas of the image, respectively. The defaults are (0.0, 0.0, 0.5) amd (1.0, 0.0, 0.0).
  - *secondColor*: 

- **Haze**: Used to add or remove haze (similar to a UV filter)
  - *distance*: Strength of the color applied. Default 0. Values between -.3 and .3 are best.
  - *slope*: Amount of color change. Default 0. Values between -.3 and .3 are best.

- **SepiaToneFilter**: Simple sepia tone filter
  - *intensity*: The degree to which the sepia tone replaces the normal image color (0.0 - 1.0, with 1.0 as the default)

- **LuminanceThreshold**: Pixels with a luminance above the threshold will appear white, and those below will be black
  - *threshold*: The luminance threshold, from 0.0 to 1.0, with a default of 0.5

- **AdaptiveThreshold**: Determines the local luminance around a pixel, then turns the pixel black if it is below that local luminance and white if above. This can be useful for picking out text under varying lighting conditions.
  - *blurRadiusInPixels*: A multiplier for the background averaging blur radius in pixels, with a default of 4.

- **ChromaKeying**: For a given color in the image, sets the alpha channel to 0. This is similar to the ChromaKeyBlend, only instead of blending in a second image for a matching color this doesn't take in a second image and just turns a given color transparent.
  - *thresholdSensitivity*: How close a color match needs to exist to the target color to be replaced (default of 0.4)
  - *smoothing*: How smoothly to blend for the color match (default of 0.1)

- **Vibrance**: Adjusts the vibrance of an image
  - *vibrance*: The vibrance adjustment to apply, using 0.0 as the default, and a suggested min/max of around -1.2 and 1.2, respectively.

- **HighlightShadowTint**: Allows you to tint the shadows and highlights of an image independently using a color and intensity
  - *shadowTintColor*: Shadow tint RGB color (GPUVector4). Default: `{1.0f, 0.0f, 0.0f, 1.0f}` (red).
  - *highlightTintColor*: Highlight tint RGB color (GPUVector4). Default: `{0.0f, 0.0f, 1.0f, 1.0f}` (blue).
  - *shadowTintIntensity*: Shadow tint intensity, from 0.0 to 1.0. Default: 0.0
  - *highlightTintIntensity*: Highlight tint intensity, from 0.0 to 1.0, with 0.0 as the default.

### Image processing ###

- **Sharpen**: Sharpens the image
  - *sharpness*: The sharpness adjustment to apply (-4.0 - 4.0, with 0.0 as the default)

- **GaussianBlur**: A hardware-optimized, variable-radius Gaussian blur
  - *blurRadiusInPixels*: A radius in pixels to use for the blur, with a default of 2.0. This adjusts the sigma variable in the Gaussian distribution function.

- **BoxBlur**: A hardware-optimized, variable-radius box blur
  - *blurRadiusInPixels*: A radius in pixels to use for the blur, with a default of 2.0. This adjusts the box radius for the blur function.

- **iOSBlur**: An attempt to replicate the background blur used on iOS 7 in places like the control center.
  - *blurRadiusInPixels*: A radius in pixels to use for the blur, with a default of 48.0. This adjusts the sigma variable in the Gaussian distribution function.
  - *saturation*: Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 0.8 as the normal level
  - *rangeReductionFactor*: The range to reduce the luminance of the image, defaulting to 0.6.

- **MedianFilter**: Takes the median value of the three color components, over a 3x3 area

- **TiltShift**: A simulated tilt shift lens effect
  - *blurRadiusInPixels*: The radius of the underlying blur, in pixels. This is 7.0 by default.
  - *topFocusLevel*: The normalized location of the top of the in-focus area in the image, this value should be lower than bottomFocusLevel, default 0.4
  - *bottomFocusLevel*: The normalized location of the bottom of the in-focus area in the image, this value should be higher than topFocusLevel, default 0.6
  - *focusFallOffRate*: The rate at which the image gets blurry away from the in-focus region, default 0.2

- **Convolution3x3**: Runs a 3x3 convolution kernel against the image
  - *convolutionKernel*: The convolution kernel is a 3x3 matrix of values to apply to the pixel and its 8 surrounding pixels. The matrix is specified in row-major order, with the top left pixel being m11 and the bottom right m33. If the values in the matrix don't add up to 1.0, the image could be brightened or darkened.

- **SobelEdgeDetection**: Sobel edge detection, with edges highlighted in white
  - *edgeStrength*: Adjusts the dynamic range of the filter. Higher values lead to stronger edges, but can saturate the intensity colorspace. Default is 1.0.

- **PrewittEdgeDetection**: Prewitt edge detection, with edges highlighted in white
  - *edgeStrength*: Adjusts the dynamic range of the filter. Higher values lead to stronger edges, but can saturate the intensity colorspace. Default is 1.0.

- **ThresholdSobelEdgeDetection**: Performs Sobel edge detection, but applies a threshold instead of giving gradual strength values
  - *edgeStrength*: Adjusts the dynamic range of the filter. Higher values lead to stronger edges, but can saturate the intensity colorspace. Default is 1.0.
  - *threshold*: Any edge above this threshold will be black, and anything below white. Ranges from 0.0 to 1.0, with 0.8 as the default

- **LocalBinaryPattern**: This performs a comparison of intensity of the red channel of the 8 surrounding pixels and that of the central one, encoding the comparison results in a bit string that becomes this pixel intensity. The least-significant bit is the top-right comparison, going counterclockwise to end at the right comparison as the most significant bit.

- **ColorLocalBinaryPattern**: This performs a comparison of intensity of all color channels of the 8 surrounding pixels and that of the central one, encoding the comparison results in a bit string that becomes each color channel's intensity. The least-significant bit is the top-right comparison, going counterclockwise to end at the right comparison as the most significant bit.

- **LowPassFilter**: This applies a low pass filter to incoming video frames. This basically accumulates a weighted rolling average of previous frames with the current ones as they come in. This can be used to denoise video, add motion blur, or be used to create a high pass filter.
  - *strength*: This controls the degree by which the previous accumulated frames are blended with the current one. This ranges from 0.0 to 1.0, with a default of 0.5.

- **HighPassFilter**: This applies a high pass filter to incoming video frames. This is the inverse of the low pass filter, showing the difference between the current frame and the weighted rolling average of previous ones. This is most useful for motion detection.
  - *strength*: This controls the degree by which the previous accumulated frames are blended and then subtracted from the current one. This ranges from 0.0 to 1.0, with a default of 0.5.

- **ZoomBlur**: Applies a directional motion blur to an image
  - *blurSize*: A multiplier for the blur size, ranging from 0.0 on up, with a default of 1.0
  - *blurCenter*: The normalized center of the blur. (0.5, 0.5) by default

- **ColourFASTFeatureDetection**: Brings out the ColourFAST feature descriptors for an image
  - *blurRadiusInPixels*: The underlying blur radius for the box blur. Default is 3.0.

### Blending modes ###

- **ChromaKeyBlend**: Selectively replaces a color in the first image with the second image
  - *thresholdSensitivity*: How close a color match needs to exist to the target color to be replaced (default of 0.4)
  - *smoothing*: How smoothly to blend for the color match (default of 0.1)

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

### Visual effects ###

- **Pixellate**: Applies a pixellation effect on an image or video
  - *fractionalWidthOfAPixel*: How large the pixels are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)

- **PolarPixellate**: Applies a pixellation effect on an image or video, based on polar coordinates instead of Cartesian ones
  - *center*: The center about which to apply the pixellation, defaulting to (0.5, 0.5)
  - *pixelSize*: The fractional pixel size, split into width and height components. The default is (0.05, 0.05)

- **PolkaDot**: Breaks an image up into colored dots within a regular grid
  - *fractionalWidthOfAPixel*: How large the dots are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)
  - *dotScaling*: What fraction of each grid space is taken up by a dot, from 0.0 to 1.0 with a default of 0.9.

- **Halftone**: Applies a halftone effect to an image, like news print
  - *fractionalWidthOfAPixel*: How large the halftone dots are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)

- **Crosshatch**: This converts an image into a black-and-white crosshatch pattern
  - *crossHatchSpacing*: The fractional width of the image to use as the spacing for the crosshatch. The default is 0.03.
  - *lineWidth*: A relative width for the crosshatch lines. The default is 0.003.

- **SketchFilter**: Converts video to look like a sketch. This is just the Sobel edge detection filter with the colors inverted
  - *edgeStrength*: Adjusts the dynamic range of the filter. Higher values lead to stronger edges, but can saturate the intensity colorspace. Default is 1.0.

- **ThresholdSketchFilter**: Same as the sketch filter, only the edges are thresholded instead of being grayscale
  - *edgeStrength*: Adjusts the dynamic range of the filter. Higher values lead to stronger edges, but can saturate the intensity colorspace. Default is 1.0.
  - *threshold*: Any edge above this threshold will be black, and anything below white. Ranges from 0.0 to 1.0, with 0.8 as the default

- **ToonFilter**: This uses Sobel edge detection to place a black border around objects, and then it quantizes the colors present in the image to give a cartoon-like quality to the image.
  - *threshold*: The sensitivity of the edge detection, with lower values being more sensitive. Ranges from 0.0 to 1.0, with 0.2 as the default
  - *quantizationLevels*: The number of color levels to represent in the final image. Default is 10.0

- **SmoothToonFilter**: This uses a similar process as the ToonFilter, only it precedes the toon effect with a Gaussian blur to smooth out noise.
  - *blurRadiusInPixels*: The radius of the underlying Gaussian blur. The default is 2.0.
  - *threshold*: The sensitivity of the edge detection, with lower values being more sensitive. Ranges from 0.0 to 1.0, with 0.2 as the default
  - *quantizationLevels*: The number of color levels to represent in the final image. Default is 10.0

- **EmbossFilter**: Applies an embossing effect on the image
  - *intensity*: The strength of the embossing, from  0.0 to 4.0, with 1.0 as the normal level

- **SwirlDistortion**: Creates a swirl distortion on the image
  - *radius*: The radius from the center to apply the distortion, with a default of 0.5
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to twist, with a default of (0.5, 0.5)
  - *angle*: The amount of twist to apply to the image, with a default of 1.0

- **BulgeDistortion**: Creates a bulge distortion on the image
  - *radius*: The radius from the center to apply the distortion, with a default of 0.25
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to distort, with a default of (0.5, 0.5)
  - *scale*: The amount of distortion to apply, from -1.0 to 1.0, with a default of 0.5

- **PinchDistortion**: Creates a pinch distortion of the image
  - *radius*: The radius from the center to apply the distortion, with a default of 1.0
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to distort, with a default of (0.5, 0.5)
  - *scale*: The amount of distortion to apply, from -2.0 to 2.0, with a default of 1.0

- **StretchDistortion**: Creates a stretch distortion of the image
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to distort, with a default of (0.5, 0.5)

- **SphereRefraction**: Simulates the refraction through a glass sphere
  - *center*: The center about which to apply the distortion, with a default of (0.5, 0.5)
  - *radius*: The radius of the distortion, ranging from 0.0 to 1.0, with a default of 0.25
  - *refractiveIndex*: The index of refraction for the sphere, with a default of 0.71

- **GlassSphereRefraction**: Same as SphereRefraction, only the image is not inverted and there's a little bit of frosting at the edges of the glass
  - *center*: The center about which to apply the distortion, with a default of (0.5, 0.5)
  - *radius*: The radius of the distortion, ranging from 0.0 to 1.0, with a default of 0.25
  - *refractiveIndex*: The index of refraction for the sphere, with a default of 0.71

- **Vignette**: Performs a vignetting effect, fading out the image at the edges
  - *center*: The center for the vignette in tex coords (CGPoint), with a default of 0.5, 0.5
  - *color*: The color to use for the vignette (GPUVector3), with a default of black
  - *start*: The normalized distance from the center where the vignette effect starts, with a default of 0.5
  - *end*: The normalized distance from the center where the vignette effect ends, with a default of 0.75

- **KuwaharaRadius3Filter**: A modified version of the Kuwahara filter, optimized to work over just a radius of three pixels

- **CGAColorspace**: Simulates the colorspace of a CGA monitor

- **Solarize**: Applies a solarization effect
  - *threshold*: Pixels with a luminance above the threshold will invert their color. Ranges from 0.0 to 1.0, with 0.5 as the default.
