// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SamAltmac",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "SamAltmac", targets: ["SamAltmac"]),
    ],
    targets: [
        .target(name: "SamAltmacCore"),
        .executableTarget(name: "SamAltmac", dependencies: ["SamAltmacCore"]),
        .testTarget(name: "SamAltmacCoreTests", dependencies: ["SamAltmacCore"]),
    ]
)
