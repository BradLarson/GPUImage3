open class OperationGroup: ImageProcessingOperation {
    let inputImageRelay = ImageRelay()
    let outputImageRelay = ImageRelay()

    public var sources: SourceContainer { return inputImageRelay.sources }
    public var targets: TargetContainer { return outputImageRelay.targets }
    public let maximumInputs: UInt = 1

    public init() {
    }

    public func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        inputImageRelay.newTextureAvailable(texture, fromSourceIndex: fromSourceIndex)
    }

    public func configureGroup(
        _ configurationOperation: (_ input: ImageRelay, _ output: ImageRelay) -> Void
    ) {
        configurationOperation(inputImageRelay, outputImageRelay)
    }

    public func transmitPreviousImage(to target: ImageConsumer, atIndex: UInt) {
        outputImageRelay.transmitPreviousImage(to: target, atIndex: atIndex)
    }
}
