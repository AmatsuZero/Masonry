//
//  Utilities.swift
//  Masonry
//
//  便捷全局函数、MASConstraint 扩展、UIView 便捷方法
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
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
    /// - Parameter builder: 约束构建闭包，参数 `$0` 为 `MASConstraintMaker`
    /// - Returns: 已安装的约束数组
    @MainActor
    @discardableResult
    public func masMakeConstraints(_ builder: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        mas.makeConstraints(builder)
    }

    /// 更新已有约束（对应 ObjC `mas_updateConstraints:`）
    ///
    /// - Parameter builder: 约束构建闭包
    /// - Returns: 已创建/更新的约束数组
    @MainActor
    @discardableResult
    public func masUpdateConstraints(_ builder: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        mas.updateConstraints(builder)
    }

    /// 移除所有约束后重新创建（对应 ObjC `mas_remakeConstraints:`）
    ///
    /// - Parameter builder: 约束构建闭包
    /// - Returns: 已创建的约束数组
    @MainActor
    @discardableResult
    public func masRemakeConstraints(_ builder: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        mas.remakeConstraints(builder)
    }
}

#endif

// MARK: - MASConstraint 便捷扩展（已迁移至 Extension）
// MASConstraint.swift 属性已不再需要，Extension 方法直接在 MASConstraint 上提供
