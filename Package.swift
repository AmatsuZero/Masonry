// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Products

let products: [Product] = [
    // ObjC 核心库
    .library(
        name: "Masonry",
        targets: ["Masonry"]
    ),
    // Swift 扩展库
    .library(
        name: "MasonrySwift",
        targets: ["MasonrySwift"]
    ),
]

// MARK: - Targets

let targets: [Target] = [
    // ── Core: Objective-C 核心功能 ──
    .target(
        name: "Masonry",
        path: "Masonry",
        publicHeadersPath: "include",
        cSettings: [
            .headerSearchPath("."),
            .headerSearchPath("include"),
        ]
    ),

    // ── Swift: Swift 原生语法扩展 ──
    .target(
        name: "MasonrySwift",
        dependencies: ["Masonry"],
        path: "MasonrySwift"
    ),

    // ── Tests: 单元测试 ──
    .testTarget(
        name: "MasonryTests",
        dependencies: ["Masonry"],
        path: "Tests",
        exclude: [
                "MasonrySwiftTests",
            ],
        cSettings: [
            .headerSearchPath("."),
            .headerSearchPath("Specs"),
            .headerSearchPath("../Masonry"),
            .headerSearchPath("../Masonry/include"),
        ]
    ),

    // ── Swift Tests: MasonrySwift 新增 API 测试 ──
    .testTarget(
        name: "MasonrySwiftTests",
        dependencies: ["Masonry", "MasonrySwift"],
        path: "Tests/MasonrySwiftTests"
    ),
]

let package = Package(
    name: "Masonry",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16)
    ],
    products: products,
    targets: targets,
    swiftLanguageModes: [.v5]
)
