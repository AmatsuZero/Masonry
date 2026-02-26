//
//  Masonry+Swift.swift
//  Masonry
//
//  提供 Swift 原生语法支持，解决 ObjC 宏定义无法在 Swift 中使用的问题
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 类型别名

#if canImport(UIKit)
/// 跨平台视图类型别名
public typealias MASNativeView = UIView
/// 跨平台边距类型别名
public typealias MASNativeEdgeInsets = UIEdgeInsets
#elseif canImport(AppKit)
/// 跨平台视图类型别名
public typealias MASNativeView = NSView
/// 跨平台边距类型别名
public typealias MASNativeEdgeInsets = NSEdgeInsets
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
    private static func boxValue(_ value: Any?) -> Any {
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
            return NSValue(cgPoint: point)
        case let size as CGSize:
            return NSValue(cgSize: size)
        #if canImport(UIKit)
        case let insets as UIEdgeInsets:
            return NSValue(uiEdgeInsets: insets)
        #endif
        case let rect as CGRect:
            return NSValue(cgRect: rect)
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
}

// MARK: - MASSwiftMakerProxy（ConstraintMaker 代理）

/// 为 `MASConstraintMaker` 提供 Swift 友好的属性访问代理
///
/// 将 `MASConstraintMaker` 的属性访问转换为返回 `MASSwiftConstraintProxy`，
/// 从而实现整个链式调用链的 Swift 化。
@MainActor
public final class MASSwiftMakerProxy {

    /// 内部持有的 ObjC ConstraintMaker 对象
    public let maker: MASConstraintMaker

    /// 以 ObjC ConstraintMaker 对象初始化
    /// - Parameter maker: 原始 MASConstraintMaker
    public init(_ maker: MASConstraintMaker) {
        self.maker = maker
    }

    // MARK: - 基础属性
    //
    // 注意：所有属性均提供空 setter，以支持 += / -= 复合赋值运算符。
    // 因为 MASConstraint 是引用类型，offset 等方法已直接修改底层对象，
    // setter 无需执行额外操作。

    /// 左边约束
    public var left: MASSwiftConstraintProxy {
        get { .init(maker.left) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 顶部约束
    public var top: MASSwiftConstraintProxy {
        get { .init(maker.top) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 右边约束
    public var right: MASSwiftConstraintProxy {
        get { .init(maker.right) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 底部约束
    public var bottom: MASSwiftConstraintProxy {
        get { .init(maker.bottom) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 前导约束
    public var leading: MASSwiftConstraintProxy {
        get { .init(maker.leading) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尾随约束
    public var trailing: MASSwiftConstraintProxy {
        get { .init(maker.trailing) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 宽度约束
    public var width: MASSwiftConstraintProxy {
        get { .init(maker.width) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 高度约束
    public var height: MASSwiftConstraintProxy {
        get { .init(maker.height) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 水平中心约束
    public var centerX: MASSwiftConstraintProxy {
        get { .init(maker.centerX) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 垂直中心约束
    public var centerY: MASSwiftConstraintProxy {
        get { .init(maker.centerY) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 基线约束
    public var baseline: MASSwiftConstraintProxy {
        get { .init(maker.baseline) }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 首行基线约束
    public var firstBaseline: MASSwiftConstraintProxy {
        get { .init(maker.firstBaseline) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 末行基线约束
    public var lastBaseline: MASSwiftConstraintProxy {
        get { .init(maker.lastBaseline) }
        set { /* 支持 += / -= 运算符 */ }
    }

    #if canImport(UIKit)
    /// 左边距（基于 Margin）
    public var leftMargin: MASSwiftConstraintProxy {
        get { .init(maker.leftMargin) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 右边距（基于 Margin）
    public var rightMargin: MASSwiftConstraintProxy {
        get { .init(maker.rightMargin) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 顶部边距（基于 Margin）
    public var topMargin: MASSwiftConstraintProxy {
        get { .init(maker.topMargin) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 底部边距（基于 Margin）
    public var bottomMargin: MASSwiftConstraintProxy {
        get { .init(maker.bottomMargin) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 前导边距（基于 Margin）
    public var leadingMargin: MASSwiftConstraintProxy {
        get { .init(maker.leadingMargin) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尾随边距（基于 Margin）
    public var trailingMargin: MASSwiftConstraintProxy {
        get { .init(maker.trailingMargin) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 水平中心（基于 Margin）
    public var centerXWithinMargins: MASSwiftConstraintProxy {
        get { .init(maker.centerXWithinMargins) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 垂直中心（基于 Margin）
    public var centerYWithinMargins: MASSwiftConstraintProxy {
        get { .init(maker.centerYWithinMargins) }
        set { /* 支持 += / -= 运算符 */ }
    }
    #endif

    // MARK: - 复合属性

    /// 四边约束（top, left, bottom, right）
    public var edges: MASSwiftConstraintProxy {
        get { .init(maker.edges) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尺寸约束（width, height）
    public var size: MASSwiftConstraintProxy {
        get { .init(maker.size) }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 中心约束（centerX, centerY）
    public var center: MASSwiftConstraintProxy {
        get { .init(maker.center) }
        set { /* 支持 += / -= 运算符 */ }
    }

    // MARK: - 按位组合属性

    /// 通过按位或组合创建复合约束
    ///
    /// - Parameter attrs: `MASAttribute` 位掩码组合
    /// - Returns: 复合约束代理
    public func attributes(_ attrs: ConstraintAttribute) -> MASSwiftConstraintProxy {
        .init(maker.attributes(attrs))
    }
}

// MARK: - MASViewDSL（视图命名空间代理）

/// 视图的 Masonry DSL 命名空间
///
/// 通过 `view.mas` 访问，提供 Swift 原生的布局约束方法。
/// 所有方法均标记了 `@discardableResult`，可忽略返回值。
///
/// ## 用法示例
///
/// ```swift
/// view.mas.makeConstraints { make in
///     make.top.equalTo(superview.mas_top).offset(20)
///     make.left.right.equalTo(superview).inset(16)
///     make.height.equalTo(44)
/// }
/// ```
@MainActor
public struct MASViewDSL {

    /// 关联的视图
    fileprivate let view: MASNativeView

    /// 以视图初始化
    /// - Parameter view: 需要布局的视图
    fileprivate init(_ view: MASNativeView) {
        self.view = view
    }

    // MARK: - 约束创建

    /// 创建并安装约束
    ///
    /// 等同于 ObjC 中的 `mas_makeConstraints:`。
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 已安装的约束数组
    @discardableResult
    public func makeConstraints(_ closure: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        view.mas_makeConstraints { closure(MASSwiftMakerProxy($0)) }
    }

    /// 更新已有约束（存在则更新，不存在则创建）
    ///
    /// 等同于 ObjC 中的 `mas_updateConstraints:`。
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 已创建/更新的约束数组
    @discardableResult
    public func updateConstraints(_ closure: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        view.mas_updateConstraints { closure(MASSwiftMakerProxy($0)) }
    }

    /// 移除所有已有约束后重新创建
    ///
    /// 等同于 ObjC 中的 `mas_remakeConstraints:`。
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 已创建的约束数组
    @discardableResult
    public func remakeConstraints(_ closure: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        view.mas_remakeConstraints { closure(MASSwiftMakerProxy($0)) }
    }

    // MARK: - 视图属性（供约束目标引用）

    /// 左边布局属性
    public var left: ViewAttribute { view.mas_left }
    /// 顶部布局属性
    public var top: ViewAttribute { view.mas_top }
    /// 右边布局属性
    public var right: ViewAttribute { view.mas_right }
    /// 底部布局属性
    public var bottom: ViewAttribute { view.mas_bottom }
    /// 前导布局属性
    public var leading: ViewAttribute { view.mas_leading }
    /// 尾随布局属性
    public var trailing: ViewAttribute { view.mas_trailing }
    /// 宽度布局属性
    public var width: ViewAttribute { view.mas_width }
    /// 高度布局属性
    public var height: ViewAttribute { view.mas_height }
    /// 水平中心布局属性
    public var centerX: ViewAttribute { view.mas_centerX }
    /// 垂直中心布局属性
    public var centerY: ViewAttribute { view.mas_centerY }
    /// 基线布局属性
    public var baseline: ViewAttribute { view.mas_baseline }

    /// 首行基线布局属性
    public var firstBaseline: ViewAttribute { view.mas_firstBaseline }
    /// 末行基线布局属性
    public var lastBaseline: ViewAttribute { view.mas_lastBaseline }

    #if canImport(UIKit)
    /// 左边距布局属性（基于 Margin）
    public var leftMargin: ViewAttribute { view.mas_leftMargin }
    /// 右边距布局属性（基于 Margin）
    public var rightMargin: ViewAttribute { view.mas_rightMargin }
    /// 顶部边距布局属性（基于 Margin）
    public var topMargin: ViewAttribute { view.mas_topMargin }
    /// 底部边距布局属性（基于 Margin）
    public var bottomMargin: ViewAttribute { view.mas_bottomMargin }
    /// 前导边距布局属性（基于 Margin）
    public var leadingMargin: ViewAttribute { view.mas_leadingMargin }
    /// 尾随边距布局属性（基于 Margin）
    public var trailingMargin: ViewAttribute { view.mas_trailingMargin }
    /// 水平中心布局属性（基于 Margin）
    public var centerXWithinMargins: ViewAttribute { view.mas_centerXWithinMargins }
    /// 垂直中心布局属性（基于 Margin）
    public var centerYWithinMargins: ViewAttribute { view.mas_centerYWithinMargins }

    /// SafeArea 布局引导
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuide: ViewAttribute { view.mas_safeAreaLayoutGuide }
    /// SafeArea 前导
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLeading: ViewAttribute { view.mas_safeAreaLayoutGuideLeading }
    /// SafeArea 尾随
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaTrailing: ViewAttribute { view.mas_safeAreaLayoutGuideTrailing }
    /// SafeArea 左边
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLeft: ViewAttribute { view.mas_safeAreaLayoutGuideLeft }
    /// SafeArea 右边
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaRight: ViewAttribute { view.mas_safeAreaLayoutGuideRight }
    /// SafeArea 顶部
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaTop: ViewAttribute { view.mas_safeAreaLayoutGuideTop }
    /// SafeArea 底部
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaBottom: ViewAttribute { view.mas_safeAreaLayoutGuideBottom }
    /// SafeArea 宽度
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaWidth: ViewAttribute { view.mas_safeAreaLayoutGuideWidth }
    /// SafeArea 高度
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaHeight: ViewAttribute { view.mas_safeAreaLayoutGuideHeight }
    /// SafeArea 水平中心
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaCenterX: ViewAttribute { view.mas_safeAreaLayoutGuideCenterX }
    /// SafeArea 垂直中心
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaCenterY: ViewAttribute { view.mas_safeAreaLayoutGuideCenterY }

    // MARK: SafeArea 全名别名（与 ObjC 属性命名对齐）

    /// SafeArea 顶部（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideTop: ViewAttribute { safeAreaTop }
    /// SafeArea 底部（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideBottom: ViewAttribute { safeAreaBottom }
    /// SafeArea 左边（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideLeft: ViewAttribute { safeAreaLeft }
    /// SafeArea 右边（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideRight: ViewAttribute { safeAreaRight }
    /// SafeArea 前导（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideLeading: ViewAttribute { safeAreaLeading }
    /// SafeArea 尾随（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideTrailing: ViewAttribute { safeAreaTrailing }
    /// SafeArea 宽度（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideWidth: ViewAttribute { safeAreaWidth }
    /// SafeArea 高度（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideHeight: ViewAttribute { safeAreaHeight }
    /// SafeArea 水平中心（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideCenterX: ViewAttribute { safeAreaCenterX }
    /// SafeArea 垂直中心（全名别名）
    @available(iOS 11.0, tvOS 11.0, *)
    public var safeAreaLayoutGuideCenterY: ViewAttribute { safeAreaCenterY }
    #endif

    // MARK: - 最近公共父视图

    /// 查找当前视图与另一个视图的最近公共父视图
    ///
    /// - Parameter view: 另一个视图
    /// - Returns: 最近公共父视图，如果不存在则返回 `nil`
    public func closestCommonSuperview(_ otherView: MASNativeView) -> MASNativeView? {
        return view.mas_closestCommonSuperview(otherView)
    }

    // MARK: - 调试键

    /// 获取或设置视图的调试标识键
    public var key: Any? {
        get { view.mas_key }
        set { view.mas_key = newValue }
    }
}

// MARK: - MASNativeView 扩展（mas 命名空间）

extension MASNativeView {

    /// Masonry Swift DSL 命名空间
    ///
    /// 通过此属性访问所有 Swift 友好的约束布局方法。
    ///
    /// ## 用法
    /// ```swift
    /// view.mas.makeConstraints { make in
    ///     make.edges.equalTo(superview)
    /// }
    /// ```
    public var mas: MASViewDSL {
        MASViewDSL(self)
    }
}

// MARK: - UIViewController 扩展

#if canImport(UIKit)

/// UIViewController 的 Masonry DSL 命名空间
@available(iOS, introduced: 8.0, deprecated: 11.0, message: "请使用 view.mas.safeAreaTop/safeAreaBottom 替代")
@MainActor
public struct MASViewControllerDSL {

    fileprivate let viewController: UIViewController

    fileprivate init(_ viewController: UIViewController) {
        self.viewController = viewController
    }

    /// 顶部布局引导
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public var topLayoutGuide: ViewAttribute { viewController.mas_topLayoutGuide }

    /// 底部布局引导
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public var bottomLayoutGuide: ViewAttribute { viewController.mas_bottomLayoutGuide }

    /// 顶部布局引导的顶部
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public var topLayoutGuideTop: ViewAttribute { viewController.mas_topLayoutGuideTop }

    /// 顶部布局引导的底部
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public var topLayoutGuideBottom: ViewAttribute { viewController.mas_topLayoutGuideBottom }

    /// 底部布局引导的顶部
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public var bottomLayoutGuideTop: ViewAttribute { viewController.mas_bottomLayoutGuideTop }

    /// 底部布局引导的底部
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public var bottomLayoutGuideBottom: ViewAttribute { viewController.mas_bottomLayoutGuideBottom }
}

extension UIViewController {

    /// Masonry Swift DSL 命名空间（用于访问已废弃的布局引导属性）
    @available(iOS, introduced: 8.0, deprecated: 11.0, message: "请使用 view.mas.safeAreaTop/safeAreaBottom 替代")
    public var mas: MASViewControllerDSL {
        MASViewControllerDSL(self)
    }
}

#endif

// MARK: - NSArray 扩展

extension Array where Element: MASNativeView {

    /// 批量创建并安装约束
    ///
    /// 对数组中的所有视图执行相同的约束构建闭包。
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 所有已安装的约束数组
    @MainActor
    @discardableResult
    public func mas_makeConstraints(_ closure: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        (self as NSArray).mas_makeConstraints { closure(MASSwiftMakerProxy($0)) }
    }

    /// 批量更新约束
    ///
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 所有已创建/更新的约束数组
    @MainActor
    @discardableResult
    public func mas_updateConstraints(_ closure: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        (self as NSArray).mas_updateConstraints { closure(MASSwiftMakerProxy($0)) }
    }

    /// 批量移除所有约束后重新创建
    ///
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 所有已创建的约束数组
    @MainActor
    @discardableResult
    public func mas_remakeConstraints(_ closure: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        (self as NSArray).mas_remakeConstraints { closure(MASSwiftMakerProxy($0))
        }
    }

    /// 等间距分布视图
    ///
    /// - Parameters:
    ///   - axis: 分布轴方向
    ///   - fixedSpacing: 视图之间的固定间距
    ///   - leadSpacing: 首个视图与容器之间的间距
    ///   - tailSpacing: 最后视图与容器之间的间距
    @MainActor
    public func mas_distributeViews(along axis: AxisType,
                                    withFixedSpacing fixedSpacing: CGFloat,
                                    leadSpacing: CGFloat,
                                    tailSpacing: CGFloat) {
        (self as NSArray).mas_distributeViews(along: axis, withFixedSpacing: fixedSpacing, leadSpacing: leadSpacing, tailSpacing: tailSpacing)
    }

    /// 等尺寸分布视图
    ///
    /// - Parameters:
    ///   - axis: 分布轴方向
    ///   - fixedItemLength: 每个视图的固定长度
    ///   - leadSpacing: 首个视图与容器之间的间距
    ///   - tailSpacing: 最后视图与容器之间的间距
    @MainActor
    public func mas_distributeViews(along axis: AxisType,
                                    withFixedItemLength fixedItemLength: CGFloat,
                                    leadSpacing: CGFloat,
                                    tailSpacing: CGFloat) {
        (self as NSArray).mas_distributeViews(along: axis, withFixedItemLength: fixedItemLength, leadSpacing: leadSpacing, tailSpacing: tailSpacing)
    }
}

// MARK: - MASAttributeOffset（视图属性 + 偏移量组合）

/// 承载 `MASViewAttribute` 与偏移量的组合
///
/// 用于支持 `label.mas.right + 10` 这样的表达式，
/// 使其可以作为 `==`、`>=`、`<=` 运算符的右操作数。
///
/// ```swift
/// make.left == label.mas.right + 10
/// make.top == otherView.mas.bottom - 5
/// ```
@MainActor
public struct MASAttributeOffset {
    /// 视图布局属性
    public let attribute: ViewAttribute
    /// 偏移量
    public let offset: CGFloat

    public init(attribute: ViewAttribute, offset: CGFloat) {
        self.attribute = attribute
        self.offset = offset
    }
}

/// 加法运算符：为视图属性设置正偏移量
///
/// ```swift
/// make.left == label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func + (lhs: ViewAttribute, rhs: CGFloat) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs, offset: rhs)
}

/// 加法运算符：为视图属性设置正偏移量（Int）
@MainActor
@discardableResult
public func + (lhs: ViewAttribute, rhs: Int) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs, offset: CGFloat(rhs))
}

/// 加法运算符：为视图属性设置正偏移量（Double）
@MainActor
@discardableResult
public func + (lhs: ViewAttribute, rhs: Double) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs, offset: CGFloat(rhs))
}

/// 减法运算符：为视图属性设置负偏移量
///
/// ```swift
/// make.bottom == superview.mas.bottom - 20
/// ```
@MainActor
@discardableResult
public func - (lhs: ViewAttribute, rhs: CGFloat) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs, offset: -rhs)
}

/// 减法运算符：为视图属性设置负偏移量（Int）
@MainActor
@discardableResult
public func - (lhs: ViewAttribute, rhs: Int) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs, offset: CGFloat(-rhs))
}

/// 减法运算符：为视图属性设置负偏移量（Double）
@MainActor
@discardableResult
public func - (lhs: ViewAttribute, rhs: Double) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs, offset: CGFloat(-rhs))
}

// MARK: - MASConstraint 运算符重载

/// 等于运算符：设置约束等于给定值
///
/// ```swift
/// make.width == 100
/// make.top == superview.mas.top
/// ```
@MainActor
@discardableResult
public func == (lhs: MASSwiftConstraintProxy, rhs: Any?) -> MASSwiftConstraintProxy {
    return lhs.equalTo(rhs)
}

/// 大于等于运算符：设置约束大于等于给定值
///
/// ```swift
/// make.height >= 44
/// ```
@MainActor
@discardableResult
public func >= (lhs: MASSwiftConstraintProxy, rhs: Any?) -> MASSwiftConstraintProxy {
    return lhs.greaterThanOrEqualTo(rhs)
}

/// 小于等于运算符：设置约束小于等于给定值
///
/// ```swift
/// make.width <= 320
/// ```
@MainActor
@discardableResult
public func <= (lhs: MASSwiftConstraintProxy, rhs: Any?) -> MASSwiftConstraintProxy {
    return lhs.lessThanOrEqualTo(rhs)
}

// MARK: - MASAttributeOffset 运算符重载（支持 make.left == view.mas.right + 10）

/// 等于运算符：设置约束等于视图属性 + 偏移量
///
/// ```swift
/// make.left == label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func == (lhs: MASSwiftConstraintProxy, rhs: MASAttributeOffset) -> MASSwiftConstraintProxy {
    return lhs.equalTo(rhs.attribute).offset(rhs.offset)
}

/// 大于等于运算符：设置约束大于等于视图属性 + 偏移量
///
/// ```swift
/// make.left >= label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func >= (lhs: MASSwiftConstraintProxy, rhs: MASAttributeOffset) -> MASSwiftConstraintProxy {
    return lhs.greaterThanOrEqualTo(rhs.attribute).offset(rhs.offset)
}

/// 小于等于运算符：设置约束小于等于视图属性 + 偏移量
///
/// ```swift
/// make.left <= label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func <= (lhs: MASSwiftConstraintProxy, rhs: MASAttributeOffset) -> MASSwiftConstraintProxy {
    return lhs.lessThanOrEqualTo(rhs.attribute).offset(rhs.offset)
}

/// 乘法运算符：设置约束的乘数
///
/// ```swift
/// make.width == superview.mas.width * 0.5
/// ```
@MainActor
@discardableResult
public func * (lhs: MASSwiftConstraintProxy, rhs: CGFloat) -> MASSwiftConstraintProxy {
    return lhs.multipliedBy(rhs)
}

/// 除法运算符：设置约束的除数
///
/// ```swift
/// make.width == superview.mas.width / 2
/// ```
@MainActor
@discardableResult
public func / (lhs: MASSwiftConstraintProxy, rhs: CGFloat) -> MASSwiftConstraintProxy {
    return lhs.dividedBy(rhs)
}

/// 加法运算符：设置约束的偏移量
///
/// ```swift
/// make.top == superview.mas.top + 20
/// ```
@MainActor
@discardableResult
public func + (lhs: MASSwiftConstraintProxy, rhs: CGFloat) -> MASSwiftConstraintProxy {
    return lhs.offset(rhs)
}

/// 减法运算符：设置约束的负偏移量
///
/// ```swift
/// make.bottom == superview.mas.bottom - 20
/// ```
@MainActor
@discardableResult
public func - (lhs: MASSwiftConstraintProxy, rhs: CGFloat) -> MASSwiftConstraintProxy {
    return lhs.offset(-rhs)
}

// MARK: - 复合赋值运算符（+= / -=）

/// 复合加法赋值运算符：增加约束偏移量（CGFloat）
///
/// 用法一：直接在 maker 属性链上使用（推荐）
/// ```swift
/// view.mas.makeConstraints { make in
///     make.right.bottom += -16
///     make.left.equalTo(view2.mas_right) += 10
/// }
/// ```
///
/// 用法二：通过变量引用
/// ```swift
/// var constraint = make.left.equalTo(view2.mas_right)
/// constraint += 10
/// ```
@MainActor
public func += (lhs: inout MASSwiftConstraintProxy, rhs: CGFloat) {
    lhs = lhs.offset(rhs)
}

/// 复合减法赋值运算符：减少约束偏移量（CGFloat）
///
/// 用法一：直接在 maker 属性链上使用（推荐）
/// ```swift
/// view.mas.makeConstraints { make in
///     make.bottom -= 20
///     make.right.bottom -= 16
/// }
/// ```
///
/// 用法二：通过变量引用
/// ```swift
/// var constraint = make.bottom.equalTo(superview.mas.bottom)
/// constraint -= 20
/// ```
@MainActor
public func -= (lhs: inout MASSwiftConstraintProxy, rhs: CGFloat) {
    lhs = lhs.offset(-rhs)
}

/// 复合加法赋值运算符：增加约束偏移量（Int）
@MainActor
public func += (lhs: inout MASSwiftConstraintProxy, rhs: Int) {
    lhs = lhs.offset(CGFloat(rhs))
}

/// 复合减法赋值运算符：减少约束偏移量（Int）
@MainActor
public func -= (lhs: inout MASSwiftConstraintProxy, rhs: Int) {
    lhs = lhs.offset(CGFloat(-rhs))
}

/// 复合加法赋值运算符：增加约束偏移量（Double）
@MainActor
public func += (lhs: inout MASSwiftConstraintProxy, rhs: Double) {
    lhs = lhs.offset(CGFloat(rhs))
}

/// 复合减法赋值运算符：减少约束偏移量（Double）
@MainActor
public func -= (lhs: inout MASSwiftConstraintProxy, rhs: Double) {
    lhs = lhs.offset(CGFloat(-rhs))
}

// MARK: - 优先级运算符

/// 自定义优先级运算符
///
/// ```swift
/// make.width == 100 ~ .defaultHigh
/// make.height == 44 ~ 750
/// ```
infix operator ~ : AdditionPrecedence

/// 使用自定义运算符设置约束优先级（Float）
///
/// ```swift
/// make.width == 100 ~ 750
/// ```
@MainActor
@discardableResult
public func ~ (lhs: MASSwiftConstraintProxy, rhs: Float) -> MASSwiftConstraintProxy {
    return lhs.priority(rhs)
}

#if canImport(UIKit)
/// 使用自定义运算符设置约束优先级（UILayoutPriority）
///
/// ```swift
/// make.width == 100 ~ .defaultHigh
/// ```
@MainActor
@discardableResult
public func ~ (lhs: MASSwiftConstraintProxy, rhs: UILayoutPriority) -> MASSwiftConstraintProxy {
    return lhs.priority(rhs.rawValue)
}
#endif

// MARK: - 便捷全局函数

/// 快速创建等宽/等高约束的辅助函数
///
/// - Parameter views: 需要设置等宽/等高的视图数组
/// - Returns: 视图数组，支持链式调用
@MainActor
@discardableResult
public func MASEqualSize(_ views: [MASNativeView]) -> [MASNativeView] {
    guard views.count > 1, let firstView = views.first else { return views }
    for view in views.dropFirst() {
        view.mas.makeConstraints { make in
            make.size.equalTo(firstView)
        }
    }
    return views
}

// MARK: - 便捷约束方法（与 ObjC API 命名一致）

#if canImport(UIKit)

/// 提供与原版 Masonry ObjC API 命名一致的便捷布局方法
///
/// ## 用法示例
///
/// ```swift
/// // 创建约束（对应 ObjC 的 mas_makeConstraints:）
/// view.masMakeConstraints {
///     $0.edges.equalTo(superview).inset(16)
/// }
///
/// // 更新约束（对应 ObjC 的 mas_updateConstraints:）
/// view.masUpdateConstraints {
///     $0.height.equalTo(100)
/// }
///
/// // 重建约束（对应 ObjC 的 mas_remakeConstraints:）
/// view.masRemakeConstraints {
///     $0.top.equalTo(superview.mas.top).offset(20)
///     $0.left.right.equalTo(superview)
///     $0.height.equalTo(44)
/// }
/// ```
extension UIView {

    /// 创建并安装约束（对应 ObjC `mas_makeConstraints:`）
    ///
    /// - Parameter builder: 约束构建闭包，参数 `$0` 为 `MASSwiftMakerProxy`
    /// - Returns: 已安装的约束数组
    @MainActor
    @discardableResult
    public func masMakeConstraints(_ builder: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        mas.makeConstraints(builder)
    }

    /// 更新已有约束（对应 ObjC `mas_updateConstraints:`）
    ///
    /// - Parameter builder: 约束构建闭包
    /// - Returns: 已创建/更新的约束数组
    @MainActor
    @discardableResult
    public func masUpdateConstraints(_ builder: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        mas.updateConstraints(builder)
    }

    /// 移除所有约束后重新创建（对应 ObjC `mas_remakeConstraints:`）
    ///
    /// - Parameter builder: 约束构建闭包
    /// - Returns: 已创建的约束数组
    @MainActor
    @discardableResult
    public func masRemakeConstraints(_ builder: (_ make: MASSwiftMakerProxy) -> Void) -> [MASConstraint] {
        mas.remakeConstraints(builder)
    }
}

#endif

// MARK: - MASConstraint 便捷扩展

extension MASConstraint {

    /// 获取 Swift 友好的约束代理
    ///
    /// 通过此属性将 ObjC `MASConstraint` 转换为 `MASSwiftConstraintProxy`，
    /// 以使用 Swift 原生的链式调用语法。
    @MainActor
    public var swift: MASSwiftConstraintProxy {
        MASSwiftConstraintProxy(self)
    }
}
