//
//  Operators.swift
//  Masonry
//
//  运算符重载：约束关系运算符、算术运算符、复合赋值运算符、优先级运算符
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
#endif

// MARK: - MASConstraint 运算符重载

// ── 关系运算符：MASViewAttribute ──

/// 等于运算符：设置约束等于视图属性
///
/// ```swift
/// make.top == superview.mas.top
/// make.width == otherView.mas.width
/// ```
@MainActor
@discardableResult
public func == (lhs: MASConstraint, rhs: ViewAttribute) -> MASConstraint {
    return lhs.equalTo(rhs)
}

/// 大于等于运算符：设置约束大于等于视图属性
@MainActor
@discardableResult
public func >= (lhs: MASConstraint, rhs: ViewAttribute) -> MASConstraint {
    return lhs.greaterThanOrEqualTo(rhs)
}

/// 小于等于运算符：设置约束小于等于视图属性
@MainActor
@discardableResult
public func <= (lhs: MASConstraint, rhs: ViewAttribute) -> MASConstraint {
    return lhs.lessThanOrEqualTo(rhs)
}

// ── 关系运算符：UIView / NSView ──

#if canImport(UIKit)
/// 等于运算符：设置约束等于另一个视图（自动匹配同名属性）
///
/// ```swift
/// make.center == container
/// make.edges == superview
/// ```
@MainActor
@discardableResult
public func == (lhs: MASConstraint, rhs: UIView) -> MASConstraint {
    return lhs.equalTo(rhs)
}

/// 大于等于运算符：设置约束大于等于另一个视图
@MainActor
@discardableResult
public func >= (lhs: MASConstraint, rhs: UIView) -> MASConstraint {
    return lhs.greaterThanOrEqualTo(rhs)
}

/// 小于等于运算符：设置约束小于等于另一个视图
@MainActor
@discardableResult
public func <= (lhs: MASConstraint, rhs: UIView) -> MASConstraint {
    return lhs.lessThanOrEqualTo(rhs)
}
#elseif canImport(AppKit)
/// 等于运算符：设置约束等于另一个视图（自动匹配同名属性）
@MainActor
@discardableResult
public func == (lhs: MASConstraint, rhs: NSView) -> MASConstraint {
    return lhs.equalTo(rhs)
}

/// 大于等于运算符：设置约束大于等于另一个视图
@MainActor
@discardableResult
public func >= (lhs: MASConstraint, rhs: NSView) -> MASConstraint {
    return lhs.greaterThanOrEqualTo(rhs)
}

/// 小于等于运算符：设置约束小于等于另一个视图
@MainActor
@discardableResult
public func <= (lhs: MASConstraint, rhs: NSView) -> MASConstraint {
    return lhs.lessThanOrEqualTo(rhs)
}
#endif

// ── 关系运算符：CGFloat（数值字面量）──
///
/// ```swift
/// make.width == 100
/// make.height == 44.5
/// ```
@MainActor
@discardableResult
public func == (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
    return lhs.equalTo(NSNumber(value: Double(rhs)))
}

/// 大于等于运算符：设置约束大于等于数值
///
/// ```swift
/// make.height >= 44
/// ```
@MainActor
@discardableResult
public func >= (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
    return lhs.greaterThanOrEqualTo(NSNumber(value: Double(rhs)))
}

/// 小于等于运算符：设置约束小于等于数值
///
/// ```swift
/// make.width <= 320
/// ```
@MainActor
@discardableResult
public func <= (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
    return lhs.lessThanOrEqualTo(NSNumber(value: Double(rhs)))
}

// MARK: - MASAttributeOffset 运算符重载（支持 make.left == view.mas.right + 10）

/// 等于运算符：设置约束等于视图属性 + 偏移量
///
/// ```swift
/// make.left == label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func == (lhs: MASConstraint, rhs: MASAttributeOffset) -> MASConstraint {
    return lhs.equalTo(rhs.attribute).offset(rhs.offset)
}

/// 大于等于运算符：设置约束大于等于视图属性 + 偏移量
///
/// ```swift
/// make.left >= label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func >= (lhs: MASConstraint, rhs: MASAttributeOffset) -> MASConstraint {
    return lhs.greaterThanOrEqualTo(rhs.attribute).offset(rhs.offset)
}

/// 小于等于运算符：设置约束小于等于视图属性 + 偏移量
///
/// ```swift
/// make.left <= label.mas.right + 10
/// ```
@MainActor
@discardableResult
public func <= (lhs: MASConstraint, rhs: MASAttributeOffset) -> MASConstraint {
    return lhs.lessThanOrEqualTo(rhs.attribute).offset(rhs.offset)
}

/// 乘法运算符：设置约束的乘数
///
/// ```swift
/// make.width == superview.mas.width * 0.5
/// ```
@MainActor
@discardableResult
public func * (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
    return lhs.multipliedBy(rhs)
}

/// 除法运算符：设置约束的除数
///
/// ```swift
/// make.width == superview.mas.width / 2
/// ```
@MainActor
@discardableResult
public func / (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
    return lhs.dividedBy(rhs)
}

/// 加法运算符：设置约束的偏移量
///
/// ```swift
/// make.top == superview.mas.top + 20
/// ```
@MainActor
@discardableResult
public func + (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
    return lhs.offset(rhs)
}

/// 减法运算符：设置约束的负偏移量
///
/// ```swift
/// make.bottom == superview.mas.bottom - 20
/// ```
@MainActor
@discardableResult
public func - (lhs: MASConstraint, rhs: CGFloat) -> MASConstraint {
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
public func += (lhs: inout MASConstraint, rhs: CGFloat) {
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
public func -= (lhs: inout MASConstraint, rhs: CGFloat) {
    lhs = lhs.offset(-rhs)
}

/// 复合加法赋值运算符：增加约束偏移量（Int）
@MainActor
public func += (lhs: inout MASConstraint, rhs: Int) {
    lhs = lhs.offset(CGFloat(rhs))
}

/// 复合减法赋值运算符：减少约束偏移量（Int）
@MainActor
public func -= (lhs: inout MASConstraint, rhs: Int) {
    lhs = lhs.offset(CGFloat(-rhs))
}

/// 复合加法赋值运算符：增加约束偏移量（Double）
@MainActor
public func += (lhs: inout MASConstraint, rhs: Double) {
    lhs = lhs.offset(CGFloat(rhs))
}

/// 复合减法赋值运算符：减少约束偏移量（Double）
@MainActor
public func -= (lhs: inout MASConstraint, rhs: Double) {
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
public func ~ (lhs: MASConstraint, rhs: Float) -> MASConstraint {
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
public func ~ (lhs: MASConstraint, rhs: UILayoutPriority) -> MASConstraint {
    return lhs.priority(rhs.rawValue)
}
#endif

/// 使用自定义运算符设置约束优先级（MASConstraintPriority 枚举）
///
/// 对齐 SnapKit 的 `.priority(.high)` 风格。
///
/// ```swift
/// make.width == 100 ~ .high
/// make.height == 44 ~ .medium
/// make.left == 0 ~ .required
/// ```
@MainActor
@discardableResult
public func ~ (lhs: MASConstraint, rhs: MASConstraintPriority) -> MASConstraint {
    return lhs.priority(rhs.value)
}
