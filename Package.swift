// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mqtt-homekit-bridge",
    dependencies: [
        .package(url: "https://github.com/rhx/SwiftMosquitto.git", .branch("master")),
        .package(url: "https://github.com/bouke/HAP.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "mqtt-homekit-bridge",
            dependencies: ["Mosquitto", "HAP"]),
    ]
)
