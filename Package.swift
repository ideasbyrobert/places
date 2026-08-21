// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Places",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "Places", targets: ["Places"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.9.4")
    ],
    targets: [
        .executableTarget(
            name: "Places",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/Places",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])
            ]
        ),
        .target(
            name: "WindowFixtureApp",
            path: "Sources/WindowFixtureApp",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "PlacesTests",
            dependencies: [
                "Places",
                "WindowFixtureApp"
            ],
            path: "Tests/PlacesTests",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
