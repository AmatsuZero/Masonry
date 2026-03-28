// swift-tools-version: 6.0

// Examples.swiftpm — Masonry iOS 示例 App（Swift Playground 包）
// 在 Xcode 中直接打开此 Package.swift 即可运行示例 App

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "MasonryExamples",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "MasonryExample",
            targets: ["AppModule"],
            bundleIdentifier: "com.masonry.examples",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .tv),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        // 依赖根目录的 Masonry 包（本地路径）
        .package(path: ".."),
    ],
    targets: [
        // ── ObjC Examples: ObjC 示例 View 库 ──
        .target(
            name: "MasonryObjCExamples",
            dependencies: [
                .product(name: "Masonry", package: "Masonry"),
            ],
            path: "ObjCExamples",
            publicHeadersPath: "include",
            cSettings: [
                .define("MAS_SHORTHAND"),
                .define("MAS_SHORTHAND_GLOBALS"),
                .headerSearchPath("."),
                .headerSearchPath("include"),
            ]
        ),

        // ── Swift Example: MasonrySwift 使用示例 ──
        .target(
            name: "MasonrySwiftExample",
            dependencies: [
                .product(name: "Masonry", package: "Masonry"),
                .product(name: "MasonrySwift", package: "Masonry"),
            ],
            path: "SwiftExample"
        ),

        // ── AppModule: iOS 示例 App 入口（SwiftUI）──
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "Masonry", package: "Masonry"),
                .product(name: "MasonrySwift", package: "Masonry"),
                "MasonryObjCExamples",
                "MasonrySwiftExample",
            ],
            path: "AppModule"
        ),
    ],
    swiftLanguageModes: [.v5]
)
