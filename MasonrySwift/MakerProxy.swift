//
//  MakerProxy.swift
//  Masonry
//
//  MASConstraintMaker Extension：为 MASConstraintMaker 提供 Swift 友好的属性访问
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
#endif

// MARK: - MASConstraintMaker Extension（Swift 友好的属性访问）

extension MASConstraintMaker {

    // MARK: - 属性链（将 ObjC 方法包装为 Swift 计算属性，支持 make.left.top 语法）
    //
    // ObjC 中 left、top 等现在是方法声明（返回 MASConstraint *），在 Swift 中桥接为 func left() -> MASConstraint。
    // 为了支持 make.left 的属性语法（无需括号），这里将它们包装为计算属性。
    // setter 为空实现，用于支持 += / -= 复合赋值运算符。

    /// 左边距约束
    @MainActor
    public var left: MASConstraint {
        get { self.left() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 顶部约束
    @MainActor
    public var top: MASConstraint {
        get { self.top() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 右边距约束
    @MainActor
    public var right: MASConstraint {
        get { self.right() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 底部约束
    @MainActor
    public var bottom: MASConstraint {
        get { self.bottom() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 前导约束
    @MainActor
    public var leading: MASConstraint {
        get { self.leading() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尾随约束
    @MainActor
    public var trailing: MASConstraint {
        get { self.trailing() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 宽度约束
    @MainActor
    public var width: MASConstraint {
        get { self.width() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 高度约束
    @MainActor
    public var height: MASConstraint {
        get { self.height() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 水平中心约束
    @MainActor
    public var centerX: MASConstraint {
        get { self.centerX() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 垂直中心约束
    @MainActor
    public var centerY: MASConstraint {
        get { self.centerY() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 基线约束
    @MainActor
    public var baseline: MASConstraint {
        get { self.baseline() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 首行基线约束
    @MainActor
    public var firstBaseline: MASConstraint {
        get { self.firstBaseline() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 末行基线约束
    @MainActor
    public var lastBaseline: MASConstraint {
        get { self.lastBaseline() }
        set { /* 支持 += / -= 运算符 */ }
    }

    #if canImport(UIKit)
    /// 左边距（基于 Margin）
    @MainActor
    public var leftMargin: MASConstraint {
        get { self.leftMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 右边距（基于 Margin）
    @MainActor
    public var rightMargin: MASConstraint {
        get { self.rightMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 顶部边距（基于 Margin）
    @MainActor
    public var topMargin: MASConstraint {
        get { self.topMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 底部边距（基于 Margin）
    @MainActor
    public var bottomMargin: MASConstraint {
        get { self.bottomMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 前导边距（基于 Margin）
    @MainActor
    public var leadingMargin: MASConstraint {
        get { self.leadingMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尾随边距（基于 Margin）
    @MainActor
    public var trailingMargin: MASConstraint {
        get { self.trailingMargin() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 水平中心（基于 Margin）
    @MainActor
    public var centerXWithinMargins: MASConstraint {
        get { self.centerXWithinMargins() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 垂直中心（基于 Margin）
    @MainActor
    public var centerYWithinMargins: MASConstraint {
        get { self.centerYWithinMargins() }
        set { /* 支持 += / -= 运算符 */ }
    }
    #endif

    // MARK: - 复合属性（将 ObjC 方法包装为 Swift 计算属性）

    /// 四边约束（top, left, bottom, right）
    @MainActor
    public var edges: MASConstraint {
        get { self.edges() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 尺寸约束（width, height）
    @MainActor
    public var size: MASConstraint {
        get { self.size() }
        set { /* 支持 += / -= 运算符 */ }
    }
    /// 中心约束（centerX, centerY）
    @MainActor
    public var center: MASConstraint {
        get { self.center() }
        set { /* 支持 += / -= 运算符 */ }
    }

    // MARK: - 扩展复合属性

    /// 方向性四边约束（top, leading, bottom, trailing）
    ///
    /// 对齐 SnapKit 的 `directionalEdges`。
    /// 使用 leading/trailing 替代 left/right，支持 RTL 布局。
    @MainActor
    public var directionalEdges: MASConstraint {
        get {
            let block: (ConstraintAttribute) -> MASConstraint = self.attributes()
            return block(
                ConstraintAttribute(rawValue:
                    ConstraintAttribute.top.rawValue |
                    ConstraintAttribute.leading.rawValue |
                    ConstraintAttribute.bottom.rawValue |
                    ConstraintAttribute.trailing.rawValue
                )
            )
        }
        set { /* 支持 += / -= 运算符 */ }
    }

    #if canImport(UIKit)
    /// 基于 Margin 的四边约束
    ///
    /// 对齐 SnapKit 的 `margins` 复合属性。
    @MainActor
    public var margins: MASConstraint {
        get {
            let block: (ConstraintAttribute) -> MASConstraint = self.attributes()
            return block(
                ConstraintAttribute(rawValue:
                    ConstraintAttribute.topMargin.rawValue |
                    ConstraintAttribute.leftMargin.rawValue |
                    ConstraintAttribute.bottomMargin.rawValue |
                    ConstraintAttribute.rightMargin.rawValue
                )
            )
        }
        set { /* 支持 += / -= 运算符 */ }
    }

    /// 基于 Margin 的方向性四边约束
    ///
    /// 对齐 SnapKit 的 `directionalMargins` 复合属性。
    @MainActor
    public var directionalMargins: MASConstraint {
        get {
            let block: (ConstraintAttribute) -> MASConstraint = self.attributes()
            return block(
                ConstraintAttribute(rawValue:
                    ConstraintAttribute.topMargin.rawValue |
                    ConstraintAttribute.leadingMargin.rawValue |
                    ConstraintAttribute.bottomMargin.rawValue |
                    ConstraintAttribute.trailingMargin.rawValue
                )
            )
        }
        set { /* 支持 += / -= 运算符 */ }
    }
    #endif

    // MARK: - 按位组合属性

    /// 通过按位或组合创建复合约束
    ///
    /// - Parameter attrs: `MASAttribute` 位掩码组合
    /// - Returns: 复合约束
    @MainActor
    public func attributes(_ attrs: ConstraintAttribute) -> MASConstraint {
        // ObjC 方法 `- (MASConstraint *(^)(MASAttribute))attributes` 桥接为
        // `func attributes() -> (ConstraintAttribute) -> MASConstraint`
        // 先调用无参方法获取 block，再传入参数
        let block: (ConstraintAttribute) -> MASConstraint = self.attributes()
        return block(attrs)
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
    /// - Returns: 包含闭包中所有约束的复合约束
    @MainActor
    @discardableResult
    public func group(_ closure: () -> Void) -> MASConstraint {
        withoutActuallyEscaping(closure) { escapableClosure in
            self.group()(escapableClosure)
        }
    }
}
