//
//  MasonryExampleApp.swift
//  Masonry iOS Example — SwiftUI App 入口
//
//  使用 SwiftUI 构建示例列表，通过 UIViewRepresentable / UIViewControllerRepresentable
//  桥接 ObjC 示例 View 和 ViewController。
//

import SwiftUI
import MasonryObjCExamples

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

    let examples: [ExampleItem] = {
        var items: [ExampleItem] = [
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
        ]

        // Layout Guide 示例（UIViewController 类型）
        items.append(ExampleItem(title: "Layout Guides") {
            MASExampleLayoutGuideViewController()
        })

        // Safe Area Layout Guide 示例
        items.append(ExampleItem(title: "Safe Area Layout Guides") {
            MASExampleSafeAreaLayoutGuideViewController()
        })

        return items
    }()

    var body: some View {
        List(examples) { example in
            NavigationLink(example.title) {
                UIViewControllerWrapper(makeViewController: example.makeViewController)
                    .navigationTitle(example.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .edgesIgnoringSafeArea(.bottom)
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
