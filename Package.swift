// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Kumi",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
    products: [
        .library(name: "Kumi", targets: ["Kumi"]),
    ],
    targets: [
        .target(name: "Kumi"),
        .testTarget(name: "KumiTests", dependencies: ["Kumi"]),
    ]
)
