//
//  MasonrySwiftCore.swift
//  Masonry
//
//  核心类型定义：跨平台类型别名、约束优先级枚举、视图属性偏移量组合
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// SPM 中 MasonrySwift 作为独立 target 依赖 Masonry ObjC target，需要显式导入模块
// CocoaPods 混编场景下此 import 也不会产生问题
import Masonry

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

// MARK: - MASConstraintPriority（约束优先级枚举，对齐 SnapKit ConstraintPriority）

/// 约束优先级枚举，提供与 SnapKit `ConstraintPriority` 对齐的语义化优先级值
///
/// ## 用法示例
///
/// ```swift
/// make.width == 100 ~ .high
/// make.height == 44 ~ .priority(600)
/// ```
public struct MASConstraintPriority: Equatable {

    /// 原始优先级值（0~1000）
    public let value: Float

    /// 以 Float 值初始化
    public init(_ value: Float) {
        self.value = value
    }

    /// 以 Int 值初始化
    public init(_ value: Int) {
        self.value = Float(value)
    }

    // MARK: - 预定义优先级

    /// 必须满足的约束（1000）
    public static let required = MASConstraintPriority(1000)
    /// 高优先级（750）
    public static let high = MASConstraintPriority(750)
    /// 中优先级（500）
    public static let medium = MASConstraintPriority(500)
    /// 低优先级（250）
    public static let low = MASConstraintPriority(250)

    // MARK: - Equatable

    public static func == (lhs: MASConstraintPriority, rhs: MASConstraintPriority) -> Bool {
        lhs.value == rhs.value
    }
}

#if canImport(UIKit)
extension MASConstraintPriority {
    /// 从 UILayoutPriority 创建
    public init(_ priority: UILayoutPriority) {
        self.value = priority.rawValue
    }

    /// 转换为 UILayoutPriority
    public var layoutPriority: UILayoutPriority {
        UILayoutPriority(rawValue: value)
    }
}
#endif

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

/// 加法运算符：在已有 MASAttributeOffset 基础上累加偏移量（CGFloat）
///
/// ```swift
/// make.left == label.mas.right + spacing + 8
/// ```
@MainActor
@discardableResult
public func + (lhs: MASAttributeOffset, rhs: CGFloat) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs.attribute, offset: lhs.offset + rhs)
}

/// 加法运算符：在已有 MASAttributeOffset 基础上累加偏移量（Int）
@MainActor
@discardableResult
public func + (lhs: MASAttributeOffset, rhs: Int) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs.attribute, offset: lhs.offset + CGFloat(rhs))
}

/// 加法运算符：在已有 MASAttributeOffset 基础上累加偏移量（Double）
@MainActor
@discardableResult
public func + (lhs: MASAttributeOffset, rhs: Double) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs.attribute, offset: lhs.offset + CGFloat(rhs))
}

/// 减法运算符：在已有 MASAttributeOffset 基础上减去偏移量（CGFloat）
///
/// ```swift
/// make.bottom <= view.mas.bottom - panelHeight - 8
/// ```
@MainActor
@discardableResult
public func - (lhs: MASAttributeOffset, rhs: CGFloat) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs.attribute, offset: lhs.offset - rhs)
}

/// 减法运算符：在已有 MASAttributeOffset 基础上减去偏移量（Int）
@MainActor
@discardableResult
public func - (lhs: MASAttributeOffset, rhs: Int) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs.attribute, offset: lhs.offset - CGFloat(rhs))
}

/// 减法运算符：在已有 MASAttributeOffset 基础上减去偏移量（Double）
@MainActor
@discardableResult
public func - (lhs: MASAttributeOffset, rhs: Double) -> MASAttributeOffset {
    return MASAttributeOffset(attribute: lhs.attribute, offset: lhs.offset - CGFloat(rhs))
}
