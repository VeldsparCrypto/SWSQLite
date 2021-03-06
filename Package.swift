// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SWSQLite",
    products: [
        .library(name: "SWSQLite", targets: ["SWSQLite"]),
    ],
    dependencies: [
        .package(url: "https://github.com/VeldsparCrypto/CSQlite.git", .exact("1.0.8")),
    ],
    targets: [
        .target(
            name: "SWSQLite",
            dependencies: [],
            path: "./Sources"),
    ],
    swiftLanguageVersions: [
        4
    ]
)
