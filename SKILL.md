---
name: masonry
description: |
  Masonry Auto Layout DSL expert skill. Use this skill when users work with Masonry in iOS/macOS/tvOS projects to:
  - **Generate constraint code**: Produce ObjC or Swift Masonry code from layout requirements ("fill parent view", "distribute buttons horizontally with equal spacing")
  - **Explain constraint code**: Translate mas_makeConstraints blocks into natural language descriptions
  - **Debug constraint conflicts**: Analyze Xcode console "Unable to simultaneously satisfy constraints" errors, identify root causes and provide fixes
  - **Best practice guidance**: Advise on makeConstraints / updateConstraints / remakeConstraints / priority / safe area / view distribution patterns

  Trigger keywords: Masonry, mas_makeConstraints, MASConstraint, MASConstraintMaker, UIView layout, NSLayoutConstraint, Auto Layout constraint generation, MasonrySwift, view.mas.makeConstraints
---

# Masonry 约束专家

Masonry 是一个 ObjC 编写的 AutoLayout DSL，通过链式语法封装 `NSLayoutConstraints`，同时提供原生 Swift 支持层（`MasonrySwift` 模块）。

## 项目概览

| 模块 | 语言 | 说明 |
|------|------|------|
| `Masonry` | Objective-C | 核心约束 DSL（`mas_makeConstraints:` 等） |
| `MasonrySwift` | Swift | 类型安全的 Swift DSL 与运算符（依赖 `Masonry`） |

**支持平台**：iOS 16+ / macOS 13+ / tvOS 16+（SPM）；iOS 9+ / macOS 10.13+ / tvOS 9+（CocoaPods）

**集成方式**：
- **Swift Package Manager**（推荐）：`https://github.com/AmatsuZero/Masonry.git`，from: `"1.3.0"`
- **CocoaPods**：`pod 'Masonry'`（ObjC）/ `pod 'Masonry/Swift'`（ObjC + Swift DSL）
- **Carthage**：`github "AmatsuZero/Masonry"`

---

## 一、代码生成

**优先输出 ObjC 代码**；若用户明确使用 Swift 项目或询问 Swift 用法，则输出 Swift 版本（或同时提供两者）。

### ObjC 语法速查

```objc
// 1. 基础方法
[view mas_makeConstraints:^(MASConstraintMaker *make) { ... }];   // 首次创建
[view mas_updateConstraints:^(MASConstraintMaker *make) { ... }]; // 只更新 constant
[view mas_remakeConstraints:^(MASConstraintMaker *make) { ... }]; // 移除并重建

// 2. 关系运算符（接受 MASViewAttribute / UIView / NSNumber / NSArray）
make.top.equalTo(superview.mas_top).offset(20);
make.width.greaterThanOrEqualTo(@200);
make.left.lessThanOrEqualTo(label.mas_left);

// 3. 常用缩写宏（需 #define MAS_SHORTHAND_GLOBALS 才可省略 mas_ 前缀）
make.top.mas_equalTo(42);                         // 等价于 equalTo(@42)
make.left.mas_equalTo(view).mas_offset(UIEdgeInsetsMake(10,0,10,0));

// 4. 组合约束
make.edges.equalTo(superview).insets(UIEdgeInsetsMake(10, 10, 10, 10));
make.size.equalTo(CGSizeMake(100, 50));
make.center.equalTo(superview);

// 5. 优先级
make.width.equalTo(@300).priorityLow();
make.height.equalTo(@44).priority(600);

// 6. 语义助词（无实际作用，提升可读性）
make.top.and.left.equalTo(superview);
make.left.equalTo(superview).with.offset(16);

// 7. 调试命名
make.top.equalTo(superview.mas_top).offset(20).key(@"topPin");
// 或批量命名：
MASAttachKeys(titleLabel, avatarView);

// 8. 多视图等间距分布
[@[btn1, btn2, btn3] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
    withFixedSpacing:10 leadSpacing:16 tailSpacing:16];
```

### Swift 语法速查（MasonrySwift 模块）

> **核心区别**：`MasonrySwift` 模块提供了完全原生的 Swift DSL，替代了 ObjC 中不可用的宏（`mas_equalTo`、`mas_offset` 等）。入口点是 `view.mas.makeConstraints { make in ... }`，其中 `make` 是 `MASSwiftMakerProxy` 类型（非可选值），方法直接调用，**不需要 `?` 和 `()()` 双括号**。

```swift
import MasonrySwift

// ✅ 正确写法：方法链式风格
view.mas.makeConstraints { make in
    make.top.equalTo(superview.mas.top).offset(20)
    make.left.right.equalTo(superview).insets(.init(top: 0, left: 16, bottom: 0, right: 16))
    make.height.equalTo(44)
    make.size.equalTo(CGSize(width: 100, height: 50))
}

// ✅ 运算符风格（更简洁，推荐）
view.mas.makeConstraints { make in
    make.top == superview.mas.top + 20        // equalTo + offset
    make.left == superview.mas.left + 16
    make.width >= 100                          // greaterThanOrEqualTo
    make.width == superview.mas.width * 0.5    // multiplier

    // Safe Area（iOS 11+）
    make.top == superview.mas.safeAreaTop
    make.bottom == superview.mas.safeAreaBottom

    // 优先级：~ 运算符
    make.width == 200 ~ .defaultHigh
    make.height == 44 ~ 750
}

// 更新与重建
view.mas.updateConstraints { make in ... }
view.mas.remakeConstraints { make in ... }

// 等价简写（UIView 扩展方法，与 ObjC API 命名对齐）
view.masMakeConstraints { make in
    make.edges.equalTo(superview).inset(16)
}
```

**❌ 旧式写法（不要使用）**——直接调用 ObjC 桥接时的写法，已被 `MASSwiftMakerProxy` 取代：

```swift
// ❌ 错误：make 是可选的，方法后还需额外 () 调用
view.mas_makeConstraints { make in
    make?.top.equalTo()(superview?.mas_top)?.offset()(20)   // 双括号 ()() 写法
    make?.size.equalTo()(CGSize(width: 48, height: 48))
}
```

### 常见布局模式

| 需求 | ObjC 代码 | Swift 运算符写法 |
|------|-----------|-----------------|
| 填充父视图 | `make.edges.equalTo(superview)` | `make.edges.equalTo(superview)` |
| 四边内缩 10pt | `make.edges.equalTo(superview).insets(UIEdgeInsetsMake(10,10,10,10))` | `make.edges.equalTo(superview).insets(.init(top:10,left:10,bottom:10,right:10))` |
| 固定宽高 | `make.size.mas_equalTo(CGSizeMake(100, 44))` | `make.size.equalTo(CGSize(width:100, height:44))` |
| 居中 | `make.center.equalTo(superview)` | `make.center.equalTo(superview)` |
| 水平居中偏上 20pt | `make.centerX.equalTo(superview); make.centerY.equalTo(superview).offset(-20)` | `make.centerX == superview; make.centerY == superview - 20` |
| 紧跟另一视图右侧 | `make.left.equalTo(otherView.mas_right).offset(8)` | `make.left == otherView.mas.right + 8` |
| 同宽 | `make.width.equalTo(otherView)` | `make.width == otherView` |
| 宽度为父视图 50% | `make.width.equalTo(superview).multipliedBy(0.5)` | `make.width == superview.mas.width * 0.5` |
| Safe Area 内 | `make.top.equalTo(self.mas_safeAreaLayoutGuideTop)` | `make.top == superview.mas.safeAreaTop` |
| 最大宽度 300 | `make.width.lessThanOrEqualTo(@300)` | `make.width <= 300` |

---

## 二、代码解释

当用户粘贴 Masonry 代码要求解释时：

1. 逐行翻译成自然语言布局描述（"视图的 top 等于父视图 top + 20pt"）
2. 指出组合约束展开的含义（`make.edges` = top + left + bottom + right）
3. 说明实际效果和注意事项（例如 `offset` 对 bottom/right 的正负含义）

**注意方向约定**：
- `make.bottom.equalTo(superview.mas_bottom).offset(-10)` → 底部**向上**偏移 10pt（远离边缘需传负值）
- `make.right.equalTo(superview.mas_right).offset(-10)` → 右边距 10pt
- `make.edges.equalTo(superview).insets(UIEdgeInsetsMake(10, 10, 10, 10))` → 四边各内缩 10pt（`insets` 会自动处理正负号）

---

## 三、调试约束冲突

当用户粘贴 Xcode 控制台的约束冲突错误时：

### 诊断步骤

1. **识别冲突轴**：找出所有 H: (水平) 或 V: (垂直) 同轴约束
2. **找出过约束**：列出所有影响同一属性的约束，计算它们是否矛盾
3. **识别 translatesAutoresizingMask**：`NSAutoresizingMaskLayoutConstraint` 说明有视图忘记设置 `translatesAutoresizingMaskIntoConstraints = NO`（Masonry 会自动处理，但手动创建的视图可能遗漏）
4. **给出修复方案**：降低某个约束优先级、移除冗余约束、或改用 `mas_updateConstraints`

### 常见冲突原因

| 现象 | 原因 | 修复 |
|------|------|------|
| `NSAutoresizingMaskLayoutConstraint` 出现 | 某视图未设 `translatesAutoresizingMaskIntoConstraints = NO` | 手动设置或通过 Masonry 创建约束（Masonry 会自动设置） |
| `mas_remakeConstraints` 后仍有旧约束 | 旧约束是在 Masonry 范围外手动添加的 | 手动移除旧约束 |
| 动画约束冲突 | `layoutIfNeeded` 在 `mas_updateConstraints` 之前调用 | 先更新约束，再调用 `layoutIfNeeded` |
| 约束 constant 不符合预期 | `offset` 方向理解有误 | 检查 bottom/trailing 的符号（需传负值） |
| UIScrollView 内容大小异常 | 内容视图约束不完整，无法推断 contentSize | 确保内容视图四边都与 scrollView 关联，并有明确的宽高 |

### 调试技巧

```objc
// 给视图和约束命名，使控制台输出更清晰
view.mas_key = @"avatarView";
MASAttachKeys(titleLabel, subtitleLabel, containerView);

// 获取特定视图上所有 Masonry 约束
NSArray *constraints = [MASViewConstraint installedConstraintsForView:view];
```

---

## 四、最佳实践

### 选择正确的 API

| 场景 | 推荐 API | 说明 |
|------|----------|------|
| 视图首次布局 | `mas_makeConstraints:` | 创建并安装约束 |
| 只需更新位移/大小数值（constant） | `mas_updateConstraints:` | 匹配已有约束并更新 constant |
| 需要彻底改变约束结构 | `mas_remakeConstraints:` | 先卸载所有 Masonry 约束，再重新创建 |
| 动画过渡 | `mas_updateConstraints:` + `[UIView animateWithDuration:...]` | 在动画块中调用 `layoutIfNeeded` |

### 优先级使用

```objc
// 内容大小优先级（阻止压缩 / 拉伸）
[label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
[label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

// 约束优先级（避免无解冲突）
make.height.equalTo(@44).priorityHigh();       // 高优先级
make.height.greaterThanOrEqualTo(@20);          // 保底
```

### Safe Area（iOS 11+）

```objc
// ObjC（UIViewController 内）
make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
```

```swift
// Swift（MasonrySwift 模块）
make.top == superview.mas.safeAreaTop
make.bottom == superview.mas.safeAreaBottom
```

### 持有约束引用

```objc
@property (nonatomic, strong) MASConstraint *heightConstraint;

[view mas_makeConstraints:^(MASConstraintMaker *make) {
    self.heightConstraint = make.height.equalTo(@44);
}];

// 动态更新
[self.heightConstraint setOffset:100];
[UIView animateWithDuration:0.3 animations:^{ [self.view layoutIfNeeded]; }];
```

### 多视图等间距

```objc
// 等间距水平分布（需先调用分布方法，再设置公共约束）
[@[view1, view2, view3] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
    withFixedSpacing:10 leadSpacing:16 tailSpacing:16];
[@[view1, view2, view3] mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(container);
    make.height.equalTo(@44);
}];
```

### 推荐约束位置

| 位置 | 适合做什么 | 注意事项 |
|------|-----------|---------|
| `init` / `viewDidLoad` | 创建视图 + `mas_makeConstraints` | ✅ 推荐 |
| `updateConstraints` / `updateViewConstraints` | `mas_updateConstraints` | 配合 `setNeedsUpdateConstraints` 触发 |
| `layoutSubviews` / `viewDidLayoutSubviews` | 读取 frame 做非约束操作 | ❌ 不要在此创建/更新约束 |

---

## 五、ObjC 宏 → Swift 对照

ObjC 宏在 Swift 中不可用，`MasonrySwift` 模块提供等价的类型安全替代：

| ObjC 宏写法 | Swift 等价写法 |
|-------------|---------------|
| `make.top.mas_equalTo(42)` | `make.top.equalTo(42)` 或 `make.top == 42` |
| `make.size.mas_equalTo(CGSizeMake(100,50))` | `make.size.equalTo(CGSize(width:100, height:50))` |
| `make.edges.mas_equalTo(UIEdgeInsetsMake(...))` | `make.edges.equalTo(superview).insets(UIEdgeInsets(...))` |
| `make.left.mas_equalTo(view).mas_offset(UIEdgeInsets)` | `make.left.equalTo(view).valueOffset(UIEdgeInsets(...))` |
| `make.width.equalTo(@300).priorityLow()` | `make.width == 300 ~ .defaultLow` |
| `make.width.equalTo(superview).multipliedBy(0.5)` | `make.width == superview.mas.width * 0.5` |

**Swift 中访问 Safe Area 的方式**（通过 `view.mas.safeArea*` 属性）：
```swift
make.top == superview.mas.safeAreaTop       // 对应 mas_safeAreaLayoutGuideTop
make.bottom == superview.mas.safeAreaBottom // 对应 mas_safeAreaLayoutGuideBottom
```

---

## 输出格式要求

- **代码生成**：给出完整可运行的约束块，注释说明每行用途；如果涉及多个视图，说明视图层级关系
- **代码解释**：先给出一句话总结整体布局效果，再逐行分析每条约束的含义
- **调试**：先定位问题根源（哪些约束冲突、在哪个轴上），再给出最小化修复方案（优先降低优先级或移除冗余约束）
- **最佳实践**：给出具体代码示例，避免仅描述原则；同时说明为什么推荐这种做法
- **ObjC vs Swift**：如果用户未指定语言，默认输出 ObjC；如果用户项目中使用了 `import MasonrySwift`，则输出 Swift 运算符风格代码
