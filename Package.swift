import PackageDescription

let package = Package(
    name: "SWSQLite",
    products: [
        .library        (name: "SWSQLite",     targets: ["SWSQLite"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/sharksync/CSQlite.git", .exact("1.0.2")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .exact("4.1.0")),
        ],
    targets: [
        .target(
            name: "SWSQLite",
            dependencies: ["SwiftyJSON"],
        ]
)




