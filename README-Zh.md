# Masonry [![CI](https://github.com/AmatsuZero/Masonry/actions/workflows/ci.yml/badge.svg)](https://github.com/AmatsuZero/Masonry/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/AmatsuZero/Masonry/branch/master/graph/badge.svg)](https://codecov.io/gh/AmatsuZero/Masonry) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![Pod Version](https://img.shields.io/cocoapods/v/Masonry.svg?style=flat)

**[English](README.md)**

Masonry 是一个轻量级的布局框架，通过更简洁的语法封装 AutoLayout。它提供了链式 DSL 来描述 `NSLayoutConstraints`，使布局代码更加简洁易读。

Masonry 支持 **iOS**、**macOS** 和 **tvOS**，并通过 `MasonrySwift` 模块提供原生 **Swift DSL**。

## 为什么选择 Masonry？

使用原生 `NSLayoutConstraint` API 创建约束非常冗长且难以阅读：

```obj-c
[superview addConstraints:@[
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:padding.top],
    // ... 仅仅是四边约束就需要更多代码
]];
```

使用 Masonry，同样的布局只需一行代码：

```obj-c
[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).with.insets(padding);
}];
```

Masonry 还会自动处理 `translatesAutoresizingMaskIntoConstraints` 和约束的安装。

## 安装

### Swift Package Manager（推荐）

添加到你的 `Package.swift`：

```swift
dependencies: [
    .package(url: "https://github.com/AmatsuZero/Masonry.git", from: "1.3.0")
]
```

提供两个库产品：
- **`Masonry`** — Objective-C 核心库
- **`MasonrySwift`** — Swift 原生 DSL（依赖 `Masonry`）

### CocoaPods

```ruby
# 仅 Objective-C
pod 'Masonry'

# Objective-C + Swift DSL
pod 'Masonry/Swift'
```

### Carthage

```
github "AmatsuZero/Masonry"
```

## 使用方法（Objective-C）

### 创建约束

```obj-c
UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);

[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.mas_top).with.offset(padding.top);
    make.left.equalTo(superview.mas_left).with.offset(padding.left);
    make.bottom.equalTo(superview.mas_bottom).with.offset(-padding.bottom);
    make.right.equalTo(superview.mas_right).with.offset(-padding.right);
}];
```

或者更简洁的写法：

```obj-c
[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).with.insets(padding);
}];
```

### 等式关系

| 方法 | NSLayoutRelation |
|------|-----------------|
| `.equalTo` | `NSLayoutRelationEqual` |
| `.lessThanOrEqualTo` | `NSLayoutRelationLessThanOrEqual` |
| `.greaterThanOrEqualTo` | `NSLayoutRelationGreaterThanOrEqual` |

这些方法接受以下参数类型：

#### 1. MASViewAttribute

```obj-c
make.centerX.lessThanOrEqualTo(view2.mas_left);
```

| MASViewAttribute | NSLayoutAttribute |
|-----------------|-------------------|
| `view.mas_left` | `NSLayoutAttributeLeft` |
| `view.mas_right` | `NSLayoutAttributeRight` |
| `view.mas_top` | `NSLayoutAttributeTop` |
| `view.mas_bottom` | `NSLayoutAttributeBottom` |
| `view.mas_leading` | `NSLayoutAttributeLeading` |
| `view.mas_trailing` | `NSLayoutAttributeTrailing` |
| `view.mas_width` | `NSLayoutAttributeWidth` |
| `view.mas_height` | `NSLayoutAttributeHeight` |
| `view.mas_centerX` | `NSLayoutAttributeCenterX` |
| `view.mas_centerY` | `NSLayoutAttributeCenterY` |
| `view.mas_baseline` | `NSLayoutAttributeBaseline` |

#### 2. UIView / NSView

```obj-c
// 以下两个约束完全等价
make.left.greaterThanOrEqualTo(label);
make.left.greaterThanOrEqualTo(label.mas_left);
```

#### 3. NSNumber

```obj-c
// width >= 200 && width <= 400
make.width.greaterThanOrEqualTo(@200);
make.width.lessThanOrEqualTo(@400);
```

对于对齐属性，传入 `NSNumber` 会创建相对于父视图的约束：

```obj-c
// 创建 view.left = view.superview.left + 10
make.left.lessThanOrEqualTo(@10);
```

#### 使用基本类型的自动装箱

使用 `mas_` 前缀的宏可以直接传入基本类型和结构体：

```obj-c
make.top.mas_equalTo(42);
make.height.mas_equalTo(20);
make.size.mas_equalTo(CGSizeMake(50, 100));
make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 10, 0));
```

> 在导入 Masonry 之前定义 `MAS_SHORTHAND_GLOBALS` 可以使用不带前缀的版本。

#### 4. NSArray

```obj-c
make.height.equalTo(@[view1.mas_height, view2.mas_height]);
make.left.equalTo(@[view1, @100, view3.right]);
```

### 属性链式调用

```obj-c
// 将 left、right 和 bottom 设置为与父视图相同，top 设置为另一个视图
make.left.right.and.bottom.equalTo(superview);
make.top.equalTo(otherView);
```

### 优先级

```obj-c
make.left.greaterThanOrEqualTo(label.mas_left).with.priorityLow();
make.top.equalTo(label.mas_top).with.priority(600);
```

### 更新与重建约束

```obj-c
// 更新已有约束（如果不存在则创建）
[view1 mas_updateConstraints:^(MASConstraintMaker *make) {
    make.leading.equalTo(superview).offset(newPadding);
}];

// 移除所有已有约束并创建新约束
[view1 mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview).insets(newPadding);
}];
```

### 持有约束引用

```obj-c
@property (nonatomic, strong) MASConstraint *topConstraint;

[view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    self.topConstraint = make.top.equalTo(superview.mas_top).with.offset(padding.top);
    make.left.equalTo(superview.mas_left).with.offset(padding.left);
}];

// 之后可以更新约束
[self.topConstraint uninstall];
```

## 使用方法（Swift）

`MasonrySwift` 模块提供了类型安全的 Swift 原生 DSL，替代 ObjC 宏：

```swift
import MasonrySwift

view.mas.makeConstraints { make in
    make.top.equalTo(superview.mas_top).offset(20)
    make.left.right.equalTo(superview).inset(16)
    make.height.equalTo(44)
}

// 更新约束
view.mas.updateConstraints { make in
    make.top.equalTo(superview).offset(newValue)
}

// 重建约束
view.mas.remakeConstraints { make in
    make.edges.equalTo(superview).inset(padding)
}
```

### Swift 运算符

Swift 模块还支持基于运算符的约束创建：

```swift
view.mas.makeConstraints { make in
    make.top == superview.mas_top + 20
    make.left >= superview.mas_left + 16
    make.width <= 200
    make.height == 44 ~ .defaultHigh  // 带优先级
}
```

## 示例

查看仓库中的 **Examples.swiftpm** Swift Playground 项目，包含以下交互式示例：

- 基础约束
- 动画
- 滚动视图
- 等比适配
- 安全区域布局指南
- 视图分布
- 更多...

使用 Xcode 打开：

```bash
open Examples.swiftpm
```

## 许可证

Masonry 基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
