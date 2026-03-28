//
//  MASSwiftExampleViews.swift
//  Masonry
//
//  MasonrySwift API 使用示例（iOS）
//  此文件作为 SPM 编译目标，同时也是 MasonrySwift 的 API 文档。
//

import UIKit
import Masonry
import MasonrySwift

// MARK: - 基础约束示例

/// 演示 MasonrySwift 基础布局：三个视图的经典 T 形排列
///
/// 技术要点：
/// - 链式方法语法 vs 运算符语法（两种等价写法）
/// - `greaterThanOrEqualTo` 设置最小间距
/// - `equalTo(anotherView)` 实现等宽 / 等高约束
@MainActor
public final class BasicExampleView: MASNativeView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let greenView = MASNativeView()
        greenView.backgroundColor = .systemGreen

        let redView = MASNativeView()
        redView.backgroundColor = .systemRed

        let blueView = MASNativeView()
        blueView.backgroundColor = .systemBlue

        addSubview(greenView)
        addSubview(redView)
        addSubview(blueView)

        let padding: CGFloat = 10

        // ── 方式一：链式方法语法 ──
        // 适合约束较多的场景，可读性好
        greenView.mas.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.mas.top).offset(padding)
            make.left.equalTo(self.mas.left).offset(padding)
            make.bottom.equalTo(blueView.mas.top).offset(-padding)
            make.right.equalTo(redView.mas.left).offset(-padding)
            make.width.equalTo(redView)   // 与 redView 等宽
            make.height.equalTo(redView)  // 与 redView 等高
            make.height.equalTo(blueView) // 与 blueView 等高
        }

        // ── 方式二：运算符语法 ──
        // 更接近数学表达式，简洁直观
        redView.mas.makeConstraints { make in
            make.top    == self.mas.top    + padding
            make.left   == greenView.mas.right + padding
            make.bottom == blueView.mas.top - padding
            make.right  == self.mas.right  - padding
            make.width  == greenView.mas.width
        }

        blueView.mas.makeConstraints { make in
            make.top    == greenView.mas.bottom + padding
            make.left   == self.mas.left   + padding
            make.bottom == self.mas.bottom - padding
            make.right  == self.mas.right  - padding
        }
    }
}

// MARK: - 运算符与优先级示例

/// 演示运算符重载与约束优先级
///
/// 技术要点：
/// - `==`、`>=`、`<=` 关系运算符
/// - `multipliedBy` / `dividedBy` 乘除修饰
/// - `~` 运算符设置优先级（支持 Float 和 `MASConstraintPriority` 枚举）
/// - `priorityLow` / `priorityMedium` / `priorityHigh` 快捷方法
@MainActor
public final class OperatorExampleView: MASNativeView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let container = MASNativeView()
        container.backgroundColor = UIColor.systemGray5
        container.layer.cornerRadius = 8

        let child = MASNativeView()
        child.backgroundColor = .systemOrange
        child.layer.cornerRadius = 6

        addSubview(container)
        addSubview(child)

        // 容器填满父视图，四边留 20pt
        container.mas.makeConstraints { make in
            make.edges.equalTo(self).inset(20)
        }

        // 子视图演示各种约束修饰符
        child.mas.makeConstraints { make in
            // center == view：居中（等价于 equalTo(container)）
            make.center == container

            // multipliedBy：宽度 = 容器的 50%
            make.width.equalTo(container.mas.width).multipliedBy(0.5)

            // >= 最小高度（必须满足）
            make.height >= 44

            // dividedBy + priorityLow：期望高度 = 容器 /2（低优先级，可被覆盖）
            make.height.equalTo(container.mas.height).dividedBy(2).priorityLow()

            // ~ 数字：期望高度 100pt（优先级 750）
            (make.height == 100) ~ 750
        }
    }
}

// MARK: - 复合属性示例

/// 演示 edges / size / center 复合属性，一行代码同时约束多个维度
///
/// 技术要点：
/// - `make.edges` = top + left + bottom + right
/// - `make.size`  = width + height
/// - `make.center` = centerX + centerY
/// - `.insets(UIEdgeInsets)` 为四边分别设置不同的缩进量
@MainActor
public final class CompositeExampleView: MASNativeView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // 带边框的容器（演示 edges + insets）
        let borderView = MASNativeView()
        borderView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.12)
        borderView.layer.borderColor = UIColor.systemTeal.cgColor
        borderView.layer.borderWidth = 2
        borderView.layer.cornerRadius = 8
        addSubview(borderView)

        // 居中方块（演示 size + center）
        let centerBox = MASNativeView()
        centerBox.backgroundColor = .systemIndigo
        centerBox.layer.cornerRadius = 6
        addSubview(centerBox)

        // edges.insets：四边非对称缩进
        let insets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
        borderView.mas.makeConstraints { make in
            make.edges.equalTo(self).insets(insets)
        }

        // size.equalTo(scalar)：宽高同时设为 100
        // center.equalTo(view)：与 borderView 居中对齐
        centerBox.mas.makeConstraints { make in
            make.center.equalTo(borderView)
            make.size.equalTo(100)
        }
    }
}

// MARK: - Update / Remake 示例

/// 演示 updateConstraints 和 remakeConstraints 的使用场景与区别
///
/// 技术要点：
/// - `updateConstraints`：找到已有约束并就地更新 `constant`，不会重建约束对象，性能更好
/// - `remakeConstraints`：先移除所有 Masonry 约束，再全量重建，适合布局模式彻底切换
/// - 配合 `UIView.animate + layoutIfNeeded()` 实现流畅动画
///
/// 交互：点击方块查看效果
@MainActor
public final class UpdateExampleView: MASNativeView {

    private let box = MASNativeView()
    private let stateLabel = UILabel()
    private var step = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func setupViews() {
        box.backgroundColor = .systemBlue
        box.layer.cornerRadius = 8
        addSubview(box)

        stateLabel.text = "点击方块"
        stateLabel.textColor = .secondaryLabel
        stateLabel.font = .systemFont(ofSize: 14)
        stateLabel.textAlignment = .center
        addSubview(stateLabel)

        stateLabel.mas.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.mas.bottom).offset(-30)
        }

        // 初始约束：居中 60×60
        box.mas.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(60)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        box.addGestureRecognizer(tap)
        box.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        step = (step + 1) % 4
        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.applyStep()
            self.layoutIfNeeded()
        }
    }

    private func applyStep() {
        switch step {
        case 1:
            // updateConstraints：只更新 size，center 约束保持不变
            stateLabel.text = "updateConstraints → 尺寸扩大至 120"
            box.backgroundColor = .systemOrange
            box.mas.updateConstraints { make in
                make.size.equalTo(120)
            }
        case 2:
            // 继续 updateConstraints：再次扩大
            stateLabel.text = "updateConstraints → 继续扩大至 180"
            box.backgroundColor = .systemRed
            box.mas.updateConstraints { make in
                make.size.equalTo(180)
            }
        case 3:
            // remakeConstraints：布局模式完全切换（移到左上角）
            stateLabel.text = "remakeConstraints → 位置 + 尺寸全部重置"
            box.backgroundColor = .systemGreen
            box.mas.remakeConstraints { make in
                make.top.left.equalTo(self).offset(30)
                make.size.equalTo(60)
            }
        default:
            // 回到初始状态
            stateLabel.text = "点击方块"
            box.backgroundColor = .systemBlue
            box.mas.remakeConstraints { make in
                make.center.equalTo(self)
                make.size.equalTo(60)
            }
        }
    }

    /// 供外部调用：增大尺寸
    public func grow() {
        let current = step
        step = 1
        applyStep()
        step = current
    }

    /// 供外部调用：重置到左上角
    public func resetToCorner() {
        step = 3
        applyStep()
    }
}

// MARK: - 视图分布示例

/// 演示 mas_distributeViews 实现等间距 / 等尺寸视图分布
///
/// 技术要点：
/// - `withFixedSpacing`：视图间距固定，视图尺寸自适应
/// - `withFixedItemLength`：视图尺寸固定，间距自适应
/// - `.horizontal` 水平分布；`.vertical` 垂直分布
/// - `mas_makeConstraints` 批量约束数组中所有视图
@MainActor
public final class DistributeExampleView: MASNativeView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // ── 水平等间距分布（固定间距 10pt，两端留 20pt）──
        let topColors: [UIColor] = [.systemRed, .systemOrange, .systemGreen, .systemBlue]
        var topRow: [MASNativeView] = []
        for color in topColors {
            let v = MASNativeView()
            v.backgroundColor = color
            v.layer.cornerRadius = 6
            addSubview(v)
            topRow.append(v)
        }

        topRow.mas_distributeViews(along: .horizontal,
                                   withFixedSpacing: 10,
                                   leadSpacing: 20,
                                   tailSpacing: 20)
        topRow.mas_makeConstraints { make in
            make.top == self.mas.top + 30
            make.height == 60
        }

        // ── 垂直等尺寸分布（固定视图高度 50pt）──
        let colColors: [UIColor] = [.systemPurple, .systemTeal, .systemPink]
        var sideCol: [MASNativeView] = []
        for color in colColors {
            let v = MASNativeView()
            v.backgroundColor = color
            v.layer.cornerRadius = 6
            addSubview(v)
            sideCol.append(v)
        }

        sideCol.mas_distributeViews(along: .vertical,
                                    withFixedItemLength: 50,
                                    leadSpacing: 20,
                                    tailSpacing: 20)
        sideCol.mas_makeConstraints { make in
            make.top == topRow.first!.mas.bottom + 20
            make.centerX == self.mas.centerX
            make.width == 80
        }
    }
}

// MARK: - 调试键示例

/// 演示 mas_key / constraint.key() / .labeled() 调试标识
///
/// 技术要点：
/// - `view.mas_key = "name"` → 约束描述中显示视图名而非内存地址
/// - `make.xxx.key("label")` → 单条约束的调试标识
/// - `make.xxx.labeled("label")` → 等价写法（SnapKit 对齐别名）
/// - 在 LLDB 中执行 `po view.constraints` 可看到可读的约束名称
@MainActor
public final class DebugKeyExampleView: MASNativeView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let header = MASNativeView()
        header.backgroundColor = .systemBlue

        let content = MASNativeView()
        content.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)

        addSubview(header)
        addSubview(content)

        // 视图级调试键：约束冲突时控制台输出 "header" 而非内存地址
        header.mas_key = "header"
        content.mas_key = "content"

        let titleLabel = UILabel()
        titleLabel.text = "Header (mas_key = \"header\")"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 15)
        header.addSubview(titleLabel)
        titleLabel.mas.makeConstraints { make in
            make.center.equalTo(header)
        }

        // .key("label")：约束级调试标识
        header.mas.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(60).key("headerHeight")
        }

        // .labeled("label")：等价写法（SnapKit 对齐）
        content.mas.makeConstraints { make in
            make.top.equalTo(header.mas.bottom).labeled("contentTop")
            make.left.bottom.right.equalTo(self)
        }

        let hint = UILabel()
        hint.text = "在 LLDB 中执行：\n(lldb) po view.constraints\n\n即可看到标注了调试键的约束，\n方便定位布局冲突问题。"
        hint.textColor = .secondaryLabel
        hint.font = .systemFont(ofSize: 13)
        hint.numberOfLines = 0
        hint.textAlignment = .center
        content.addSubview(hint)

        hint.mas.makeConstraints { make in
            make.center.equalTo(content)
            make.left.right.equalTo(content).inset(20)
        }
    }
}

// MARK: - 复合赋值运算符示例

/// 演示 += / -= 复合赋值运算符（边距快捷设置）
///
/// 技术要点：
/// - `make.top.left += 16` 等价于 `make.top.left.equalToSuperview().offset(16)`
/// - `make.right.bottom -= 16` 等价于 `make.right.bottom.equalToSuperview().offset(-16)`
/// - 适合同方向多属性批量设置 offset 的场景，代码更简洁
@MainActor
public final class CompoundAssignmentExampleView: MASNativeView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let outer = MASNativeView()
        outer.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        outer.layer.borderColor = UIColor.systemPurple.cgColor
        outer.layer.borderWidth = 2
        outer.layer.cornerRadius = 8
        addSubview(outer)

        let inner = MASNativeView()
        inner.backgroundColor = .systemPurple
        inner.layer.cornerRadius = 6
        outer.addSubview(inner)

        outer.mas.makeConstraints { make in
            make.edges.equalTo(self).inset(30)
        }

        // += / -= 批量设置边距，等价于各自调用 offset
        inner.mas.makeConstraints { make in
            make.top.left    += 16  // top = outer.top + 16, left = outer.left + 16
            make.right.bottom -= 16 // right = outer.right - 16, bottom = outer.bottom - 16
        }

        let hint = UILabel()
        hint.text = "make.top.left += 16\nmake.right.bottom -= 16"
        hint.textColor = .white
        hint.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        hint.numberOfLines = 0
        hint.textAlignment = .center
        inner.addSubview(hint)

        hint.mas.makeConstraints { make in
            make.center.equalTo(inner)
            make.left.right.equalTo(inner).inset(8)
        }
    }
}

// MARK: - UIScrollView 示例

/// 演示 UIScrollView 的标准 Masonry 布局模式
///
/// 技术要点：
/// - `scrollView` 固定到父视图边缘
/// - `contentView` 四边 = scrollView + **宽度锁定** = 实现垂直滚动
/// - 不设置 `contentView.height` → Auto Layout 根据子视图自动计算滚动区域高度
/// - 最后一个子视图的 `bottom` 必须连接到 `contentView.bottom`，否则高度无法撑开
/// - 15 行 × 120pt = 1800pt 总高度，确保在各种设备上都能滚动
@MainActor
public final class ScrollViewExampleView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let scrollView = UIScrollView()
        addSubview(scrollView)

        // scrollView 贴满父视图
        scrollView.mas.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // contentView：承载所有滚动内容
        let contentView = UIView()
        scrollView.addSubview(contentView)

        // 关键三步：
        //   1. 四边贴 scrollView（建立滚动区域）
        //   2. 宽度 = scrollView（禁止横向滚动）
        //   3. 不设高度（由子视图自动撑开）
        contentView.mas.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 纵向堆叠多个色块（行数和高度足够多，确保可以滚动）
        let colors: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen,
            .systemTeal, .systemCyan, .systemBlue, .systemIndigo,
            .systemPurple, .systemPink, .systemBrown, .systemMint,
            .systemRed.withAlphaComponent(0.7),
            .systemOrange.withAlphaComponent(0.7),
            .systemGreen.withAlphaComponent(0.7),
        ]
        let items: [(UIColor, String)] = colors.enumerated().map { i, color in
            let suffix = (i == colors.count - 1) ? " — bottom → contentView.bottom" : ""
            return (color, "Row \(i + 1)\(suffix)")
        }

        var prevView: UIView? = nil
        for (i, item) in items.enumerated() {
            let row = UIView()
            row.backgroundColor = item.0
            contentView.addSubview(row)

            let label = UILabel()
            label.text = item.1
            label.textColor = .white
            label.font = .systemFont(ofSize: 15, weight: .medium)
            row.addSubview(label)

            row.mas.makeConstraints { make in
                make.left.right.equalTo(contentView)
                make.height.equalTo(120)  // 每行 120pt，15 行共 1800pt，确保可滚动
                if let prev = prevView {
                    make.top.equalTo(prev.mas.bottom)
                } else {
                    make.top.equalTo(contentView.mas.top)
                }
                // 最后一行的 bottom 必须连接到 contentView.bottom
                // Auto Layout 通过这条约束推算 contentView 的总高度
                if i == items.count - 1 {
                    make.bottom.equalTo(contentView.mas.bottom)
                }
            }

            label.mas.makeConstraints { make in
                make.centerY.equalTo(row)
                make.left.equalTo(row).offset(16)
            }

            prevView = row
        }
    }
}

// MARK: - 动画约束示例

/// 演示约束动画：配合 UIView.animate + layoutIfNeeded
///
/// 技术要点：
/// - 在动画块**之前**修改约束（remakeConstraints / updateConstraints）
/// - 在动画块**之内**调用 `setNeedsLayout()` + `layoutIfNeeded()`，
///   使约束变化以动画形式呈现
/// - `usingSpringWithDamping` 弹性动画参数调节弹跳感
///
/// 交互：点击方块触发展开 / 收起动画
@MainActor
public final class AnimatedExampleView: UIView {

    private let box = UIView()
    private let hintLabel = UILabel()
    private var isExpanded = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        box.backgroundColor = .systemBlue
        box.layer.cornerRadius = 12
        addSubview(box)

        hintLabel.text = "点击方块触发弹性动画"
        hintLabel.textColor = .secondaryLabel
        hintLabel.font = .systemFont(ofSize: 14)
        hintLabel.textAlignment = .center
        addSubview(hintLabel)

        hintLabel.mas.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.mas.bottom).offset(-40)
        }

        // 初始约束：居中，80×80
        box.mas.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(80)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleAnimation))
        box.addGestureRecognizer(tap)
        box.isUserInteractionEnabled = true
    }

    @objc private func toggleAnimation() {
        isExpanded.toggle()

        // Step 1：在动画块外修改约束（remakeConstraints 重建所有约束）
        box.mas.remakeConstraints { make in
            if self.isExpanded {
                make.centerX.equalTo(self)
                make.top.equalTo(self.mas.top).offset(60)
                make.width.equalTo(self).multipliedBy(0.8)
                make.height.equalTo(160)
            } else {
                make.center.equalTo(self)
                make.size.equalTo(80)
            }
        }

        // Step 2：在动画块内调用 layoutIfNeeded，约束变化以动画形式执行
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.65,
                       initialSpringVelocity: 0.8) {
            self.box.backgroundColor   = self.isExpanded ? .systemOrange : .systemBlue
            self.box.layer.cornerRadius = self.isExpanded ? 16 : 40
            self.layoutIfNeeded()
        }

        hintLabel.text = isExpanded ? "再次点击收起" : "点击方块触发弹性动画"
    }
}

// MARK: - 标签布局示例

/// 演示 UILabel 内容拥抱与压缩阻力（Content Hugging & Compression Resistance）
///
/// 技术要点：
/// - **Content Hugging Priority（内容拥抱优先级）**
///   - 默认值：水平 250，垂直 250
///   - 优先级越高，视图越"拥抱"自身内容，越不愿被拉伸超过内容尺寸
///   - 场景：徽标 / 价格标签等宽度应由内容决定的视图
///
/// - **Content Compression Resistance（内容压缩阻力优先级）**
///   - 默认值：水平 750，垂直 750
///   - 优先级越高，视图越不愿被压缩小于内容尺寸（不愿被截断）
///   - 场景：必须完整显示的关键信息（价格、电话号码等）
@MainActor
public final class LabelLayoutExampleView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // ── 场景一：Hugging ── 徽标紧贴内容，标题填充剩余空间
        let huggingTitle = makeSectionLabel("Hugging：徽标紧贴内容，标题填充剩余")
        addSubview(huggingTitle)
        huggingTitle.mas.makeConstraints { make in
            make.top.equalTo(self).offset(20)
            make.left.right.equalTo(self).inset(16)
        }

        let huggingRow = makeHuggingRow()
        addSubview(huggingRow)
        huggingRow.mas.makeConstraints { make in
            make.top.equalTo(huggingTitle.mas.bottom).offset(8)
            make.left.right.equalTo(self).inset(16)
            make.height.equalTo(52)
        }

        // ── 场景二：Compression Resistance ── 价格标签优先保持完整
        let comprTitle = makeSectionLabel("Compression Resistance：价格标签优先完整显示")
        addSubview(comprTitle)
        comprTitle.mas.makeConstraints { make in
            make.top.equalTo(huggingRow.mas.bottom).offset(24)
            make.left.right.equalTo(self).inset(16)
        }

        let comprRow = makeCompressionRow()
        addSubview(comprRow)
        comprRow.mas.makeConstraints { make in
            make.top.equalTo(comprTitle.mas.bottom).offset(8)
            make.left.right.equalTo(self).inset(16)
            make.height.equalTo(52)
        }
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }

    /// 场景一：图标 + 标题（低 hugging，可拉伸）+ 徽标（高 hugging，紧贴内容）
    private func makeHuggingRow() -> UIView {
        let row = UIView()
        row.backgroundColor = .secondarySystemBackground
        row.layer.cornerRadius = 8

        let iconView = UIView()
        iconView.backgroundColor = .systemBlue
        iconView.layer.cornerRadius = 6
        row.addSubview(iconView)
        iconView.mas.makeConstraints { make in
            make.left.equalTo(row).offset(12)
            make.centerY.equalTo(row)
            make.size.equalTo(32)
        }

        let titleLabel = UILabel()
        titleLabel.text = "MasonrySwift"
        titleLabel.font = .systemFont(ofSize: 16)
        row.addSubview(titleLabel)

        let badgeLabel = UILabel()
        badgeLabel.text = "NEW"
        badgeLabel.font = .boldSystemFont(ofSize: 11)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.layer.cornerRadius = 4
        badgeLabel.layer.masksToBounds = true
        row.addSubview(badgeLabel)

        // 提高 badge 的 hugging 优先级 → badge 按内容收缩，不被拉伸
        // 降低 title 的 hugging 优先级 → title 填充两者之间的剩余空间
        badgeLabel.mas.contentHuggingHorizontalPriority = 751
        titleLabel.mas.contentHuggingHorizontalPriority = 249

        titleLabel.mas.makeConstraints { make in
            make.left.equalTo(iconView.mas.right).offset(12)
            make.right.equalTo(badgeLabel.mas.left).offset(-8)
            make.centerY.equalTo(row)
        }
        badgeLabel.mas.makeConstraints { make in
            make.right.equalTo(row).offset(-12)
            make.centerY.equalTo(row)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(36)
        }
        return row
    }

    /// 场景二：商品标题（低压缩阻力，可被截断）vs 价格（高压缩阻力，优先完整）
    private func makeCompressionRow() -> UIView {
        let row = UIView()
        row.backgroundColor = .secondarySystemBackground
        row.layer.cornerRadius = 8

        let descLabel = UILabel()
        descLabel.text = "这是一段比较长的商品名称描述文本"
        descLabel.font = .systemFont(ofSize: 15)
        row.addSubview(descLabel)

        let priceLabel = UILabel()
        priceLabel.text = "¥99.00"
        priceLabel.font = .boldSystemFont(ofSize: 15)
        priceLabel.textColor = .systemRed
        row.addSubview(priceLabel)

        // descLabel 压缩阻力低 → 空间不够时优先截断商品名
        // priceLabel 压缩阻力高 → 价格始终完整显示
        descLabel.mas.contentCompressionResistanceHorizontalPriority = 749
        priceLabel.mas.contentCompressionResistanceHorizontalPriority = 751

        descLabel.mas.makeConstraints { make in
            make.left.equalTo(row).offset(12)
            make.right.equalTo(priceLabel.mas.left).offset(-8)
            make.centerY.equalTo(row)
        }
        priceLabel.mas.makeConstraints { make in
            make.right.equalTo(row).offset(-12)
            make.centerY.equalTo(row)
        }
        return row
    }
}

// MARK: - 宽高比约束示例

/// 演示 multipliedBy() 实现宽高比约束
///
/// 技术要点：
/// - `make.height.equalTo(view.mas.width).multipliedBy(ratio)` 实现固定宽高比
/// - 视图在任意尺寸下比例保持不变，无需硬编码具体数值
/// - 常见场景：视频播放器（16:9）、头像（1:1）、Banner（2:1）
@MainActor
public final class AspectRatioExampleView: UIView {

    private var avatarView: UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // ── 16:9 视频占位图 ──
        let videoView = UIView()
        videoView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        videoView.layer.cornerRadius = 8
        videoView.clipsToBounds = true
        addSubview(videoView)

        let videoLabel = makeCenteredLabel("▶  16 : 9", font: .boldSystemFont(ofSize: 18))
        videoView.addSubview(videoLabel)

        videoView.mas.makeConstraints { make in
            make.top.equalTo(self.mas.safeAreaTop).offset(20)
            make.left.right.equalTo(self).inset(16)
            // height = width × (9/16)：始终维持 16:9 比例
            make.height.equalTo(videoView.mas.width).multipliedBy(9.0 / 16.0)
        }
        videoLabel.mas.makeConstraints { make in make.center.equalTo(videoView) }

        // ── 1:1 头像占位图 ──
        let avatar = UIView()
        avatar.backgroundColor = .systemBlue
        addSubview(avatar)
        avatarView = avatar

        let avatarLabel = makeCenteredLabel("1 : 1", font: .boldSystemFont(ofSize: 16))
        avatar.addSubview(avatarLabel)

        avatar.mas.makeConstraints { make in
            make.top.equalTo(videoView.mas.bottom).offset(24)
            make.centerX.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.35)
            make.height.equalTo(avatar.mas.width)  // height = width → 正方形 → 再配合 cornerRadius = width/2 变成圆形
        }
        avatarLabel.mas.makeConstraints { make in make.center.equalTo(avatar) }

        // ── 2:1 Banner 占位图 ──
        let bannerView = UIView()
        bannerView.backgroundColor = .systemGreen
        bannerView.layer.cornerRadius = 8
        addSubview(bannerView)

        let bannerLabel = makeCenteredLabel("2 : 1  Banner", font: .boldSystemFont(ofSize: 16))
        bannerView.addSubview(bannerLabel)

        bannerView.mas.makeConstraints { make in
            make.top.equalTo(avatar.mas.bottom).offset(24)
            make.left.right.equalTo(self).inset(16)
            make.height.equalTo(bannerView.mas.width).multipliedBy(0.5)  // height = width / 2 → 2:1
        }
        bannerLabel.mas.makeConstraints { make in make.center.equalTo(bannerView) }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 圆形头像：cornerRadius 必须在布局完成后（bounds 已确定）才能正确计算
        avatarView?.layer.cornerRadius = (avatarView?.bounds.width ?? 0) / 2
    }

    private func makeCenteredLabel(_ text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = font
        return label
    }
}

// MARK: - SnapKit 对齐新增 API 示例

/// 演示 MasonrySwift 对标 SnapKit 补充的新 API
///
/// 技术要点：
/// - `equalToSuperview()` / `greaterThanOrEqualToSuperview()` / `lessThanOrEqualToSuperview()`
///   — 等价于 `equalTo(self.superview!)`，但更简洁且 nil 安全
/// - `.labeled("name")` — 约束调试标签（等价于 `.key("name")`，对齐 SnapKit 命名）
/// - `.priority(.high / .medium / .low / .required)` — 语义化优先级枚举
/// - `make.group { }` — 对一组约束批量设置属性（如统一调整优先级）
/// - `mas.removeConstraints()` — 移除当前视图所有 Masonry 约束
/// - `mas.contentHuggingHorizontalPriority` — 内容拥抱优先级（对齐 SnapKit 属性名）
@MainActor
public final class SnapKitAlignedExampleView: UIView {

    private let redBox   = UIView()
    private let blueBox  = UIView()
    private let greenBox = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        redBox.backgroundColor = .systemRed
        redBox.layer.cornerRadius = 8
        addSubview(redBox)

        blueBox.backgroundColor = .systemBlue
        blueBox.layer.cornerRadius = 8
        addSubview(blueBox)

        greenBox.backgroundColor = .systemGreen
        greenBox.layer.cornerRadius = 8
        addSubview(greenBox)

        // ── equalToSuperview() + greaterThanOrEqualToSuperview() ──
        // 比 equalTo(superview!) 更简洁，内部做了 nil 检查
        redBox.mas.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(20).labeled("redMinTop")
            make.left.right.equalToSuperview().inset(16).labeled("redHorizontal")
            make.height.equalTo(50).priority(.high)  // 语义化优先级 → 750
        }

        // ── .priority(MASConstraintPriority) ──
        // .required=1000, .high=750, .medium=500, .low=250
        blueBox.mas.makeConstraints { make in
            make.top.equalTo(redBox.mas.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50).priority(.medium)  // 500
        }

        // ── make.group { } ── 批量设置一组约束的共同属性
        greenBox.mas.makeConstraints { make in
            let hGroup = make.group {
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }
            hGroup.priority(.high)  // 组内所有约束统一设为 .high

            make.top.equalTo(blueBox.mas.bottom).offset(12)
            make.height.equalTo(50)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        // 说明标签
        let hint = UILabel()
        hint.text = "演示 API：\nequalToSuperview() · labeled() · priority(.high)\n make.group { } · removeConstraints()"
        hint.textColor = .secondaryLabel
        hint.font = .systemFont(ofSize: 13)
        hint.numberOfLines = 0
        hint.textAlignment = .center
        addSubview(hint)

        hint.mas.makeConstraints { make in
            make.top.equalTo(greenBox.mas.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        // ── contentHuggingHorizontalPriority ──（SnapKit 对齐属性名）
        let label = UILabel()
        label.text = "mas.contentHuggingHorizontalPriority = 600"
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        addSubview(label)

        // 提高水平拥抱优先级，让 label 宽度紧贴文字内容
        label.mas.contentHuggingHorizontalPriority = 600

        label.mas.makeConstraints { make in
            make.top.equalTo(hint.mas.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }

    /// 演示 removeConstraints()：移除所有 Masonry 约束
    public func clearAllConstraints() {
        redBox.mas.removeConstraints()
        blueBox.mas.removeConstraints()
        greenBox.mas.removeConstraints()
    }
}
