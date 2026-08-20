// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GridWindowManager",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "GridWindowManager", targets: ["GridWindowManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.9.4")
    ],
    targets: [
        .executableTarget(
            name: "GridWindowManager",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/GridWindowManager",
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
            name: "GridWindowManagerTests",
            dependencies: [
                "GridWindowManager",
                "WindowFixtureApp"
            ],
            path: "Tests/GridWindowManagerTests",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
