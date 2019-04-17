// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SWSQLite",
    dependencies: [
        .package(url: "https://github.com/VeldsparCrypto/CSQlite.git", .exact("1.0.8")),
    ],
    targets: [
        .target(
            name: "SWSQLite",
            dependencies: [],
    ],
    swiftLanguageVersions: [
        4
    ]
)
