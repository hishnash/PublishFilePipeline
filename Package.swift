// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PublishFilePipeline",
    platforms: [.macOS(.v14),],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PublishFilePipeline",
            targets: ["PublishFilePipeline"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/NilCoalescing/publish.git", branch: "upstream"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.7.1"),
        .package(url: "https://github.com/ainame/Swift-WebP.git", from: "0.5.0"),
        .package(url: "https://github.com/awxkee/jxl-coder-swift.git", from: "1.7.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PublishFilePipeline",
            dependencies: [
                .product(name: "Publish", package: "Publish"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(
                    name: "WebP",
                    package: "Swift-WebP",
                    condition: TargetDependencyCondition.when(platforms: [Platform.macOS])
                ),
                .product(
                    name: "JxlCoder",
                    package: "jxl-coder-swift",
                    condition: TargetDependencyCondition.when(platforms: [Platform.macOS])
                ),
            ]
        ),
        .testTarget(
            name: "PublishFilePipelineTests",
            dependencies: ["PublishFilePipeline"]
        ),
    ]
)
