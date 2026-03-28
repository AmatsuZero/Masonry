//
//  ConstraintProxy.swift
//  Masonry
//
//  MASConstraint Extension：为 MASConstraint 提供 Swift 友好的链式调用方法
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
#endif

// MARK: - MASConstraint Extension（Swift 友好的链式调用）

extension MASConstraint {

    // MARK: - 关系设置（替代 mas_equalTo / mas_greaterThanOrEqualTo / mas_lessThanOrEqualTo 宏）

    /// 设置约束关系为"等于"
    ///
    /// 替代 ObjC 宏 `mas_equalTo(...)`，自动将值类型包装为 `NSValue`。
    /// 支持传入可选类型（如 `UIView!`），内部会自动解包。
    /// - Parameter value: 约束目标，可以是 `CGFloat`、`CGPoint`、`CGSize`、`MASNativeEdgeInsets`、
    ///   `MASNativeView`、`ViewAttribute` 或其他数值类型
    /// - Parameter file: 调用处文件名（自动捕获，无需手动传入）
    /// - Parameter line: 调用处行号（自动捕获，无需手动传入）
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func equalTo(_ value: Any?,
                        _ file: String = #fileID,
                        _ line: UInt = #line) -> MASConstraint {
        self.equalToWithLocation()(MASConstraint.boxValue(value, file: file, line: line), file, line)
        return self
    }

    /// 设置约束关系为"大于等于"
    ///
    /// 替代 ObjC 宏 `mas_greaterThanOrEqualTo(...)`。
    /// 支持传入可选类型（如 `UIView!`），内部会自动解包。
    /// - Parameter value: 约束目标
    /// - Parameter file: 调用处文件名（自动捕获，无需手动传入）
    /// - Parameter line: 调用处行号（自动捕获，无需手动传入）
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func greaterThanOrEqualTo(_ value: Any?,
                                     _ file: String = #fileID,
                                     _ line: UInt = #line) -> MASConstraint {
        self.greaterThanOrEqualToWithLocation()(MASConstraint.boxValue(value, file: file, line: line), file, line)
        return self
    }

    /// 设置约束关系为"小于等于"
    ///
    /// 替代 ObjC 宏 `mas_lessThanOrEqualTo(...)`。
    /// 支持传入可选类型（如 `UIView!`），内部会自动解包。
    /// - Parameter value: 约束目标
    /// - Parameter file: 调用处文件名（自动捕获，无需手动传入）
    /// - Parameter line: 调用处行号（自动捕获，无需手动传入）
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func lessThanOrEqualTo(_ value: Any?,
                                  _ file: String = #fileID,
                                  _ line: UInt = #line) -> MASConstraint {
        self.lessThanOrEqualToWithLocation()(MASConstraint.boxValue(value, file: file, line: line), file, line)
        return self
    }

    /// 设置约束关系为"等于父视图的对应属性"
    ///
    /// 替代写法 `.equalTo(superview)` 或 `.equalTo(superview.mas_top)` 等，
    /// 直接与父视图的同名属性建立等值约束。
    /// 视图必须已加入视图层级（有父视图），否则触发断言。
    /// - Returns: 当前约束对象，支持链式调用
    ///
    /// - Note: ObjC 已有同名方法 `equalToSuperview`，但返回 `MASConstraint *`。
    ///   此处 Swift Extension 方法与 ObjC 方法签名完全一致，Swift 会优先选择 Extension 版本。
    ///   由于 ObjC 版本已经完成了实际工作，这里无需额外操作。

    /// 设置约束关系为"大于等于父视图的对应属性"
    ///
    /// 对齐 SnapKit 的 `greaterThanOrEqualToSuperview()`。
    /// 直接映射到 Masonry 底层的 `greaterThanOrEqualToSuperview` 方法。
    /// 视图必须已加入视图层级（有父视图），否则触发断言。

    /// 设置约束关系为"小于等于父视图的对应属性"
    ///
    /// 对齐 SnapKit 的 `lessThanOrEqualToSuperview()`。
    /// 直接映射到 Masonry 底层的 `lessThanOrEqualToSuperview` 方法。
    /// 视图必须已加入视图层级（有父视图），否则触发断言。

    // MARK: - 偏移量设置（替代 mas_offset 宏）

    /// 设置约束常量偏移（CGFloat）
    ///
    /// 与 ObjC 的无参 `offset() -> (CGFloat) -> MASConstraint` 构成合法重载。
    /// - Parameter value: 偏移量数值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func offset(_ value: CGFloat) -> MASConstraint {
        self.offset()(value)
        return self
    }

    /// 设置基于值类型的偏移量（替代 ObjC 宏 `mas_offset`）
    ///
    /// 支持 `CGFloat`、`CGPoint`、`CGSize`、`MASNativeEdgeInsets` 等类型，
    /// 自动包装为 `NSValue`。支持传入可选类型，内部会自动解包。
    /// - Parameter value: 偏移量
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func valueOffset(_ value: Any?) -> MASConstraint {
        guard let boxed = MASConstraint.boxValue(value) as? NSValue else {
            assertionFailure("[Masonry] valueOffset: 传入的值无法转换为 NSValue，请检查参数类型")
            return self
        }
        self.valueOffset()(boxed)
        return self
    }

    /// 设置边距偏移（MASEdgeInsets）
    ///
    /// - Parameter insets: 边距值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func insets(_ insets: MASNativeEdgeInsets) -> MASConstraint {
        self.insets()(insets)
        return self
    }

    /// 设置统一的边距偏移
    ///
    /// - Parameter value: 统一的内边距值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func inset(_ value: CGFloat) -> MASConstraint {
        self.inset()(value)
        return self
    }

    /// 设置尺寸偏移（CGSize）
    ///
    /// - Parameter offset: 尺寸偏移量
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func sizeOffset(_ offset: CGSize) -> MASConstraint {
        self.sizeOffset()(offset)
        return self
    }

    /// 设置中心偏移（CGPoint）
    ///
    /// - Parameter offset: 中心点偏移量
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func centerOffset(_ offset: CGPoint) -> MASConstraint {
        self.centerOffset()(offset)
        return self
    }

    // MARK: - 优先级

    /// 设置约束优先级
    ///
    /// 与 ObjC 的无参 `priority() -> (MASLayoutPriority) -> MASConstraint` 构成合法重载。
    /// - Parameter value: 优先级值（0~1000）
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func priority(_ value: Float) -> MASConstraint {
        self.priority()(MASLayoutPriority(rawValue: value))
        return self
    }

    /// 设置约束为低优先级（`UILayoutPriority.defaultLow`）
    ///
    /// ObjC 原始方法已通过 `NS_REFINED_FOR_SWIFT` 重命名为 `__priorityLow`。
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func priorityLow() -> MASConstraint {
        self.__priorityLow()()
        return self
    }

    /// 设置约束为中优先级（500）
    ///
    /// ObjC 原始方法已通过 `NS_REFINED_FOR_SWIFT` 重命名为 `__priorityMedium`。
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func priorityMedium() -> MASConstraint {
        self.__priorityMedium()()
        return self
    }

    /// 设置约束为高优先级（`UILayoutPriority.defaultHigh`）
    ///
    /// ObjC 原始方法已通过 `NS_REFINED_FOR_SWIFT` 重命名为 `__priorityHigh`。
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func priorityHigh() -> MASConstraint {
        self.__priorityHigh()()
        return self
    }

    /// 使用 `MASConstraintPriority` 枚举设置约束优先级
    ///
    /// 对齐 SnapKit 的 `.priority(.high)` 风格。
    ///
    /// ```swift
    /// make.width.equalTo(100).priority(.high)
    /// make.height.equalTo(44).priority(.medium)
    /// ```
    ///
    /// - Parameter priority: 优先级枚举值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func priority(_ priority: MASConstraintPriority) -> MASConstraint {
        self.priority()(MASLayoutPriority(rawValue: priority.value))
        return self
    }

    // MARK: - 乘除

    /// 设置约束乘数
    ///
    /// - Parameter value: 乘数值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func multipliedBy(_ value: CGFloat) -> MASConstraint {
        self.multipliedBy()(value)
        return self
    }

    /// 设置约束除数（内部转换为 1.0/value 的乘数）
    ///
    /// - Parameter value: 除数值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func dividedBy(_ value: CGFloat) -> MASConstraint {
        self.dividedBy()(value)
        return self
    }

    // MARK: - 调试键

    /// 设置约束的调试标识键
    ///
    /// - Parameter value: 用于调试的键值
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func key(_ value: Any?) -> MASConstraint {
        self.key()(value)
        return self
    }

    /// 设置约束的调试标签
    ///
    /// 对齐 SnapKit 的 `labeled(_:)` 方法，用于在调试约束冲突时提供可读标识。
    /// 内部映射到 Masonry 的 `key()` 方法。
    ///
    /// ```swift
    /// make.top.equalToSuperview().labeled("topConstraint")
    /// ```
    ///
    /// - Parameter label: 调试标签字符串
    /// - Returns: 当前约束对象，支持链式调用
    @MainActor
    @discardableResult
    public func labeled(_ label: String) -> MASConstraint {
        key(label)
    }

    // MARK: - 底层约束访问（对齐 SnapKit Constraint.layoutConstraints / isActive）

    /// 获取底层 NSLayoutConstraint 数组
    ///
    /// 对齐 SnapKit 的 `Constraint.layoutConstraints` 属性。
    /// - 对于 `MASViewConstraint`：返回包含单个 `layoutConstraint` 的数组（如已安装）
    /// - 对于 `MASCompositeConstraint`：递归收集所有子约束的底层 NSLayoutConstraint
    /// - 未安装的约束返回空数组
    @MainActor
    public var layoutConstraints: [NSLayoutConstraint] {
        return MASConstraint.collectLayoutConstraints(from: self)
    }

    /// 约束是否处于激活状态
    ///
    /// 对齐 SnapKit 的 `Constraint.isActive` 属性。
    /// - 对于 `MASViewConstraint`：直接返回底层 `isActive` 属性
    /// - 对于 `MASCompositeConstraint`：所有子约束均激活时返回 `true`
    /// - 未安装的约束返回 `false`
    @MainActor
    public var isActive: Bool {
        if let viewConstraint = self as? MASViewConstraint {
            return viewConstraint.layoutConstraint?.isActive ?? false
        }
        if let composite = self as? CompositeConstraint {
            let children = composite.childConstraints as? [MASConstraint] ?? []
            return children.allSatisfy { $0.isActive }
        }
        return false
    }

    /// 递归收集 MASConstraint 树中所有底层 NSLayoutConstraint
    @MainActor
    private static func collectLayoutConstraints(from constraint: MASConstraint) -> [NSLayoutConstraint] {
        if let viewConstraint = constraint as? MASViewConstraint {
            if let lc = viewConstraint.layoutConstraint {
                return [lc]
            }
            return []
        }
        if let composite = constraint as? CompositeConstraint {
            let children = composite.childConstraints as? [MASConstraint] ?? []
            return children.flatMap { collectLayoutConstraints(from: $0) }
        }
        return []
    }

    // MARK: - 外部更新方法（对齐 SnapKit Constraint.updateOffset / updateInsets）

    /// 在约束块外部更新约束的偏移量
    ///
    /// 对齐 SnapKit 的 `Constraint.updateOffset(_:)` 方法。
    /// 可在 `makeConstraints` / `updateConstraints` 块外部直接修改已安装约束的常量值。
    ///
    /// - Parameter offset: 新的偏移量
    @MainActor
    public func updateOffset(_ offset: CGFloat) {
        self.setOffset(offset)
    }

    /// 在约束块外部更新约束的边距
    ///
    /// 对齐 SnapKit 的 `Constraint.updateInsets(_:)` 方法。
    ///
    /// - Parameter insets: 新的边距值
    @MainActor
    public func updateInsets(_ insets: MASNativeEdgeInsets) {
        self.setInsets(insets)
    }

    /// 在约束块外部更新约束的统一内边距
    ///
    /// - Parameter inset: 新的统一内边距值
    @MainActor
    public func updateInset(_ inset: CGFloat) {
        self.setInset(inset)
    }

    /// 在约束块外部更新约束的中心偏移
    ///
    /// - Parameter centerOffset: 新的中心偏移量
    @MainActor
    public func updateCenterOffset(_ centerOffset: CGPoint) {
        self.setCenterOffset(centerOffset)
    }

    /// 在约束块外部更新约束的尺寸偏移
    ///
    /// - Parameter sizeOffset: 新的尺寸偏移量
    @MainActor
    public func updateSizeOffset(_ sizeOffset: CGSize) {
        self.setSizeOffset(sizeOffset)
    }

    // MARK: - 值包装（内部工具方法）

    /// 将 Swift 值类型自动包装为 ObjC 对象
    ///
    /// 替代 ObjC 的 `MASBoxValue()` 宏。对于 `NSObject` 子类直接返回，
    /// 对于 `CGFloat`、`Double`、`Int`、`CGPoint`、`CGSize`、`MASNativeEdgeInsets`
    /// 等值类型，自动包装为 `NSNumber` 或 `NSValue`。
    ///
    /// 支持可选类型输入：
    /// - 若传入 `Optional.some(wrapped)`，会先解包再进行类型匹配
    /// - 若传入 `nil`，将触发断言失败（仅 Debug 模式）
    ///
    /// - Parameter value: 需要包装的值（支持可选类型）
    /// - Returns: 包装后的 ObjC 对象
    internal static func boxValue(_ value: Any?, file: String = #fileID, line: UInt = #line) -> any ConstraintConvertible {
        // 处理可选类型：解包 Optional 容器
        let unwrapped: Any
        if let value = value {
            // Mirror 用于检测嵌套 Optional（如 Any? 包装的 UIView?）
            let mirror = Mirror(reflecting: value)
            if mirror.displayStyle == .optional {
                // 嵌套的可选值，提取内部值
                if let (_, innerValue) = mirror.children.first {
                    unwrapped = innerValue
                } else {
                    // 嵌套 Optional 且内部为 nil
                    assertionFailure("[Masonry] [\(file):\(line)] boxValue: 约束目标值不能为 nil，请检查传入的可选值是否已正确赋值")
                    return NSNumber(value: 0)
                }
            } else {
                unwrapped = value
            }
        } else {
            assertionFailure("[Masonry] [\(file):\(line)] boxValue: 约束目标值不能为 nil，请检查传入的可选值是否已正确赋值")
            return NSNumber(value: 0)
        }

        switch unwrapped {
        // Swift value types → box to NSValue/NSNumber first
        case let point as CGPoint:
            #if canImport(UIKit)
            return NSValue(cgPoint: point)
            #else
            return NSValue(point: point)
            #endif
        case let size as CGSize:
            #if canImport(UIKit)
            return NSValue(cgSize: size)
            #else
            return NSValue(size: size)
            #endif
        #if canImport(UIKit)
        case let insets as UIEdgeInsets:
            return NSValue(uiEdgeInsets: insets)
        #endif
        case let rect as CGRect:
            #if canImport(UIKit)
            return NSValue(cgRect: rect)
            #else
            return NSValue(rect: rect)
            #endif
        case let floatVal as CGFloat:
            return NSNumber(value: Double(floatVal))
        case let doubleVal as Double:
            return NSNumber(value: doubleVal)
        case let intVal as Int:
            return NSNumber(value: intVal)
        case let floatVal as Float:
            return NSNumber(value: floatVal)
        // ObjC objects (ViewAttribute, UIView/NSView, NSValue/NSNumber, NSArray)
        case let convertible as any ConstraintConvertible:
            return convertible
        default:
            assertionFailure("[Masonry] [\(file):\(line)] boxValue: 不支持的约束目标类型: \(type(of: unwrapped))")
            return NSNumber(value: 0)
        }
    }

    #if os(macOS)
    // MARK: - macOS 动画代理

    /// macOS 动画约束代理
    ///
    /// 对齐 SnapKit 在 macOS 上的 animator 支持。
    /// 通过 NSAnimatablePropertyContainer 的 animator 代理修改约束常量。
    ///
    /// > 限制：仅在 macOS 上可用，iOS/tvOS 不支持。
    @MainActor
    public var mas_animator: MASConstraint {
        self.animator
    }
    #endif

    // MARK: - 属性链（将 ObjC 方法包装为 Swift 计算属性，支持 make.top.left.right 语法）
    //
    // ObjC 中 left、top 等是方法（返回 MASConstraint *），在 Swift 中桥接为 func left() -> MASConstraint。
    // 为了支持 make.top.left.right 的属性链语法，这里将它们包装为计算属性。
    // Swift 编译器在 constraint.left 时会优先选择属性（无需括号），而非方法。

    /// 左边距约束（属性链）
    @MainActor
    public var left: MASConstraint {
        get { self.left() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 顶部约束（属性链）
    @MainActor
    public var top: MASConstraint {
        get { self.top() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 右边距约束（属性链）
    @MainActor
    public var right: MASConstraint {
        get { self.right() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 底部约束（属性链）
    @MainActor
    public var bottom: MASConstraint {
        get { self.bottom() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 前导约束（属性链）
    @MainActor
    public var leading: MASConstraint {
        get { self.leading() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尾随约束（属性链）
    @MainActor
    public var trailing: MASConstraint {
        get { self.trailing() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 宽度约束（属性链）
    @MainActor
    public var width: MASConstraint {
        get { self.width() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 高度约束（属性链）
    @MainActor
    public var height: MASConstraint {
        get { self.height() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 水平中心约束（属性链）
    @MainActor
    public var centerX: MASConstraint {
        get { self.centerX() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 垂直中心约束（属性链）
    @MainActor
    public var centerY: MASConstraint {
        get { self.centerY() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 基线约束（属性链）
    @MainActor
    public var baseline: MASConstraint {
        get { self.baseline() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 首行基线约束（属性链）
    @MainActor
    public var firstBaseline: MASConstraint {
        get { self.firstBaseline() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 末行基线约束（属性链）
    @MainActor
    public var lastBaseline: MASConstraint {
        get { self.lastBaseline() }
        set { /* 支持 += / -= 运算符 */ }
    }

    #if canImport(UIKit)
    /// 左边距（基于 Margin，属性链）
    @MainActor
    public var leftMargin: MASConstraint {
        get { self.leftMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 右边距（基于 Margin，属性链）
    @MainActor
    public var rightMargin: MASConstraint {
        get { self.rightMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 顶部边距（基于 Margin，属性链）
    @MainActor
    public var topMargin: MASConstraint {
        get { self.topMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 底部边距（基于 Margin，属性链）
    @MainActor
    public var bottomMargin: MASConstraint {
        get { self.bottomMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 前导边距（基于 Margin，属性链）
    @MainActor
    public var leadingMargin: MASConstraint {
        get { self.leadingMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尾随边距（基于 Margin，属性链）
    @MainActor
    public var trailingMargin: MASConstraint {
        get { self.trailingMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 水平中心（基于 Margin，属性链）
    @MainActor
    public var centerXWithinMargins: MASConstraint {
        get { self.centerXWithinMargins() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 垂直中心（基于 Margin，属性链）
    @MainActor
    public var centerYWithinMargins: MASConstraint {
        get { self.centerYWithinMargins() }
        set { /* 支持 += / -= 运算符 */ }
    }
    #endif

    // MARK: - 语义链

    /// 语义属性，不影响约束，提升可读性
    @MainActor
    public var mas_with: MASConstraint { self.with() }

    /// 语义属性，不影响约束，提升可读性
    @MainActor
    public var mas_and: MASConstraint { self.and() }
}
