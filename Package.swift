// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "GPUImage",
    platforms: [
        .macOS(.v10_11), .iOS(.v10),
    ],
    products: [
        .library(
            name: "GPUImage",
            targets: ["GPUImage"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GPUImage",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GPUImageTests",
            dependencies: ["GPUImage"]),
    ]
)
