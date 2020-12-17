// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotificationView",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "NotificationView",
            targets: ["NotificationView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NotificationView",
            dependencies: []),
        .testTarget(
            name: "NotificationViewTests",
            dependencies: ["NotificationView"]),
    ]
)
