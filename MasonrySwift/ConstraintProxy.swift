//
//  ConstraintProxy.swift
//  Masonry
//
//  MASSwiftConstraintProxy：为 MASConstraint 提供 Swift 友好的链式调用代理
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
#endif

// MARK: - MASSwiftConstraintProxy（约束代理，提供 Swift 友好的值包装）

/// 为 `MASConstraint` 提供 Swift 友好的链式调用代理
///
/// 此代理解决了 ObjC 宏（如 `mas_equalTo`、`mas_offset` 等）在 Swift 中不可用的问题，
/// 通过泛型方法自动将 Swift 值类型包装为 `NSValue`/`NSNumber`。
@MainActor
public final class MASSwiftConstraintProxy {

    /// 内部持有的 ObjC 约束对象
    public let constraint: MASConstraint

    /// 以 ObjC 约束对象初始化
    /// - Parameter constraint: 原始 MASConstraint
    public init(_ constraint: MASConstraint) {
        self.constraint = constraint
    }

    // MARK: - 关系设置（替代 mas_equalTo / mas_greaterThanOrEqualTo / mas_lessThanOrEqualTo 宏）

    /// 设置约束关系为"等于"
    ///
    /// 替代 ObjC 宏 `mas_equalTo(...)`，自动将值类型包装为 `NSValue`。
    /// 支持传入可选类型（如 `UIView!`），内部会自动解包。
    /// - Parameter value: 约束目标，可以是 `CGFloat`、`CGPoint`、`CGSize`、`MASNativeEdgeInsets`、
    ///   `MASNativeView`、`ViewAttribute` 或其他数值类型
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func equalTo(_ value: Any?) -> MASSwiftConstraintProxy {
        constraint.equalTo()(MASSwiftConstraintProxy.boxValue(value))
        return self
    }

    /// 设置约束关系为"大于等于"
    ///
    /// 替代 ObjC 宏 `mas_greaterThanOrEqualTo(...)`。
    /// 支持传入可选类型（如 `UIView!`），内部会自动解包。
    /// - Parameter value: 约束目标
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func greaterThanOrEqualTo(_ value: Any?) -> MASSwiftConstraintProxy {
        constraint.greaterThanOrEqualTo()(MASSwiftConstraintProxy.boxValue(value))
        return self
    }

    /// 设置约束关系为"小于等于"
    ///
    /// 替代 ObjC 宏 `mas_lessThanOrEqualTo(...)`。
    /// 支持传入可选类型（如 `UIView!`），内部会自动解包。
    /// - Parameter value: 约束目标
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func lessThanOrEqualTo(_ value: Any?) -> MASSwiftConstraintProxy {
        constraint.lessThanOrEqualTo()(MASSwiftConstraintProxy.boxValue(value))
        return self
    }

    /// 设置约束关系为"等于父视图的对应属性"
    ///
    /// 替代写法 `.equalTo(superview)` 或 `.equalTo(superview.mas_top)` 等，
    /// 直接与父视图的同名属性建立等值约束。
    /// 视图必须已加入视图层级（有父视图），否则触发断言。
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func equalToSuperview() -> MASSwiftConstraintProxy {
        constraint.equalToSuperview()
        return self
    }

    /// 设置约束关系为"大于等于父视图的对应属性"
    ///
    /// 对齐 SnapKit 的 `greaterThanOrEqualToSuperview()`。
    /// 直接映射到 Masonry 底层的 `greaterThanOrEqualToSuperview` 方法。
    /// 视图必须已加入视图层级（有父视图），否则触发断言。
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func greaterThanOrEqualToSuperview() -> MASSwiftConstraintProxy {
        constraint.greaterThanOrEqualToSuperview()
        return self
    }

    /// 设置约束关系为"小于等于父视图的对应属性"
    ///
    /// 对齐 SnapKit 的 `lessThanOrEqualToSuperview()`。
    /// 直接映射到 Masonry 底层的 `lessThanOrEqualToSuperview` 方法。
    /// 视图必须已加入视图层级（有父视图），否则触发断言。
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func lessThanOrEqualToSuperview() -> MASSwiftConstraintProxy {
        constraint.lessThanOrEqualToSuperview()
        return self
    }

    // MARK: - 偏移量设置（替代 mas_offset 宏）

    /// 设置约束常量偏移（CGFloat）
    ///
    /// - Parameter value: 偏移量数值
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func offset(_ value: CGFloat) -> MASSwiftConstraintProxy {
        constraint.offset()(value)
        return self
    }

    /// 设置基于值类型的偏移量（替代 ObjC 宏 `mas_offset`）
    ///
    /// 支持 `CGFloat`、`CGPoint`、`CGSize`、`MASNativeEdgeInsets` 等类型，
    /// 自动包装为 `NSValue`。支持传入可选类型，内部会自动解包。
    /// - Parameter value: 偏移量
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func valueOffset(_ value: Any?) -> MASSwiftConstraintProxy {
        guard let boxed = MASSwiftConstraintProxy.boxValue(value) as? NSValue else {
            assertionFailure("[Masonry] valueOffset: 传入的值无法转换为 NSValue，请检查参数类型")
            return self
        }
        constraint.valueOffset()(boxed)
        return self
    }

    /// 设置边距偏移（MASEdgeInsets）
    ///
    /// - Parameter insets: 边距值
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func insets(_ insets: MASNativeEdgeInsets) -> MASSwiftConstraintProxy {
        constraint.insets()(insets)
        return self
    }

    /// 设置统一的边距偏移
    ///
    /// - Parameter value: 统一的内边距值
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func inset(_ value: CGFloat) -> MASSwiftConstraintProxy {
        constraint.inset()(value)
        return self
    }

    /// 设置尺寸偏移（CGSize）
    ///
    /// - Parameter offset: 尺寸偏移量
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func sizeOffset(_ offset: CGSize) -> MASSwiftConstraintProxy {
        constraint.sizeOffset()(offset)
        return self
    }

    /// 设置中心偏移（CGPoint）
    ///
    /// - Parameter offset: 中心点偏移量
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func centerOffset(_ offset: CGPoint) -> MASSwiftConstraintProxy {
        constraint.centerOffset()(offset)
        return self
    }

    // MARK: - 优先级

    /// 设置约束优先级
    ///
    /// - Parameter value: 优先级值（0~1000）
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func priority(_ value: Float) -> MASSwiftConstraintProxy {
        constraint.priority()(MASLayoutPriority(rawValue: value))
        return self
    }

    /// 设置约束为低优先级（`UILayoutPriority.defaultLow`）
    ///
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func priorityLow() -> MASSwiftConstraintProxy {
        constraint.priorityLow()()
        return self
    }

    /// 设置约束为中优先级（500）
    ///
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func priorityMedium() -> MASSwiftConstraintProxy {
        constraint.priorityMedium()()
        return self
    }

    /// 设置约束为高优先级（`UILayoutPriority.defaultHigh`）
    ///
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func priorityHigh() -> MASSwiftConstraintProxy {
        constraint.priorityHigh()()
        return self
    }

    // MARK: - 乘除

    /// 设置约束乘数
    ///
    /// - Parameter value: 乘数值
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func multipliedBy(_ value: CGFloat) -> MASSwiftConstraintProxy {
        constraint.multipliedBy()(value)
        return self
    }

    /// 设置约束除数（内部转换为 1.0/value 的乘数）
    ///
    /// - Parameter value: 除数值
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func dividedBy(_ value: CGFloat) -> MASSwiftConstraintProxy {
        constraint.dividedBy()(value)
        return self
    }

    // MARK: - 调试键

    /// 设置约束的调试标识键
    ///
    /// - Parameter value: 用于调试的键值
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func key(_ value: Any?) -> MASSwiftConstraintProxy {
        guard let unwrapped = value else { return self }
        constraint.key()(unwrapped)
        return self
    }

    // MARK: - 安装/卸载

    /// 激活约束
    public func activate() {
        constraint.activate()
    }

    /// 停用约束
    public func deactivate() {
        constraint.deactivate()
    }

    /// 安装约束
    public func install() {
        constraint.install()
    }

    /// 卸载约束
    public func uninstall() {
        constraint.uninstall()
    }

    // MARK: - 底层约束访问（对齐 SnapKit Constraint.layoutConstraints / isActive）

    /// 获取底层 NSLayoutConstraint 数组
    ///
    /// 对齐 SnapKit 的 `Constraint.layoutConstraints` 属性。
    /// - 对于 `MASViewConstraint`：返回包含单个 `layoutConstraint` 的数组（如已安装）
    /// - 对于 `MASCompositeConstraint`：递归收集所有子约束的底层 NSLayoutConstraint
    /// - 未安装的约束返回空数组
    ///
    /// ```swift
    /// let proxy = make.top.equalToSuperview()
    /// // 约束安装后
    /// let nsConstraints = proxy.layoutConstraints
    /// ```
    public var layoutConstraints: [NSLayoutConstraint] {
        return Self.collectLayoutConstraints(from: constraint)
    }

    /// 约束是否处于激活状态
    ///
    /// 对齐 SnapKit 的 `Constraint.isActive` 属性。
    /// - 对于 `MASViewConstraint`：直接返回底层 `isActive` 属性
    /// - 对于 `MASCompositeConstraint`：所有子约束均激活时返回 `true`
    /// - 未安装的约束返回 `false`
    public var isActive: Bool {
        if let viewConstraint = constraint as? MASViewConstraint {
            return viewConstraint.isActive
        }
        if let composite = constraint as? CompositeConstraint {
            let children = composite.childConstraints as? [MASConstraint] ?? []
            return children.allSatisfy { child in
                MASSwiftConstraintProxy(child).isActive
            }
        }
        return false
    }

    /// 递归收集 MASConstraint 树中所有底层 NSLayoutConstraint
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

    // MARK: - 属性链（链式获取子约束属性）
    //
    // 注意：所有属性均提供空 setter，以支持 += / -= 复合赋值运算符。
    // 因为 MASConstraint 是引用类型，offset 等方法已直接修改底层对象，
    // setter 无需执行额外操作。

    /// 左边距约束
    public var left: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.left()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 顶部约束
    public var top: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.top()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 右边距约束
    public var right: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.right()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 底部约束
    public var bottom: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.bottom()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 前导约束
    public var leading: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.leading()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 尾随约束
    public var trailing: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.trailing()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 宽度约束
    public var width: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.width()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 高度约束
    public var height: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.height()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 水平中心约束
    public var centerX: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.centerX()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 垂直中心约束
    public var centerY: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.centerY()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 基线约束
    public var baseline: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.baseline()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 首行基线约束
    public var firstBaseline: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.firstBaseline()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 末行基线约束
    public var lastBaseline: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.lastBaseline()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    #if canImport(UIKit)
    /// 左边距（基于 Margin）
    public var leftMargin: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.leftMargin()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 右边距（基于 Margin）
    public var rightMargin: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.rightMargin()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 顶部边距（基于 Margin）
    public var topMargin: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.topMargin()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 底部边距（基于 Margin）
    public var bottomMargin: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.bottomMargin()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 前导边距（基于 Margin）
    public var leadingMargin: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.leadingMargin()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 尾随边距（基于 Margin）
    public var trailingMargin: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.trailingMargin()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 水平中心（基于 Margin）
    public var centerXWithinMargins: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.centerXWithinMargins()) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 垂直中心（基于 Margin）
    public var centerYWithinMargins: MASSwiftConstraintProxy {
        get { MASSwiftConstraintProxy(constraint.centerYWithinMargins()) }
        set { /* 支持 += / -= 运算符 */ }
    }
    #endif

    // MARK: - 语义链

    /// 语义属性，不影响约束，提升可读性
    public var with: MASSwiftConstraintProxy { self }

    /// 语义属性，不影响约束，提升可读性
    public var and: MASSwiftConstraintProxy { self }

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
    internal static func boxValue(_ value: Any?) -> Any {
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
                    assertionFailure("[Masonry] boxValue: 约束目标值不能为 nil，请检查传入的可选值是否已正确赋值")
                    return NSNull()
                }
            } else {
                unwrapped = value
            }
        } else {
            assertionFailure("[Masonry] boxValue: 约束目标值不能为 nil，请检查传入的可选值是否已正确赋值")
            return NSNull()
        }

        switch unwrapped {
        case let obj as NSObject:
            return obj
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
        default:
            return unwrapped
        }
    }

    // MARK: - 调试标签（对齐 SnapKit labeled）

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
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func labeled(_ label: String) -> MASSwiftConstraintProxy {
        constraint.key()(label)
        return self
    }

    // MARK: - 外部更新方法（对齐 SnapKit Constraint.updateOffset / updateInsets）

    /// 在约束块外部更新约束的偏移量
    ///
    /// 对齐 SnapKit 的 `Constraint.updateOffset(_:)` 方法。
    /// 可在 `makeConstraints` / `updateConstraints` 块外部直接修改已安装约束的常量值。
    ///
    /// ```swift
    /// // 保存约束引用
    /// var topConstraint: MASSwiftConstraintProxy!
    /// view.mas.makeConstraints { make in
    ///     topConstraint = make.top.equalToSuperview().offset(20)
    /// }
    /// // 稍后更新
    /// topConstraint.updateOffset(40)
    /// ```
    ///
    /// - Parameter offset: 新的偏移量
    public func updateOffset(_ offset: CGFloat) {
        constraint.setOffset(offset)
    }

    /// 在约束块外部更新约束的边距
    ///
    /// 对齐 SnapKit 的 `Constraint.updateInsets(_:)` 方法。
    ///
    /// - Parameter insets: 新的边距值
    public func updateInsets(_ insets: MASNativeEdgeInsets) {
        constraint.setInsets(insets)
    }

    /// 在约束块外部更新约束的统一内边距
    ///
    /// - Parameter inset: 新的统一内边距值
    public func updateInset(_ inset: CGFloat) {
        constraint.setInset(inset)
    }

    /// 在约束块外部更新约束的中心偏移
    ///
    /// - Parameter centerOffset: 新的中心偏移量
    public func updateCenterOffset(_ centerOffset: CGPoint) {
        constraint.setCenterOffset(centerOffset)
    }

    /// 在约束块外部更新约束的尺寸偏移
    ///
    /// - Parameter sizeOffset: 新的尺寸偏移量
    public func updateSizeOffset(_ sizeOffset: CGSize) {
        constraint.setSizeOffset(sizeOffset)
    }

    // MARK: - 优先级（MASConstraintPriority 枚举支持）

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
    /// - Returns: 当前代理对象，支持链式调用
    @discardableResult
    public func priority(_ priority: MASConstraintPriority) -> MASSwiftConstraintProxy {
        constraint.priority()(MASLayoutPriority(rawValue: priority.value))
        return self
    }

    #if os(macOS)
    // MARK: - macOS 动画代理

    /// macOS 动画约束代理
    ///
    /// 对齐 SnapKit 在 macOS 上的 animator 支持。
    /// 通过 NSAnimatablePropertyContainer 的 animator 代理修改约束常量。
    ///
    /// > 限制：仅在 macOS 上可用，iOS/tvOS 不支持。
    public var animator: MASSwiftConstraintProxy {
        MASSwiftConstraintProxy(constraint.animator)
    }
    #endif
}
