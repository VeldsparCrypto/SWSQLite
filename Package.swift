// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SWSQLite",
    targets: [Target(name: "SWSQLite", dependencies:[])],
    dependencies: [
        .package(url: "https://github.com/VeldsparCrypto/CSQlite.git", .exact("1.0.8")),
    ],
    exclude: []
)
