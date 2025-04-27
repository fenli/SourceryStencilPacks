// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceryStencilPacks",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .plugin(name: "TestPack", targets: ["TestPack"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .plugin(
            name: "TestPack",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SourceryBinary")
            ]
        ),
        .binaryTarget(
            name: "SourceryBinary",
            url: "https://github.com/krzysztofzablocki/Sourcery/releases/download/2.2.6/sourcery-2.2.6.artifactbundle.zip",
            checksum: "00ddb01d968cf5a1b9971a997f362553b2cf57ccdd437e7ecde9c7891ee9e4c1"
        ),
    ]
)
