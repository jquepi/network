import PackageDescription

let package = Package(
    name: "Network",
    dependencies: [
        .Package(url: "https://github.com/swift-stack/platform.git", majorVersion: 0),
        .Package(url: "https://github.com/swift-stack/async.git", majorVersion: 0)
    ]
)
