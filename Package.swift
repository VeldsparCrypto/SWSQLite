import PackageDescription

let package = Package(
    name: "SWSQLite",
    targets: [Target(name: "SWSQLite", dependencies:[])],
    dependencies: [.Package(url: "https://github.com/sharksync/CSQlite.git", majorVersion: 2)],
    exclude: []
)

