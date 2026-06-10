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
        // Showcase executables — each builds a styled page with Kumi and prints
        // it (see Examples/render.sh → docs/). They are NOT library products, so
        // packages depending on `Kumi` never build them.
        .executableTarget(name: "report", dependencies: ["Kumi"], path: "Examples/report"),
        .executableTarget(name: "invoice", dependencies: ["Kumi"], path: "Examples/invoice"),
        .executableTarget(name: "article", dependencies: ["Kumi"], path: "Examples/article"),
        .executableTarget(name: "gallery", dependencies: ["Kumi"], path: "Examples/gallery"),
    ]
)
