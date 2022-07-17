// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PublishFilePipeline",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PublishFilePipeline",
            targets: ["PublishFilePipeline"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.9.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.1.0"),
        .package(url: "https://github.com/eneko/RegEx.git", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PublishFilePipeline",
            dependencies: [
                .product(name: "Publish", package: "Publish"),
                .product(name: "Crypto", package: "swift-crypto"),
                "RegEx"
            ]
        ),
        .testTarget(
            name: "PublishFilePipelineTests",
            dependencies: ["PublishFilePipeline"]
        ),
    ]
)
