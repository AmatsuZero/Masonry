// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Masonry",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12)
    ],
    products: [
        // ObjC 核心库，等价于 pod 'Masonry' 或 pod 'Masonry/Core'
        .library(
            name: "Masonry",
            targets: ["Masonry"]
        ),
        // Swift 扩展库，等价于 pod 'Masonry/Swift'
        .library(
            name: "MasonrySwift",
            targets: ["MasonrySwift"]
        ),
    ],
    targets: [
        // ── Core: Objective-C 核心功能 ──
        .target(
            name: "Masonry",
            path: "Masonry",
            exclude: [
                "Masonry+Swift.swift",
                "Info.plist"
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),

        // ── Swift: Swift 原生语法扩展 ──
        .target(
            name: "MasonrySwift",
            dependencies: ["Masonry"],
            path: "Masonry",
            exclude: [
                "Info.plist"
            ],
            sources: ["Masonry+Swift.swift"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
