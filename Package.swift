// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "GPUImage",
    platforms: [
        .macOS(.v10_11), .iOS(.v9),
    ],
    products: [
        .library(
            name: "GPUImage",
            targets: ["GPUImage"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GPUImage",
            path: "framework/Source",
            exclude: ["Linux", "Operations/Shaders"])],
    swiftLanguageVersions: [.v4_2]
)
