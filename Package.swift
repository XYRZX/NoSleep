// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NoSleep",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "NoSleep", targets: ["NoSleep"])
    ],
    targets: [
        .executableTarget(
            name: "NoSleep",
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("Cocoa")
            ]
        )
    ]
)