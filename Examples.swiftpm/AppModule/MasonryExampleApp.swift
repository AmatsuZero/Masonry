//
//  MasonryExampleApp.swift
//  Masonry iOS Example — SwiftUI App 入口
//
//  使用 SwiftUI 构建示例列表，通过 UIViewRepresentable / UIViewControllerRepresentable
//  桥接 ObjC 示例 View 和 ViewController。
//

import SwiftUI
import MasonryObjCExamples
import MasonrySwiftExample

// MARK: - App 入口

@main
struct MasonryExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ExampleListView()
                    .navigationTitle("Masonry Examples")
            }
            .navigationViewStyle(.stack)
        }
    }
}

// MARK: - 示例数据模型

/// 示例条目：标题 + 创建对应 UIView/UIViewController 的闭包
struct ExampleItem: Identifiable {
    let id = UUID()
    let title: String
    /// 返回一个 UIViewController 来展示示例
    let makeViewController: () -> UIViewController
}

// MARK: - 示例列表

struct ExampleListView: View {

    // MARK: ObjC (Masonry) 示例

    let objcExamples: [ExampleItem] = [
        ExampleItem(title: "Basic") {
            MASExampleViewController(title: "Basic", viewClass: MASExampleBasicView.self)
        },
        ExampleItem(title: "Update Constraints") {
            MASExampleViewController(title: "Update Constraints", viewClass: MASExampleUpdateView.self)
        },
        ExampleItem(title: "Remake Constraints") {
            MASExampleViewController(title: "Remake Constraints", viewClass: MASExampleRemakeView.self)
        },
        ExampleItem(title: "Using Constants") {
            MASExampleViewController(title: "Using Constants", viewClass: MASExampleConstantsView.self)
        },
        ExampleItem(title: "Composite Edges") {
            MASExampleViewController(title: "Composite Edges", viewClass: MASExampleSidesView.self)
        },
        ExampleItem(title: "Aspect Fit") {
            MASExampleViewController(title: "Aspect Fit", viewClass: MASExampleAspectFitView.self)
        },
        ExampleItem(title: "Basic Animated") {
            MASExampleViewController(title: "Basic Animated", viewClass: MASExampleAnimatedView.self)
        },
        ExampleItem(title: "Debugging Helpers") {
            MASExampleViewController(title: "Debugging Helpers", viewClass: MASExampleDebuggingView.self)
        },
        ExampleItem(title: "Bacony Labels") {
            MASExampleViewController(title: "Bacony Labels", viewClass: MASExampleLabelView.self)
        },
        ExampleItem(title: "UIScrollView") {
            MASExampleViewController(title: "UIScrollView", viewClass: MASExampleScrollView.self)
        },
        ExampleItem(title: "Array") {
            MASExampleViewController(title: "Array", viewClass: MASExampleArrayView.self)
        },
        ExampleItem(title: "Attribute Chaining") {
            MASExampleViewController(title: "Attribute Chaining", viewClass: MASExampleAttributeChainingView.self)
        },
        ExampleItem(title: "Margins") {
            MASExampleViewController(title: "Margins", viewClass: MASExampleMarginView.self)
        },
        ExampleItem(title: "Views Distribute") {
            MASExampleViewController(title: "Views Distribute", viewClass: MASExampleDistributeView.self)
        },
        ExampleItem(title: "Layout Guides") {
            MASExampleLayoutGuideViewController()
        },
        ExampleItem(title: "Safe Area Layout Guides") {
            MASExampleSafeAreaLayoutGuideViewController()
        },
    ]

    // MARK: Swift (MasonrySwift) 示例

    let swiftExamples: [ExampleItem] = [
        ExampleItem(title: "Basic") {
            SwiftExampleViewController(title: "Basic", viewClass: BasicExampleView.self)
        },
        ExampleItem(title: "Operators & Priority") {
            SwiftExampleViewController(title: "Operators & Priority", viewClass: OperatorExampleView.self)
        },
        ExampleItem(title: "Composite (edges/size/center)") {
            SwiftExampleViewController(title: "Composite", viewClass: CompositeExampleView.self)
        },
        ExampleItem(title: "Update / Remake") {
            SwiftExampleViewController(title: "Update / Remake", viewClass: UpdateExampleView.self)
        },
        ExampleItem(title: "Distribute Views") {
            SwiftExampleViewController(title: "Distribute Views", viewClass: DistributeExampleView.self)
        },
        ExampleItem(title: "Debug Keys") {
            SwiftExampleViewController(title: "Debug Keys", viewClass: DebugKeyExampleView.self)
        },
        ExampleItem(title: "Compound Assignment (+=/-=)") {
            SwiftExampleViewController(title: "Compound Assignment", viewClass: CompoundAssignmentExampleView.self)
        },
        ExampleItem(title: "SnapKit-Aligned API") {
            SwiftExampleViewController(title: "SnapKit-Aligned API", viewClass: SnapKitAlignedExampleView.self)
        },
        ExampleItem(title: "UIScrollView") {
            SwiftExampleViewController(title: "UIScrollView", viewClass: ScrollViewExampleView.self)
        },
        ExampleItem(title: "Animated Constraints") {
            SwiftExampleViewController(title: "Animated Constraints", viewClass: AnimatedExampleView.self)
        },
        ExampleItem(title: "Label Layout (Hugging / Compression)") {
            SwiftExampleViewController(title: "Label Layout", viewClass: LabelLayoutExampleView.self)
        },
        ExampleItem(title: "Aspect Ratio") {
            SwiftExampleViewController(title: "Aspect Ratio", viewClass: AspectRatioExampleView.self)
        },
    ]

    // MARK: Body

    var body: some View {
        List {
            Section("Objective-C — Masonry") {
                ForEach(objcExamples) { example in
                    NavigationLink(example.title) {
                        UIViewControllerWrapper(makeViewController: example.makeViewController)
                            .navigationTitle(example.title)
                            .navigationBarTitleDisplayMode(.inline)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }

            Section("Swift — MasonrySwift") {
                ForEach(swiftExamples) { example in
                    NavigationLink(example.title) {
                        UIViewControllerWrapper(makeViewController: example.makeViewController)
                            .navigationTitle(example.title)
                            .navigationBarTitleDisplayMode(.inline)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
        }
    }
}

// MARK: - UIViewController 桥接

/// 将 UIViewController 包装为 SwiftUI View
struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let makeViewController: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        makeViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Swift 示例 ViewController

/// 通用的 Swift 示例视图控制器，用于展示 MasonrySwift 示例 View
final class SwiftExampleViewController: UIViewController {

    private let exampleTitle: String
    private let viewClass: UIView.Type

    init(title: String, viewClass: UIView.Type) {
        self.exampleTitle = title
        self.viewClass = viewClass
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func loadView() {
        let exampleView = viewClass.init(frame: .zero)
        exampleView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.view = exampleView
    }
}
