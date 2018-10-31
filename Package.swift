import PackageDescription

let package = Package(
    name: "SWSQLite",
    products: [
        .library(name: "SWSQLite", targets: ["SWSQLite"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sharksync/CSQlite.git", .exact("1.0.2")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .exact("4.1.0")),
    ],
    targets: [
        .target(
            name: "SWSQLite",
            dependencies: ["SwiftyJSON"]),
    ]
)





