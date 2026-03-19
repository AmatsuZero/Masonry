# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目简介

Masonry 是一个 Objective-C 编写的 iOS/macOS/tvOS 自动布局 DSL 库，通过链式语法封装 `NSLayoutConstraints` API，同时提供现代 Swift 支持层。

## 构建与测试

### 环境准备

```bash
pod install  # 安装 CocoaPods 依赖，生成 .xcworkspace
```

### 构建

```bash
# iOS 框架
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry iOS' \
  -configuration Debug -sdk iphonesimulator clean build

# macOS 框架
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry OSX' \
  -configuration Debug clean build

# SPM
swift build
```

### 运行测试

```bash
# 全量测试
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry iOS Tests' \
  -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0' clean test

# SPM 测试
swift test
```

## 代码架构

### 核心设计模式

库采用**块作用域 + 方法链式调用**的 DSL 模式：

```objc
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(superview);
    make.size.equalTo(CGSizeMake(100, 50));
}];
```

### 关键组件及职责

| 组件 | 职责 |
|------|------|
| `View+MASAdditions` | 对外主 API：`mas_makeConstraints:`、`mas_updateConstraints:`、`mas_remakeConstraints:` |
| `MASConstraintMaker` | 约束工厂，在块内收集约束，最终批量安装 |
| `MASConstraint`（抽象） | 链式约束接口，定义 `.top`、`.equalTo()`、`.offset()` 等链式方法 |
| `MASViewConstraint` | 单属性约束实现（top/left/width 等） |
| `MASCompositeConstraint` | 多属性组合约束（edges/size/center），展开后生成多个 `MASViewConstraint` |
| `MASViewAttribute` | `(视图, NSLayoutAttribute)` 二元组，是约束的目标/来源 |
| `MASLayoutConstraint` | `NSLayoutConstraint` 子类，携带 `mas_key` 用于调试标识 |
| `MASUtilities.h` | 跨平台宏（`MAS_VIEW`、`MASEdgeInsets`）及值装箱工具 |
| `Masonry+Swift.swift` | Swift 包装层：`MASSwiftConstraintProxy` 替代 ObjC 宏，提供类型安全 API |

### 约束安装流程

1. 调用 `mas_makeConstraints:` → 创建 `MASConstraintMaker`
2. 块内链式调用 → 构建 `MASViewConstraint`/`MASCompositeConstraint` 集合
3. 块结束 → `MASConstraintMaker` 调用 `install` 将约束转换为 `NSLayoutConstraint` 并激活

### Swift 互操作

ObjC 宏（`mas_equalTo`、`mas_offset`）在 Swift 中不可用，由 `MASSwiftConstraintProxy` 代替：

```swift
view.mas_makeConstraints { make in
    make?.top.equalTo()(superview?.mas_top)
    make?.left.offset()(16)
}
```

### 平台抽象

通过 `MASUtilities.h` 中的条件编译宏统一 iOS/macOS/tvOS：
- `MAS_VIEW` → `UIView` / `NSView`
- `MASEdgeInsets` → `UIEdgeInsets` / `NSEdgeInsets`

### 测试规范

测试位于 `Tests/Specs/`，使用 XCTest + Expecta 断言库 + BDD 风格宏（`SpecBegin`/`SpecEnd`、`it()`/`describe()`）。每个核心类对应一个 `*Spec.m` 文件。
