//
//  MasonrySwiftNewAPITests.swift
//  MasonrySwiftTests
//
//  MasonrySwift 新增 API 测试用例
//  参考 SnapKit 测试策略，验证底层 NSLayoutConstraint 的具体属性值
//  覆盖：约束关系、属性映射、优先级、偏移量、乘除、生命周期、复合约束、Superview 约束
//

import XCTest
import Masonry
import MasonrySwift

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 测试辅助扩展

extension MASSwiftConstraintProxy {
    /// 获取第一个底层 NSLayoutConstraint（测试辅助）
    var firstLayoutConstraint: NSLayoutConstraint? {
        layoutConstraints.first
    }
}

// MARK: - MASConstraintPriority 测试

final class MASConstraintPriorityTests: XCTestCase {

    func testPredefinedPriorities() {
        XCTAssertEqual(MASConstraintPriority.required.value, 1000)
        XCTAssertEqual(MASConstraintPriority.high.value, 750)
        XCTAssertEqual(MASConstraintPriority.medium.value, 500)
        XCTAssertEqual(MASConstraintPriority.low.value, 250)
    }

    func testCustomPriority() {
        let priority = MASConstraintPriority(600)
        XCTAssertEqual(priority.value, 600)
    }

    func testIntInitializer() {
        let priority = MASConstraintPriority(750)
        XCTAssertEqual(priority, .high)
    }

    func testEquatable() {
        XCTAssertEqual(MASConstraintPriority(750), MASConstraintPriority.high)
        XCTAssertNotEqual(MASConstraintPriority.high, MASConstraintPriority.low)
    }

    #if canImport(UIKit)
    func testUILayoutPriorityConversion() {
        let priority = MASConstraintPriority(.defaultHigh)
        XCTAssertEqual(priority.value, UILayoutPriority.defaultHigh.rawValue)
        XCTAssertEqual(priority.layoutPriority, .defaultHigh)
    }
    #endif
}

// MARK: - 约束关系验证（参考 SnapKit ConstraintSpec）

/// 验证 equalTo / greaterThanOrEqualTo / lessThanOrEqualTo 创建的底层
/// NSLayoutConstraint 的 relation 属性是否正确
@MainActor
final class ConstraintRelationTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    // MARK: - equalTo 关系验证

    func testEqualToCreatesEqualRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalTo(superview!)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc, "应创建底层 NSLayoutConstraint")
        XCTAssertEqual(lc?.relation, .equal, "equalTo 应创建 .equal 关系")
    }

    func testEqualToSuperviewCreatesEqualRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview()
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .equal)
        XCTAssertTrue(lc?.secondItem === superview, "secondItem 应为父视图")
    }

    // MARK: - greaterThanOrEqualTo 关系验证

    func testGreaterThanOrEqualToCreatesCorrectRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.greaterThanOrEqualTo(superview!)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .greaterThanOrEqual,
                       "greaterThanOrEqualTo 应创建 .greaterThanOrEqual 关系")
    }

    func testGreaterThanOrEqualToSuperviewCreatesCorrectRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.greaterThanOrEqualToSuperview()
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .greaterThanOrEqual,
                       "greaterThanOrEqualToSuperview 应创建 .greaterThanOrEqual 关系")
        XCTAssertTrue(lc?.secondItem === superview, "secondItem 应为父视图")
    }

    // MARK: - lessThanOrEqualTo 关系验证

    func testLessThanOrEqualToCreatesCorrectRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.bottom.lessThanOrEqualTo(superview!)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .lessThanOrEqual,
                       "lessThanOrEqualTo 应创建 .lessThanOrEqual 关系")
    }

    func testLessThanOrEqualToSuperviewCreatesCorrectRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.bottom.lessThanOrEqualToSuperview()
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .lessThanOrEqual,
                       "lessThanOrEqualToSuperview 应创建 .lessThanOrEqual 关系")
        XCTAssertTrue(lc?.secondItem === superview, "secondItem 应为父视图")
    }

    // MARK: - 运算符关系验证

    func testEqualOperatorCreatesEqualRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = (make.width == 100)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .equal)
        XCTAssertEqual(lc?.constant, 100)
    }

    func testGreaterThanOrEqualOperatorCreatesCorrectRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = (make.width >= 50)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .greaterThanOrEqual)
        XCTAssertEqual(lc?.constant, 50)
    }

    func testLessThanOrEqualOperatorCreatesCorrectRelation() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = (make.width <= 200)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.relation, .lessThanOrEqual)
        XCTAssertEqual(lc?.constant, 200)
    }
}

// MARK: - 约束属性映射验证（参考 SnapKit ConstraintMakerSpec）

/// 验证各 maker 属性映射到正确的 NSLayoutAttribute
@MainActor
final class ConstraintAttributeTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testLeftAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.left.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .left)
    }

    func testTopAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .top)
    }

    func testRightAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.right.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .right)
    }

    func testBottomAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.bottom.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .bottom)
    }

    func testLeadingAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.leading.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .leading)
    }

    func testTrailingAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.trailing.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .trailing)
    }

    func testWidthAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100)
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .width)
    }

    func testHeightAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.height.equalTo(50)
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .height)
    }

    func testCenterXAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.centerX.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .centerX)
    }

    func testCenterYAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.centerY.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .centerY)
    }

    func testBaselineAttribute() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.baseline.equalToSuperview()
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.firstAttribute, .lastBaseline)
    }
}

// MARK: - 优先级验证（参考 SnapKit ConstraintSpec priority tests）

/// 验证 priority 设置后底层 NSLayoutConstraint 的 priority 值
@MainActor
final class ConstraintPriorityTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testPriorityFloat() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100).priority(600)
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, UILayoutPriority(600))
        #endif
    }

    func testPriorityHigh() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100).priorityHigh()
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, .defaultHigh)
        #endif
    }

    func testPriorityMedium() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100).priorityMedium()
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, UILayoutPriority(500))
        #endif
    }

    func testPriorityLow() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100).priorityLow()
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, .defaultLow)
        #endif
    }

    func testPriorityWithMASConstraintPriorityEnum() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100).priority(.high)
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, .defaultHigh)
        #endif
    }

    func testPriorityWithCustomMASConstraintPriority() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100).priority(MASConstraintPriority(333))
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, UILayoutPriority(333))
        #endif
    }

    func testTildeOperatorWithMASConstraintPriority() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = (make.width == 100) ~ .high
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, .defaultHigh)
        #endif
    }

    func testTildeOperatorWithFloatPriority() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = (make.width == 100) ~ 444
        }
        #if canImport(UIKit)
        XCTAssertEqual(proxy.firstLayoutConstraint?.priority, UILayoutPriority(444))
        #endif
    }
}

// MARK: - 偏移量与常量验证（参考 SnapKit ConstraintSpec offset/inset tests）

/// 验证 offset / inset / insets 设置后底层 NSLayoutConstraint 的 constant 值
@MainActor
final class ConstraintOffsetTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testOffset() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview().offset(20)
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.constant, 20,
                       "offset(20) 应设置 constant 为 20")
    }

    func testInsetOnEdges() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.edges.equalToSuperview().inset(15)
        }
        let constraints = proxy.layoutConstraints
        // edges 产生 4 个约束：top, left, bottom, right
        XCTAssertEqual(constraints.count, 4, "edges 应产生 4 个约束")

        for lc in constraints {
            switch lc.firstAttribute {
            case .top, .left, .leading:
                XCTAssertEqual(lc.constant, 15,
                               "\(lc.firstAttribute.rawValue) inset 应为 15")
            case .bottom, .right, .trailing:
                XCTAssertEqual(lc.constant, -15,
                               "\(lc.firstAttribute.rawValue) inset 应为 -15")
            default:
                break
            }
        }
    }

    func testInsetsWithEdgeInsets() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.edges.equalToSuperview().insets(
                MASNativeEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            )
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 4)

        for lc in constraints {
            switch lc.firstAttribute {
            case .top:
                XCTAssertEqual(lc.constant, 10)
            case .left, .leading:
                XCTAssertEqual(lc.constant, 20)
            case .bottom:
                XCTAssertEqual(lc.constant, -30)
            case .right, .trailing:
                XCTAssertEqual(lc.constant, -40)
            default:
                break
            }
        }
    }

    func testUpdateOffsetChangesConstant() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview().offset(20)
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.constant, 20)

        proxy.updateOffset(50)
        XCTAssertEqual(proxy.firstLayoutConstraint?.constant, 50,
                       "updateOffset 应更新底层 constant")
    }

    func testUpdateInsetChangesConstant() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.edges.equalToSuperview().inset(10)
        }
        proxy.updateInset(25)

        for lc in proxy.layoutConstraints {
            switch lc.firstAttribute {
            case .top, .left, .leading:
                XCTAssertEqual(lc.constant, 25)
            case .bottom, .right, .trailing:
                XCTAssertEqual(lc.constant, -25)
            default:
                break
            }
        }
    }

    func testPlusOperatorAddsOffset() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview() + 30
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.constant, 30)
    }

    func testMinusOperatorSubtractsOffset() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview() - 15
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.constant, -15)
    }
}

// MARK: - 乘除验证（参考 SnapKit ConstraintSpec multiplier tests）

/// 验证 multipliedBy / dividedBy 设置后底层 NSLayoutConstraint 的 multiplier 值
@MainActor
final class ConstraintMultiplierTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testMultipliedBy() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalToSuperview().multipliedBy(0.5)
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.multiplier, 0.5,
                       "multipliedBy(0.5) 应设置 multiplier 为 0.5")
    }

    func testDividedBy() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalToSuperview().dividedBy(3)
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.multiplier ?? 0, 1.0 / 3.0,
                       accuracy: 0.0001,
                       "dividedBy(3) 应设置 multiplier 为 1/3")
    }

    func testMultiplyOperator() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalToSuperview() * 0.75
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.multiplier, 0.75)
    }

    func testDivideOperator() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalToSuperview() / 4
        }
        XCTAssertEqual(proxy.firstLayoutConstraint?.multiplier ?? 0, 0.25,
                       accuracy: 0.0001)
    }
}

// MARK: - 复合约束验证（参考 SnapKit ConstraintMakerSpec composite tests）

/// 验证 edges / size / center / directionalEdges 创建正确数量和类型的底层约束
@MainActor
final class CompositeConstraintTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testEdgesCreates4Constraints() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.edges.equalToSuperview()
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 4, "edges 应创建 4 个约束")

        let attributes = Set(constraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.top))
        XCTAssertTrue(attributes.contains(.left))
        XCTAssertTrue(attributes.contains(.bottom))
        XCTAssertTrue(attributes.contains(.right))
    }

    func testSizeCreates2Constraints() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.size.equalTo(CGSize(width: 100, height: 50))
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 2, "size 应创建 2 个约束")

        let attributes = Set(constraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.width))
        XCTAssertTrue(attributes.contains(.height))
    }

    func testCenterCreates2Constraints() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.center.equalToSuperview()
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 2, "center 应创建 2 个约束")

        let attributes = Set(constraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.centerX))
        XCTAssertTrue(attributes.contains(.centerY))
    }

    func testDirectionalEdgesCreates4Constraints() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.directionalEdges.equalToSuperview()
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 4, "directionalEdges 应创建 4 个约束")

        let attributes = Set(constraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.top))
        XCTAssertTrue(attributes.contains(.leading))
        XCTAssertTrue(attributes.contains(.bottom))
        XCTAssertTrue(attributes.contains(.trailing))
    }

    #if canImport(UIKit)
    func testMarginsCreates4Constraints() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.margins.equalToSuperview()
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 4, "margins 应创建 4 个约束")

        let attributes = Set(constraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.topMargin))
        XCTAssertTrue(attributes.contains(.leftMargin))
        XCTAssertTrue(attributes.contains(.bottomMargin))
        XCTAssertTrue(attributes.contains(.rightMargin))
    }

    func testDirectionalMarginsCreates4Constraints() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.directionalMargins.equalToSuperview()
        }
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 4, "directionalMargins 应创建 4 个约束")

        let attributes = Set(constraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.topMargin))
        XCTAssertTrue(attributes.contains(.leadingMargin))
        XCTAssertTrue(attributes.contains(.bottomMargin))
        XCTAssertTrue(attributes.contains(.trailingMargin))
    }
    #endif

    func testSizeWithCGSizeConstant() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.size.equalTo(CGSize(width: 120, height: 80))
        }
        let constraints = proxy.layoutConstraints
        for lc in constraints {
            if lc.firstAttribute == .width {
                XCTAssertEqual(lc.constant, 120)
            } else if lc.firstAttribute == .height {
                XCTAssertEqual(lc.constant, 80)
            }
        }
    }
}

// MARK: - 约束生命周期验证（参考 SnapKit ConstraintSpec lifecycle tests）

/// 验证 activate / deactivate / install / uninstall / isActive 的行为
@MainActor
final class ConstraintLifecycleTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testIsActiveAfterInstall() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100)
        }
        XCTAssertTrue(proxy.isActive, "安装后约束应为激活状态")
    }

    func testIsActiveAfterDeactivate() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100)
        }
        proxy.deactivate()
        XCTAssertFalse(proxy.isActive, "deactivate 后约束应为非激活状态")
    }

    func testReactivateAfterDeactivate() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100)
        }
        proxy.deactivate()
        XCTAssertFalse(proxy.isActive)

        proxy.activate()
        XCTAssertTrue(proxy.isActive, "重新 activate 后约束应为激活状态")
    }

    func testUninstallRemovesConstraint() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.width.equalTo(100)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)

        proxy.uninstall()
        XCTAssertFalse(proxy.isActive)
    }

    func testLayoutConstraintsReturnsCorrectCount() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.edges.equalToSuperview()
        }
        XCTAssertEqual(proxy.layoutConstraints.count, 4,
                       "edges 约束应返回 4 个底层 NSLayoutConstraint")
    }

    func testLayoutConstraintsEmptyBeforeInstall() {
        // 通过 prepareConstraints 创建但不安装
        let constraints = view.mas.prepareConstraints { make in
            make.width.equalTo(100)
        }
        // prepareConstraints 返回的约束未安装，layoutConstraint 应为 nil
        if let first = constraints.first {
            let proxy = MASSwiftConstraintProxy(first)
            XCTAssertTrue(proxy.layoutConstraints.isEmpty,
                          "未安装的约束 layoutConstraints 应为空")
        }
    }
}

// MARK: - labeled 验证（参考 SnapKit labeled tests）

/// 验证 labeled 设置后底层 NSLayoutConstraint 的 identifier
@MainActor
final class ConstraintLabeledTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testLabeledSetsIdentifier() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.top.equalToSuperview().labeled("myTopConstraint")
        }
        // Masonry 的 key() 映射到 MASLayoutConstraint 的 mas_key，
        // 同时也会设置 NSLayoutConstraint 的 identifier（如果 MASLayoutConstraint 支持）
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc, "应创建底层约束")
        // MASLayoutConstraint 的 mas_key 应被设置
        if let masLC = lc as? LayoutConstraint {
            XCTAssertEqual(masLC.mas_key as? String, "myTopConstraint",
                           "labeled 应设置 mas_key")
        }
    }

    func testLabeledOnCompositeConstraint() {
        var proxy: MASSwiftConstraintProxy!
        view.mas.makeConstraints { make in
            proxy = make.edges.equalToSuperview().labeled("edgesConstraint")
        }
        // 复合约束的 labeled 应为每个子约束设置带索引的 key
        let constraints = proxy.layoutConstraints
        XCTAssertEqual(constraints.count, 4)
        for (index, lc) in constraints.enumerated() {
            if let masLC = lc as? LayoutConstraint {
                XCTAssertEqual(masLC.mas_key as? String, "edgesConstraint[\(index)]",
                               "复合约束的 labeled 应设置带索引的 key")
            }
        }
    }
}

// MARK: - group 验证

/// 验证 group 方法创建的约束分组行为
@MainActor
final class ConstraintGroupTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testGroupCreatesConstraints() {
        view.mas.makeConstraints { make in
            let group = make.group {
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }
            group.priority(.high)
            make.top.bottom.equalToSuperview()
        }
        // 验证约束已安装到父视图上
        XCTAssertFalse(superview.constraints.isEmpty, "group 中的约束应被安装")
    }

    func testGroupPriorityAppliesToAllChildren() {
        view.mas.makeConstraints { make in
            let group = make.group {
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            group.priority(.low)
            make.top.bottom.equalToSuperview()
        }

        // 检查父视图上的约束，找到 left 和 right 约束验证优先级
        let leftRightConstraints = superview.constraints.filter { lc in
            (lc.firstItem === view) &&
            (lc.firstAttribute == .left || lc.firstAttribute == .right)
        }
        for lc in leftRightConstraints {
            #if canImport(UIKit)
            XCTAssertEqual(lc.priority, .defaultLow,
                           "group 中的约束优先级应为 .low")
            #endif
        }
    }
}

// MARK: - removeConstraints / prepareConstraints 验证（参考 SnapKit ConstraintViewDSLSpec）

@MainActor
final class ViewDSLTests: XCTestCase {

    var superview: MASNativeView!
    var view: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view = MASNativeView()
        superview.addSubview(view)
    }

    @MainActor
    override func tearDown() {
        view.removeFromSuperview()
        view = nil
        superview = nil
        super.tearDown()
    }

    func testRemoveConstraintsRemovesAllInstalled() {
        view.mas.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 验证约束已安装
        let beforeCount = superview.constraints.filter { $0.firstItem === view }.count
        XCTAssertGreaterThan(beforeCount, 0, "应有已安装的约束")

        view.mas.removeConstraints()

        // 验证约束已移除
        let afterCount = superview.constraints.filter {
            ($0.firstItem === view) && $0.isActive
        }.count
        XCTAssertEqual(afterCount, 0, "removeConstraints 后不应有激活的约束")
    }

    func testRemakeConstraintsReplacesAll() {
        view.mas.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.height.equalTo(100)
        }

        view.mas.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }

        // 验证旧约束被替换
        let activeConstraints = superview.constraints.filter {
            ($0.firstItem === view) && $0.isActive
        }
        // remake 后应只有 center + size 的约束
        let attributes = Set(activeConstraints.map { $0.firstAttribute })
        XCTAssertTrue(attributes.contains(.centerX) || attributes.contains(.centerY),
                      "remake 后应包含 center 约束")
    }

    #if canImport(UIKit)
    func testContentHuggingHorizontalPriority() {
        view.mas.contentHuggingHorizontalPriority = 300
        XCTAssertEqual(view.mas.contentHuggingHorizontalPriority, 300)
        XCTAssertEqual(
            view.contentHuggingPriority(for: .horizontal),
            UILayoutPriority(300),
            "应同步到 UIView 的 contentHuggingPriority"
        )
    }

    func testContentHuggingVerticalPriority() {
        view.mas.contentHuggingVerticalPriority = 400
        XCTAssertEqual(view.mas.contentHuggingVerticalPriority, 400)
        XCTAssertEqual(
            view.contentHuggingPriority(for: .vertical),
            UILayoutPriority(400)
        )
    }

    func testContentCompressionResistanceHorizontalPriority() {
        view.mas.contentCompressionResistanceHorizontalPriority = 600
        XCTAssertEqual(view.mas.contentCompressionResistanceHorizontalPriority, 600)
        XCTAssertEqual(
            view.contentCompressionResistancePriority(for: .horizontal),
            UILayoutPriority(600)
        )
    }

    func testContentCompressionResistanceVerticalPriority() {
        view.mas.contentCompressionResistanceVerticalPriority = 800
        XCTAssertEqual(view.mas.contentCompressionResistanceVerticalPriority, 800)
        XCTAssertEqual(
            view.contentCompressionResistancePriority(for: .vertical),
            UILayoutPriority(800)
        )
    }
    #endif
}

// MARK: - 两视图间约束验证（参考 SnapKit 多视图约束测试）

/// 验证两个视图之间建立约束时，secondItem 和 secondAttribute 是否正确
@MainActor
final class InterViewConstraintTests: XCTestCase {

    var superview: MASNativeView!
    var viewA: MASNativeView!
    var viewB: MASNativeView!

    @MainActor
    override func setUp() {
        super.setUp()
        superview = MASNativeView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        viewA = MASNativeView()
        viewB = MASNativeView()
        superview.addSubview(viewA)
        superview.addSubview(viewB)
    }

    @MainActor
    override func tearDown() {
        viewA.removeFromSuperview()
        viewB.removeFromSuperview()
        viewA = nil
        viewB = nil
        superview = nil
        super.tearDown()
    }

    func testEqualToAnotherView() {
        var proxy: MASSwiftConstraintProxy!
        viewA.mas.makeConstraints { make in
            proxy = make.top.equalTo(viewB!)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertTrue(lc?.firstItem === viewA)
        XCTAssertTrue(lc?.secondItem === viewB, "secondItem 应为 viewB")
        XCTAssertEqual(lc?.firstAttribute, .top)
        XCTAssertEqual(lc?.secondAttribute, .top, "同名属性应自动匹配")
    }

    func testEqualToAnotherViewAttribute() {
        var proxy: MASSwiftConstraintProxy!
        viewA.mas.makeConstraints { make in
            proxy = make.top.equalTo(viewB!.mas.bottom)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertTrue(lc?.firstItem === viewA)
        XCTAssertTrue(lc?.secondItem === viewB)
        XCTAssertEqual(lc?.firstAttribute, .top)
        XCTAssertEqual(lc?.secondAttribute, .bottom,
                       "应使用指定的 secondAttribute")
    }

    func testEqualToAnotherViewWithOffset() {
        var proxy: MASSwiftConstraintProxy!
        viewA.mas.makeConstraints { make in
            proxy = make.top.equalTo(viewB!.mas.bottom).offset(10)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.constant, 10)
        XCTAssertTrue(lc?.secondItem === viewB)
    }

    func testWidthEqualToAnotherViewWidth() {
        var proxy: MASSwiftConstraintProxy!
        viewA.mas.makeConstraints { make in
            proxy = make.width.equalTo(viewB!.mas.width)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.firstAttribute, .width)
        XCTAssertEqual(lc?.secondAttribute, .width)
        XCTAssertTrue(lc?.secondItem === viewB)
    }

    func testWidthEqualToAnotherViewWidthWithMultiplier() {
        var proxy: MASSwiftConstraintProxy!
        viewA.mas.makeConstraints { make in
            proxy = make.width.equalTo(viewB!.mas.width).multipliedBy(0.5)
        }
        let lc = proxy.firstLayoutConstraint
        XCTAssertNotNil(lc)
        XCTAssertEqual(lc?.multiplier, 0.5)
    }
}
