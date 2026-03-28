**[English Changelog](CHANGELOG.md)**

v1.3.2
======

#### - 新增 Apple 隐私清单（PrivacyInfo.xcprivacy）

添加 `PrivacyInfo.xcprivacy` 以符合 Apple 隐私清单要求（WWDC23 引入）。该清单声明 Masonry 不进行用户追踪、不收集用户数据、不访问任何隐私敏感 API。SPM（`Package.swift`）和 CocoaPods（`Masonry.podspec`）现在均会自动打包此文件。

#### - 新增 Swift Xcode 代码片段

在 `CodeSnippets/` 目录中新增三个 Swift DSL 的 Xcode 代码片段：

| 补全前缀 | 说明 |
|---|---|
| `mas_swift_make` | `view.mas.makeConstraints { make in … }` |
| `mas_swift_remake` | `view.mas.remakeConstraints { make in … }` |
| `mas_swift_update` | `view.mas.updateConstraints { make in … }` |

将它们复制到 `~/Library/Developer/Xcode/UserData/CodeSnippets/` 即可在 Xcode 中启用自动补全。

#### - 升级 GitHub Issue 模板

将旧的 `ISSUE_TEMPLATE.md` 替换为结构化的 GitHub YAML 表单模板（`bug_report.yml` 和 `feature_request.yml`），提供平台、版本、集成方式、复现步骤等引导式填写字段。

#### - 清理遗留文件

移除了 SPM 迁移前遗留的过时文件：
* `Masonry/Info.plist` — 不再需要；SPM 会自动生成 bundle 信息。
* `Tests/MasonryTestsLoader/` — 旧的测试宿主应用，已被 SPM 测试目标替代。
* `Tests/GcovTestObserver.m` — 已弃用的 gcov 代码覆盖率集成。
* `Tests/MasonryTests-Info.plist` — 旧的测试 bundle plist。
* `Tests/NSObject+MASSubscriptSupport.h` — 未使用的测试辅助文件。
* 移除了 podspec 中多余的 `TARGET_OS_IOS` / `TARGET_OS_TV` PCH 宏定义。
* 清理了 `.gitignore` 中的重复条目。

#### - `key` 方法签名变更（API 变更）

`MASConstraint` 的 `.key()` 方法参数类型从 `NSString *` 放宽为 `id _Nullable`，现在可以传入任意对象（如 `NSNumber`、自定义对象等）作为约束的调试标识，内部通过 `-description` 转换为字符串。传入 `nil` 时安全处理不会崩溃。

```objc
// 之前：仅接受 NSString
make.top.equalTo(superview).key(@"topPin");

// 现在：接受任意对象
make.top.equalTo(superview).key(@"topPin");       // NSString — 行为不变
make.top.equalTo(superview).key(@(340954));        // NSNumber — mas_key 为 "340954"
make.top.equalTo(superview).key(someObject);       // 任意对象 — 使用 -description
```

Swift 端 `MASSwiftConstraintProxy` 的 `.key(_:)` 方法同步简化，直接透传 `Any?` 给 ObjC 层处理，`labeled(_:)` 方法也统一复用 `key(_:)` 实现。新增了对应的单元测试覆盖 `NSNumber`、`NSString`、`nil` 及多次覆盖设置等场景。


v1.3.1
======

#### - 新增 MASConstraintConvertible 协议

引入 `MASConstraintConvertible` 协议，作为 `equalTo` / `greaterThanOrEqualTo` / `lessThanOrEqualTo` 接受参数类型的形式契约。原本接受裸 `id` 的方法签名现在改为 `id<MASConstraintConvertible>`，使合法的约束目标类型（`MASViewAttribute`、`UIView/NSView`、`NSValue/NSNumber`、`NSArray`）在编译时得到明确声明，提升类型安全性。

#### - Debug 信息增强

`mas_equalTo()`、`mas_greaterThanOrEqualTo()`、`mas_lessThanOrEqualTo()` 宏现在自动将调用处的文件名和行号嵌入到约束的 `mas_key` 中，从而使 Xcode 控制台输出的约束冲突日志能够精确定位到源代码位置。同时新增 `equalToWithLocation:file:line:`、`greaterThanOrEqualToWithLocation:file:line:`、`lessThanOrEqualToWithLocation:file:line:` 方法供高级使用。

Swift 端的 `equalTo(_:)`、`greaterThanOrEqualTo(_:)`、`lessThanOrEqualTo(_:)` 也同步升级，自动捕获 `#fileID` 和 `#line` 以提供更清晰的运行时断言信息。


v1.3.0
======

#### - MasonrySwift API 全面对齐 SnapKit

重构 `MasonrySwift` 模块，使其 API 风格、属性命名与 SnapKit 保持一致，降低两者混用项目的学习成本。

#### - 新增 equalToSuperView 便捷方法

为常见的"与父视图等值"约束提供了 `equalToSuperView` 快捷方式。

#### - 性能优化

参考社区反馈（[SnapKit/Masonry#578](https://github.com/SnapKit/Masonry/issues/578)），对约束安装的内部遍历逻辑进行了性能优化。

#### - 迁移至 GitHub Actions

CI/CD 流水线从 Travis CI 迁移到 GitHub Actions；Example 工程迁移为 Swift Package 格式。


v1.2.3
======

#### - 目录结构调整

对仓库目录结构进行整理，使公共头文件和源文件的组织更清晰规范。


v1.2.2
======

#### - 修复圈复杂度问题

重构了圈复杂度过高的方法，提升代码可维护性。


v1.2.1
======

#### - 新增 MASAttributeOffset 运算符

添加 `MASAttributeOffset` 运算符，简化带偏移量的约束写法。

#### - 新增 SKILL.md

添加 Masonry 约束专家技能文档。


v1.2.0
======

#### - Swift Package Manager 支持

新增 SPM 集成支持，通过 `Package.swift` 提供 `Masonry` 和 `MasonrySwift` 两个库产品，支持 iOS 16+ / macOS 13+ / tvOS 16+。

#### - Swift 强化支持

深度强化 `MasonrySwift` 模块，提供完全原生的 Swift DSL，包括运算符重载（`==`、`>=`、`<=`、`~`）和 `view.mas.makeConstraints` 入口点，替代 Swift 中不可用的 ObjC 宏。

#### - 现代化改造

将 ObjC 代码现代化，采用 Xcode 推荐的 `NSLayoutConstraint` activate/deactivate API。


v1.0.2
======

* 修复数组类型约束使用 greaterThanOrEqualTo / lessThanOrEqualTo 的 bug（[#377](https://github.com/SnapKit/Masonry/pull/377)）
* 修复 Podfile 导致示例工程无法运行的 bug（[#374](https://github.com/SnapKit/Masonry/pull/374)）
* 提升视图分布（view distribution）性能（[#362](https://github.com/SnapKit/Masonry/pull/362)）
* 取消共享 Pod scheme（[#352](https://github.com/SnapKit/Masonry/pull/352)）


v1.0.1
======

#### - 新增 first/last baseline 支持

新增对 `NSLayoutAttributeFirstBaseline` 和 `NSLayoutAttributeLastBaseline` 两个属性的支持。


v1.0.0
======

#### - 正式发布 v1.0.0

修复了 install/uninstall 与 activate/deactivate 之间的若干问题，并将项目文件现代化。


v0.6.4
======

#### - 新增 tvOS 支持


v0.6.3
======

#### - 新增视图分布（view distribution）支持（[pingyourid](https://github.com/pingyourid)）

https://github.com/SnapKit/Masonry/pull/225


v0.6.2
======

#### - 新增 iOS 8 margin 属性支持（[CraigSiemens](https://github.com/CraigSiemens)）

https://github.com/SnapKit/Masonry/pull/163

#### - 新增 leading / trailing insets 支持（[montehurd](https://github.com/montehurd)）

https://github.com/SnapKit/Masonry/pull/168

#### - 新增 Carthage 支持（[erichoracek](https://github.com/erichoracek)）

https://github.com/SnapKit/Masonry/pull/182

#### - 修复 updateConstraints 的内存占用问题


v0.6.1
======

#### - 修复在关闭 NSAssert 时编译产生的未使用变量警告

#### - 新增等比适配（aspect fit）示例（[kouky](https://github.com/kouky)）

https://github.com/SnapKit/Masonry/pull/148


v0.6.0
======

#### - 改善 iOS 8 支持

iOS 8 起 `NSLayoutConstraint` 提供了 `active` 属性，可以直接激活/停用约束而无需寻找最近公共父视图。

#### - 在测试工程中新增 iPhone 6 / iPhone 6+ 支持


v0.5.3
======

#### - 修复在 Xcode 6 beta 下的编译错误

https://github.com/Masonry/Masonry/pull/84


v0.5.2
======

#### - 修复 Shorthand view additions 模式下的编译警告

https://github.com/cloudkite/Masonry/issues/71


v0.5.1
======

#### - 修复在 Objective-C++ 环境下的编译错误（[nickynick](https://github.com/nickynick)）

https://github.com/cloudkite/Masonry/pull/69


v0.5.0
======

#### - 修复 `mas_updateConstraints` 的 bug（[Rolken](https://github.com/Rolken)）

之前未检查约束关系是否一致。
https://github.com/cloudkite/Masonry/pull/65

#### - 新增 `mas_remakeConstraints`（[nickynick](https://github.com/nickynick)）

与 `mas_updateConstraints` 类似，但会先移除视图上所有已安装的 Masonry 约束，再重新创建，适合需要彻底改变约束结构的场景。

https://github.com/cloudkite/Masonry/pull/63

#### - 新增基本类型/结构体的自动装箱（Autoboxing）（[nickynick](https://github.com/nickynick)）

自动装箱允许直接传入基本类型和结构体来设置等值关系和偏移量：

```obj-c
make.top.mas_equalTo(42);
make.height.mas_equalTo(20);
make.size.mas_equalTo(CGSizeMake(50, 100));
make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 10, 0));
make.left.mas_equalTo(view).mas_offset(UIEdgeInsetsMake(10, 0, 10, 0));
```

默认情况下这些宏带 `mas_` 前缀。若需使用不带前缀的版本，需在引入 Masonry.h 之前定义 `MAS_SHORTHAND_GLOBALS`（例如在 Prefix.pch 中）。

https://github.com/cloudkite/Masonry/pull/62

#### - 新增视图属性链式调用

组合约束非常适合一次定义多个属性，例如让 top、left、bottom、right 都等于 `superview`：

```obj-c
make.edges.equalTo(superview).insets(padding);
```

但如果只有三条边等于 `superview`，之前需要重复很多代码：

```obj-c
make.left.equalTo(superview).insets(padding);
make.right.equalTo(superview).insets(padding);
make.bottom.equalTo(superview).insets(padding);
// top 需要等于另一个视图
make.top.equalTo(otherView).insets(padding);
```

现在可以通过链式调用提升可读性：

```obj-c
make.left.right.and.bottom.equalTo(superview).insets(padding);
make.top.equalTo(otherView).insets(padding);
```

https://github.com/cloudkite/Masonry/pull/56


v0.4.0
=======

#### - 修复 Xcode 自动补全支持（[nickynick](https://github.com/nickynick)）

***破坏性变更***

如果你持有了 Masonry 约束的实例：

```obj-c
// 在公开/私有接口中
@property (nonatomic, strong) id<MASConstraint> topConstraint;
```

需要将其改为：

```obj-c
// 在公开/私有接口中
@property (nonatomic, strong) MASConstraint *topConstraint;
```

Masonry 改用抽象基类（而非协议）来表示约束，以支持 Xcode 自动补全。详见 http://stackoverflow.com/questions/14534223/


v0.3.2
=======

#### - 新增 Mac OSX animator proxy 支持（[pfandrade](https://github.com/pfandrade)）

```objective-c
self.leftConstraint.animator.offset(20);
```

#### - 新增 NSLayoutConstraint constant 代理的 setter 方法（`offset`、`centerOffset`、`insets`、`sizeOffset`）

现在可以用更自然的语法更新这些值：

```objective-c
self.edgesConstraint.insets(UIEdgeInsetsMake(20, 10, 15, 5));
```

可以写成：

```objective-c
self.edgesConstraint.insets = UIEdgeInsetsMake(20, 10, 15, 5);
```


v0.3.1
=======

#### - 支持对数组中的多个视图应用相同约束（[danielrhammond](https://github.com/danielrhammond)）

```objective-c
[@[view1, view2, view3] mas_makeConstraints:^(MASConstraintMaker *make) {
    make.baseline.equalTo(superView.mas_centerY);
    make.width.equalTo(@100);
}];
```


v0.3.0
=======

#### - 新增 `- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *))block`

尽量更新已有约束，若找不到匹配项则新增。更便于在 `UIView` 的 `- (void)updateConstraints` 方法中使用 Masonry（苹果推荐在此方法中添加/更新约束）。

#### - 为 iOS 7 更新了示例，并新增了若干示例。

#### - 为 `MASViewAttribute` 添加了 `-isEqual:` 和 `-hash` 方法（[CraigSiemens](https://github.com/CraigSiemens)）。
