// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "skdemo",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit.git", from: "4.1.0"),
        // .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.1.0")
    ],
    targets: [
        .target( name: "skdemo", dependencies: [
            .product(name: "ConsoleKit", package: "console-kit"),
            // .product(name: "WebSocketKit", package: "websocket-kit")
        ]),
        .testTarget(
            name: "skdemoTests",
            dependencies: ["skdemo"])
    ]
)
