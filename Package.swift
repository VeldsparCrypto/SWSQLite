// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SWSQLite",
    products: [
        .library(name: "SWSQLite"),
        ],
    dependencies: [
        .package(url: "https://github.com/VeldsparCrypto/CSQlite.git", .exact("1.0.2")),],
    targets: []
)

