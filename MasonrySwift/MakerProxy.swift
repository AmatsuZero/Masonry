//
//  MakerProxy.swift
//  Masonry
//
//  MASSwiftMakerProxy：为 MASConstraintMaker 提供 Swift 友好的属性访问代理
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
#endif

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

    /// 方向性四边约束（top, leading, bottom, trailing）
    ///
    /// 对齐 SnapKit 的 `directionalEdges`。
    /// 使用 leading/trailing 替代 left/right，支持 RTL 布局。
    public var directionalEdges: MASSwiftConstraintProxy {
        get {
            .init(maker.attributes(
                ConstraintAttribute(rawValue:
                    ConstraintAttribute.top.rawValue |
                    ConstraintAttribute.leading.rawValue |
                    ConstraintAttribute.bottom.rawValue |
                    ConstraintAttribute.trailing.rawValue
                )
            ))
        }
        set { /* 支持 += / -= 运算符 */ }
    }

    #if canImport(UIKit)
    /// 基于 Margin 的四边约束
    ///
    /// 对齐 SnapKit 的 `margins` 复合属性。
    public var margins: MASSwiftConstraintProxy {
        get {
            .init(maker.attributes(
                ConstraintAttribute(rawValue:
                    ConstraintAttribute.topMargin.rawValue |
                    ConstraintAttribute.leftMargin.rawValue |
                    ConstraintAttribute.bottomMargin.rawValue |
                    ConstraintAttribute.rightMargin.rawValue
                )
            ))
        }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 基于 Margin 的方向性四边约束
    ///
    /// 对齐 SnapKit 的 `directionalMargins` 复合属性。
    public var directionalMargins: MASSwiftConstraintProxy {
        get {
            .init(maker.attributes(
                ConstraintAttribute(rawValue:
                    ConstraintAttribute.topMargin.rawValue |
                    ConstraintAttribute.leadingMargin.rawValue |
                    ConstraintAttribute.bottomMargin.rawValue |
                    ConstraintAttribute.trailingMargin.rawValue
                )
            ))
        }
        set { /* 支持 += / -= 运算符 */ }
    }
    #endif

    // MARK: - 按位组合属性

    /// 通过按位或组合创建复合约束
    ///
    /// - Parameter attrs: `MASAttribute` 位掩码组合
    /// - Returns: 复合约束代理
    public func attributes(_ attrs: ConstraintAttribute) -> MASSwiftConstraintProxy {
        .init(maker.attributes(attrs))
    }

    // MARK: - 约束分组

    /// 将闭包中创建的约束组合为一个复合约束
    ///
    /// 对齐 SnapKit 中将多个约束作为一组管理的能力。
    /// 内部映射到 Masonry 的 `group` 方法。
    ///
    /// ```swift
    /// let group = make.group {
    ///     make.left.equalToSuperview().offset(16)
    ///     make.right.equalToSuperview().offset(-16)
    /// }
    /// group.priority(.high)
    /// ```
    ///
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 包含闭包中所有约束的复合约束代理
    @discardableResult
    public func group(_ closure: () -> Void) -> MASSwiftConstraintProxy {
        withoutActuallyEscaping(closure) { escapableClosure in
            .init(maker.group()(escapableClosure))
        }
    }
}
