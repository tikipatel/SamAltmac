// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MemoryDropAlert",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MemoryDropAlert", targets: ["MemoryDropAlert"]),
    ],
    targets: [
        .target(name: "MemoryDropAlertCore"),
        .executableTarget(name: "MemoryDropAlert", dependencies: ["MemoryDropAlertCore"]),
        .testTarget(name: "MemoryDropAlertCoreTests", dependencies: ["MemoryDropAlertCore"]),
    ]
)
