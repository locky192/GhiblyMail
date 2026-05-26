// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GhiblyMail",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "GhiblyMailCore", targets: ["GhiblyMailCore"]),
        .executable(name: "GhiblyMail", targets: ["GhiblyMail"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GhiblyMailCore",
            path: "Sources/GhiblyMailCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "GhiblyMail",
            dependencies: ["GhiblyMailCore"],
            path: "Sources/GhiblyMail"
        ),
        .testTarget(
            name: "GhiblyMailCoreTests",
            dependencies: ["GhiblyMailCore"]
        )
    ]
)
