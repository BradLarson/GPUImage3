// swift-tools-version:5.5

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
            resources: [.process("Metal/"), .copy("Operations/LookupImages/")])],
    swiftLanguageVersions: [.v4_2]
)
