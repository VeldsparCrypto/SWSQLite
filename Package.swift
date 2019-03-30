import PackageDescription

let package = Package(
    name: "SWSQLite",
    targets: [Target(name: "SWSQLite", dependencies:[])],
    dependencies: [.Package(url: "https://github.com/VeldsparCrypto/CSQlite.git", versions: Version(1,0,6)..<Version(2,0,0))],
    exclude: []
)
