import PackageDescription

let package = Package(
    name: "SWSQLite",
    targets: [Target(name: "SWSQLite", dependencies:[])],
    dependencies: [.Package(url: "https://github.com/sharksync/CSQlite.git", majorVersion: 1), .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(4,1,0)..<Version(4,1,9))],
    exclude: []
)

