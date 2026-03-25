//
//  MASExampleSwiftBasicView.swift
//  Masonry iOS Examples
//
//  MasonrySwift 基础布局示例 — 与 ObjC 版 MASExampleBasicView 形成对比
//
//  注：此文件需手动拖入 Xcode 工程中编译。首次添加 Swift 文件时，
//  Xcode 会提示创建 Bridging Header，接受即可。在 Bridging Header 中添加：
//    #import "Masonry.h"
//

import UIKit
import Masonry
import MasonrySwift

/// Swift 版基础布局示例
///
/// 使用 `@objc(MASExampleSwiftBasicView)` 确保 ObjC 端可通过 Class 动态加载。
@objc(MASExampleSwiftBasicView)
final class MASExampleSwiftBasicView: UIView {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let greenView = UIView()
        greenView.backgroundColor = .green
        greenView.layer.borderColor = UIColor.black.cgColor
        greenView.layer.borderWidth = 2
        addSubview(greenView)

        let redView = UIView()
        redView.backgroundColor = .red
        redView.layer.borderColor = UIColor.black.cgColor
        redView.layer.borderWidth = 2
        addSubview(redView)

        let blueView = UIView()
        blueView.backgroundColor = .blue
        blueView.layer.borderColor = UIColor.black.cgColor
        blueView.layer.borderWidth = 2
        addSubview(blueView)

        let padding: CGFloat = 10

        // ── 方式一：链式方法调用 ──
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
            // 高度通过数组约束（使用 ObjC API 桥接）
            make.height.equalTo(greenView)
        }

        blueView.mas.makeConstraints { make in
            make.top == greenView.mas.bottom + padding
            make.left == self.mas.left + padding
            make.bottom == self.mas.bottom - padding
            make.right == self.mas.right - padding
            make.height.equalTo(greenView)
        }
    }
}
