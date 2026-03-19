---
name: masonry
description: |
  Masonry 约束 DSL 专家技能。当用户在 iOS/macOS/tvOS 项目中使用 Masonry（或 SnapKit 的 ObjC 前身）时，使用此 skill 来：
  - **生成约束代码**：根据布局需求（"让视图填充父视图"、"两个按钮水平等间距分布"）生成 ObjC 或 Swift 的 Masonry 代码
  - **解释约束代码**：将 mas_makeConstraints 块的含义翻译成自然语言
  - **调试约束冲突**：分析 Xcode 控制台的 "Unable to simultaneously satisfy constraints" 错误，找出冲突原因并给出修复方案
  - **最佳实践建议**：在 makeConstraints / updateConstraints / remakeConstraints / 约束优先级 / safe area / 多视图分布等场景提供正确用法

  凡是用户提到 Masonry、mas_makeConstraints、MASConstraint、UIView 布局、NSLayoutConstraint、自动布局约束生成等，都应触发此 skill。
---

# Masonry 约束专家

Masonry 是一个 ObjC 编写的 AutoLayout DSL，通过链式语法封装 `NSLayoutConstraints`，同时提供 Swift 包装层（`MasonrySwift` 模块）。

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

> **关键区别**：Swift 封装层（`MASSwiftMakerProxy`）使得 `make` 是**非可选值**，方法直接调用，**不需要 `?` 和 `()()` 双括号**。

```swift
import MasonrySwift

// ✅ 正确写法：make 是 MASSwiftMakerProxy，非可选，方法直接调用
view.mas.makeConstraints { make in
    // 方法链式风格
    make.top.equalTo(superview.mas.top).offset(20)
    make.left.right.equalTo(superview).insets(.init(top: 0, left: 16, bottom: 0, right: 16))
    make.height.equalTo(44)
    make.size.equalTo(CGSize(width: 100, height: 50))   // 直接传 CGSize，无需宏

    // 运算符风格（更简洁，推荐）
    make.top == superview.mas.top + 20
    make.left == superview.mas.left + 16
    make.width >= 100                         // greaterThanOrEqualTo
    make.width == superview.mas.width * 0.5   // multiplier

    // Safe Area（iOS 11+）
    make.top == superview.mas.safeAreaTop
    make.bottom == superview.mas.safeAreaBottom

    // 优先级：~ 运算符
    make.width == 200 ~ .defaultHigh
    make.height == 44 ~ 750
}

view.mas.updateConstraints { make in ... }
view.mas.remakeConstraints { make in ... }

// 等价简写（UIView 扩展方法，与 ObjC API 命名对齐）
view.masMakeConstraints { make in
    make.edges.equalTo(superview).inset(16)
}
```

**❌ 旧式写法（不要使用）**——这是直接调用 ObjC 桥接时的写法，已被 `MASSwiftMakerProxy` 取代：

```swift
// ❌ 错误：make 是可选的，方法后还需额外 () 调用
view.mas_makeConstraints { make in
    make?.top.equalTo()(superview?.mas_top)?.offset()(20)   // 双括号 ()() 写法
    make?.size.equalTo()(CGSize(width: 48, height: 48))
}
```

### 常见布局模式

| 需求 | ObjC 代码 |
|------|-----------|
| 填充父视图 | `make.edges.equalTo(superview)` |
| 四边内缩 10pt | `make.edges.equalTo(superview).insets(UIEdgeInsetsMake(10,10,10,10))` |
| 固定宽高 | `make.size.mas_equalTo(CGSizeMake(100, 44))` |
| 居中 | `make.center.equalTo(superview)` |
| 水平居中偏上 20pt | `make.centerX.equalTo(superview); make.centerY.equalTo(superview).offset(-20)` |
| 紧跟另一个视图右侧 | `make.left.equalTo(otherView.mas_right).offset(8)` |
| 同宽 | `make.width.equalTo(otherView)` |
| 宽度为父视图 50% | `make.width.equalTo(superview).multipliedBy(0.5)` |
| 固定在 Safe Area 内 | `make.top.equalTo(self.mas_safeAreaLayoutGuideTop)` (iOS 11+) |
| 最大宽度 300 | `make.width.lessThanOrEqualTo(@300)` |

---

## 二、代码解释

当用户粘贴 Masonry 代码要求解释时：

1. 逐行翻译成自然语言布局描述（"视图的 top 等于父视图 top + 20pt"）
2. 指出组合约束展开的含义（`make.edges` = top + left + bottom + right）
3. 说明实际效果和注意事项（例如 `offset` 对 bottom/right 的正负含义）

**注意方向约定**：
- `make.bottom.equalTo(superview.mas_bottom).offset(-10)` → 底部**向上**偏移 10pt（远离边缘需传负值）
- `make.right.equalTo(superview.mas_right).offset(-10)` → 右边距 10pt

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
| `NSAutoresizingMaskLayoutConstraint` 出现 | 某视图未设 `translatesAutoresizingMaskIntoConstraints = NO` | 手动设置或通过 Masonry 创建约束 |
| `mas_remakeConstraints` 后仍有旧约束 | 旧约束是在 Masonry 范围外手动添加的 | 手动移除旧约束 |
| 动画约束冲突 | `layoutIfNeeded` 在 `mas_updateConstraints` 之前调用 | 先更新约束，再调用 `layoutIfNeeded` |
| 约束 constant 不符合预期 | `offset` 方向理解有误 | 检查 bottom/trailing 的符号 |

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

| 场景 | 推荐 API |
|------|----------|
| 视图首次布局 | `mas_makeConstraints:` |
| 只需更新位移/大小数值（constant） | `mas_updateConstraints:` |
| 需要彻底改变约束结构 | `mas_remakeConstraints:` |
| 动画过渡 | `mas_updateConstraints:` + `[UIView animateWithDuration:...]` |

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

// Swift
make.top == superview.mas.safeAreaTop
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
// 等间距水平分布
[@[view1, view2, view3] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
    withFixedSpacing:10 leadSpacing:16 tailSpacing:16];
[@[view1, view2, view3] mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(container);
    make.height.equalTo(@44);
}];
```

### 推荐约束位置

- **创建视图**：在 `init` / `viewDidLoad` 中
- **添加/更新约束**：在 `updateConstraints` 中（配合 `setNeedsUpdateConstraints`）
- **不要**在 `layoutSubviews` / `viewDidLayoutSubviews` 中创建约束

---

## ObjC 宏 → Swift 对照

ObjC 宏在 Swift 中不可用，`MASSwiftConstraintProxy` 提供等价的类型安全替代：

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

- **代码生成**：给出完整可运行的约束块，注释说明每行用途
- **代码解释**：先给出自然语言总结，再逐行分析
- **调试**：先定位问题根源，再给出最小化修复方案
- **最佳实践**：给出具体代码示例，避免仅描述原则
