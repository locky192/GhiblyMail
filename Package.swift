// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GhiblyMail",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "GhiblyMail", targets: ["GhiblyMail"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "GhiblyMail",
            path: "Sources/GhiblyMail"
        )
    ]
)
