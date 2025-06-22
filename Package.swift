// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceryStencilPacks",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .plugin(name: "SourcePack", targets: ["SourcePack"]),
        .plugin(name: "TestPack", targets: ["TestPack"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .plugin(
            name: "SourcePack",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SourceryBinary")
            ]
        ),
        .plugin(
            name: "TestPack",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SourceryBinary")
            ]
        ),
        .binaryTarget(
            name: "SourceryBinary",
            url: "https://github.com/krzysztofzablocki/Sourcery/releases/download/2.2.7/sourcery-2.2.7.artifactbundle.zip",
            checksum: "33f4590a657cc3d6631d81cd557b9ac47594e709623f3e61baa254334e950da6"
        ),
    ]
)
