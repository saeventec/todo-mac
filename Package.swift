// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [.macOS(.v27)],
    targets: [
        .executableTarget(name: "TodoApp"),
        .testTarget(
            name: "TodoAppTests",
            dependencies: ["TodoApp"]
        ),
    ]
)
