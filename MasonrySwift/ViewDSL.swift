//
//  ViewDSL.swift
//  Masonry
//
//  MASViewDSL：视图命名空间代理，UIViewController 扩展，NSArray 扩展
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if SWIFT_PACKAGE
import Masonry
#endif

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
    public func makeConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        view.mas_makeConstraints { closure($0) }
    }

    /// 更新已有约束（存在则更新，不存在则创建）
    ///
    /// 等同于 ObjC 中的 `mas_updateConstraints:`。
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 已创建/更新的约束数组
    @discardableResult
    public func updateConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        view.mas_updateConstraints { closure($0) }
    }

    /// 移除所有已有约束后重新创建
    ///
    /// 等同于 ObjC 中的 `mas_remakeConstraints:`。
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 已创建的约束数组
    @discardableResult
    public func remakeConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        view.mas_remakeConstraints { closure($0) }
    }

    /// 移除当前视图上由 Masonry 安装的所有约束
    ///
    /// 对齐 SnapKit 的 `snp.removeConstraints()`。
    /// 内部通过获取已安装的约束并逐个卸载实现。
    public func removeConstraints() {
        let installed = MASViewConstraint.installedConstraints(for: view)
        installed.forEach { $0.uninstall() }
    }

    /// 创建约束但不立即安装
    ///
    /// 对齐 SnapKit 的 `snp.prepareConstraints(_:)`。
    /// 返回约束数组，可稍后通过 `activate()` / `install()` 手动激活。
    ///
    /// ```swift
    /// let constraints = view.mas.prepareConstraints { make in
    ///     make.edges.equalToSuperview()
    /// }
    /// // 稍后激活
    /// constraints.forEach { $0.install() }
    /// ```
    ///
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 已创建但未安装的约束数组
    public func prepareConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        view.mas_prepareConstraints { maker in
            closure(maker)
        }
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
        view.mas_closestCommonSuperview(otherView)
    }

    // MARK: - 调试键

    /// 获取或设置视图的调试标识键
    public var key: Any? {
        get { view.mas_key }
        set { view.mas_key = newValue }
    }

    #if canImport(UIKit)
    // MARK: - 内容优先级（对齐 SnapKit contentHugging / contentCompressionResistance）

    /// 水平方向内容拥抱优先级
    ///
    /// 对齐 SnapKit 的 `snp.contentHuggingHorizontalPriority`。
    public var contentHuggingHorizontalPriority: Float {
        get { view.contentHuggingPriority(for: .horizontal).rawValue }
        set { view.setContentHuggingPriority(UILayoutPriority(rawValue: newValue), for: .horizontal) }
    }

    /// 垂直方向内容拥抱优先级
    ///
    /// 对齐 SnapKit 的 `snp.contentHuggingVerticalPriority`。
    public var contentHuggingVerticalPriority: Float {
        get { view.contentHuggingPriority(for: .vertical).rawValue }
        set { view.setContentHuggingPriority(UILayoutPriority(rawValue: newValue), for: .vertical) }
    }

    /// 水平方向内容压缩阻力优先级
    ///
    /// 对齐 SnapKit 的 `snp.contentCompressionResistanceHorizontalPriority`。
    public var contentCompressionResistanceHorizontalPriority: Float {
        get { view.contentCompressionResistancePriority(for: .horizontal).rawValue }
        set { view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: newValue), for: .horizontal) }
    }

    /// 垂直方向内容压缩阻力优先级
    ///
    /// 对齐 SnapKit 的 `snp.contentCompressionResistanceVerticalPriority`。
    public var contentCompressionResistanceVerticalPriority: Float {
        get { view.contentCompressionResistancePriority(for: .vertical).rawValue }
        set { view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: newValue), for: .vertical) }
    }
    #endif

    #if canImport(AppKit)
    // MARK: - 内容优先级（macOS）

    /// 水平方向内容拥抱优先级
    public var contentHuggingHorizontalPriority: Float {
        get { view.contentHuggingPriority(for: .horizontal).rawValue }
        set { view.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: newValue), for: .horizontal) }
    }

    /// 垂直方向内容拥抱优先级
    public var contentHuggingVerticalPriority: Float {
        get { view.contentHuggingPriority(for: .vertical).rawValue }
        set { view.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: newValue), for: .vertical) }
    }

    /// 水平方向内容压缩阻力优先级
    public var contentCompressionResistanceHorizontalPriority: Float {
        get { view.contentCompressionResistancePriority(for: .horizontal).rawValue }
        set { view.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: newValue), for: .horizontal) }
    }

    /// 垂直方向内容压缩阻力优先级
    public var contentCompressionResistanceVerticalPriority: Float {
        get { view.contentCompressionResistancePriority(for: .vertical).rawValue }
        set { view.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: newValue), for: .vertical) }
    }
    #endif
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
        get { MASViewDSL(self) }
        // setter 仅用于让编译器允许对值类型属性赋值（如 view.mas.contentHuggingHorizontalPriority = 600）
        // MASViewDSL 的 setter 内部直接操作 view 引用，因此赋值已在 getter 返回的临时值上生效
        set { }
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
    public func mas_makeConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        (self as NSArray).mas_makeConstraints { closure($0) }
    }

    /// 批量更新约束
    ///
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 所有已创建/更新的约束数组
    @MainActor
    @discardableResult
    public func mas_updateConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        (self as NSArray).mas_updateConstraints { closure($0) }
    }

    /// 批量移除所有约束后重新创建
    ///
    /// - Parameter closure: 约束构建闭包
    /// - Returns: 所有已创建的约束数组
    @MainActor
    @discardableResult
    public func mas_remakeConstraints(_ closure: (_ make: MASConstraintMaker) -> Void) -> [MASConstraint] {
        (self as NSArray).mas_remakeConstraints { closure($0) }
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
