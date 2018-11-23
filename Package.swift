// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SWSQLite",
    products: [
        .library(name: "SWSQLite", targets: ["SWSQLite"]),
        ],
    dependencies: [
        .Package(url: "https://github.com/VeldsparCrypto/CSQlite.git", .branch("master")),],
    targets: [
        .target(
            name: "SWSQLite",
            dependencies: []),
        ]
)

