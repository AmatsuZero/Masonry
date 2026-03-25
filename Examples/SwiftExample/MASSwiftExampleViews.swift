//
//  MASSwiftExampleViews.swift
//  Masonry
//
//  MasonrySwift API 使用示例 — 跨平台（iOS/macOS/tvOS）
//  此文件作为 SPM 编译目标，同时也是 MasonrySwift 的 API 文档。
//

import Masonry
import MasonrySwift

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 基础约束示例

/// 演示 MasonrySwift 基础布局：三个视图的经典布局
///
/// 对应 ObjC 版本：MASExampleBasicView
@MainActor
final class BasicExampleView: MASNativeView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let greenView = MASNativeView()
        let redView = MASNativeView()
        let blueView = MASNativeView()

        addSubview(greenView)
        addSubview(redView)
        addSubview(blueView)

        let padding: CGFloat = 10

        // ── 方式一：链式方法语法 ──
        greenView.mas.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.mas.top).offset(padding)
            make.left.equalTo(self.mas.left).offset(padding)
            make.bottom.equalTo(blueView.mas.top).offset(-padding)
            make.right.equalTo(redView.mas.left).offset(-padding)
            make.width.equalTo(redView)
            make.height.equalTo(redView)
            make.height.equalTo(blueView)
        }

        // ── 方式二：运算符语法 ──
        redView.mas.makeConstraints { make in
            make.top == self.mas.top + padding
            make.left == greenView.mas.right + padding
            make.bottom == blueView.mas.top - padding
            make.right == self.mas.right - padding
            make.width == greenView.mas.width
        }

        blueView.mas.makeConstraints { make in
            make.top == greenView.mas.bottom + padding
            make.left == self.mas.left + padding
            make.bottom == self.mas.bottom - padding
            make.right == self.mas.right - padding
        }
    }
}

// MARK: - 运算符与优先级示例

/// 演示运算符重载：==、>=、<=、*、/、~（优先级）
@MainActor
final class OperatorExampleView: MASNativeView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let container = MASNativeView()
        let child = MASNativeView()

        addSubview(container)
        addSubview(child)

        // 容器填满父视图，四边留 20pt
        container.mas.makeConstraints { make in
            make.edges.equalTo(self).inset(20)
        }

        // 子视图居中，宽度为容器的一半，高度至少 44pt
        child.mas.makeConstraints { make in
            make.center == container                              // 居中
            make.width.equalTo(container.mas.width).multipliedBy(0.5)  // 宽度乘法
            make.height >= 44                                     // 最小高度
            make.height.equalTo(container.mas.height).dividedBy(2).priorityLow()  // 最大高度
            (make.height == 100) ~ 750                            // 期望高度（优先级）
        }
    }
}

// MARK: - 复合属性示例

/// 演示 edges / size / center 复合属性
@MainActor
final class CompositeExampleView: MASNativeView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let innerView = MASNativeView()
        let centerBox = MASNativeView()

        addSubview(innerView)
        addSubview(centerBox)

        // edges: 四边约束 + insets
        #if canImport(UIKit)
        let insets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        #else
        let insets = NSEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        #endif

        innerView.mas.makeConstraints { make in
            make.edges.equalTo(self).insets(insets)
        }

        // size + center
        centerBox.mas.makeConstraints { make in
            make.center.equalTo(innerView)
            make.size.equalTo(100)
        }
    }
}

// MARK: - Update / Remake 示例

/// 演示 updateConstraints 和 remakeConstraints
@MainActor
final class UpdateExampleView: MASNativeView {

    private let box = MASNativeView()
    private var boxSize: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(box)

        // 初始约束
        box.mas.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(self.boxSize)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    /// 更新尺寸（已有约束就地更新，无需重建）
    func grow() {
        boxSize += 20
        box.mas.updateConstraints { make in
            make.size.equalTo(self.boxSize)
        }
    }

    /// 重建约束（先移除所有旧约束再重新创建）
    func resetToCorner() {
        boxSize = 50
        box.mas.remakeConstraints { make in
            make.top.left.equalTo(self).offset(20)
            make.size.equalTo(self.boxSize)
        }
    }
}

// MARK: - 视图分布示例

/// 演示 mas_distributeViews（等间距 / 等尺寸分布）
@MainActor
final class DistributeExampleView: MASNativeView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        var views: [MASNativeView] = []
        for _ in 0..<4 {
            let view = MASNativeView()
            addSubview(view)
            views.append(view)
        }

        // 水平等间距分布
        views.mas_distributeViews(
            along: .horizontal,
            withFixedSpacing: 10,
            leadSpacing: 20,
            tailSpacing: 20
        )

        // 垂直方向统一高度
        views.mas_makeConstraints { make in
            make.top == self.mas.top + 40
            make.height == 60
        }
    }
}

// MARK: - 调试键示例

/// 演示 mas.key 调试标识
@MainActor
final class DebugKeyExampleView: MASNativeView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let header = MASNativeView()
        let content = MASNativeView()

        addSubview(header)
        addSubview(content)

        // 设置调试键，约束冲突时可在控制台看到可读名称
        header.mas_key = "header"
        content.mas_key = "content"

        header.mas.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(60).key("headerHeight")
        }

        content.mas.makeConstraints { make in
            make.top.equalTo(header.mas.bottom).key("contentTop")
            make.left.bottom.right.equalTo(self)
        }
    }
}

// MARK: - 复合赋值运算符示例

/// 演示 += / -= 复合赋值运算符
@MainActor
final class CompoundAssignmentExampleView: MASNativeView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let box = MASNativeView()
        addSubview(box)

        box.mas.makeConstraints { make in
            // += / -= 设置偏移量
            make.top.left += 16
            make.right.bottom -= 16
            make.height >= 44
        }
    }
}
