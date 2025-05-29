// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Dog",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "Dog",
            dependencies: ["ZIPFoundation"]
        )
    ]
) 