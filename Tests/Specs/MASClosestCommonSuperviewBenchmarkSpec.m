//
//  MASClosestCommonSuperviewBenchmarkSpec.m
//  Masonry
//
//  mas_closestCommonSuperview: 性能优化基准测试
//  Ref: https://github.com/SnapKit/Masonry/issues/578
//
//  测试三种算法：
//  1. Original: O(n²) 嵌套循环
//  2. Two-pointer: O(n)，灵感来自链表交叉点查找
//  3. Fast-path + two-pointer: O(1) 常见场景 + O(n) 回退
//
//  使用苹果官方推荐的 XCTest 性能测试 API：
//  - measureMetrics:automaticallyStartMeasuring:forBlock: 精确控制测量范围
//  - startMeasuring / stopMeasuring 排除 setup 开销
//  - XCTPerformanceMetricWallClockTime 墙钟时间指标
//  Ref: https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests
//

#import "XCTest+Spec.h"
#import "MASUtilities.h"
#import "View+MASAdditions.h"

// ─────────────────────────────────────────────────────────────────
// 本地算法实现（用于对比，不修改源码）
// ─────────────────────────────────────────────────────────────────

/// 算法 1: 原始 O(n²) 嵌套循环（当前实现）
static MAS_VIEW *algo_original(MAS_VIEW *self, MAS_VIEW *view) {
    MAS_VIEW *closestCommonSuperview = nil;
    MAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        MAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

/// 算法 2: 双指针 O(n) — 链表交叉点技巧
/// 当指针到达 nil 时，从另一个视图的起始节点重新开始。
/// 两个指针各遍历 (depth_A + depth_B) 步后在 LCA 处相遇。
/// 若无公共祖先，两者同时到达 nil。
static MAS_VIEW *algo_twoPointer(MAS_VIEW *viewA, MAS_VIEW *viewB) {
    MAS_VIEW *a = viewA;
    MAS_VIEW *b = viewB;
    while (a != b) {
        a = (a == nil) ? viewB : a.superview;
        b = (b == nil) ? viewA : b.superview;
    }
    return a;
}

/// 算法 3: 快速路径 O(1)（兄弟/父子）+ O(n) 双指针回退
/// 实际场景中大多数约束发生在兄弟或父子视图之间，
/// 因此快速路径覆盖了绝大多数真实调用。
static MAS_VIEW *algo_fastPath(MAS_VIEW *viewA, MAS_VIEW *viewB) {
    // 退化情况：同一视图（如 make.width.equalTo(view.mas_width)）
    if (viewA == viewB) return viewA;
    // 快速路径：共享直接父视图的兄弟节点（UI 布局中最常见）
    if (viewA.superview && viewA.superview == viewB.superview) {
        return viewA.superview;
    }
    // 快速路径：直接父子关系
    if (viewA.superview == viewB) return viewB;
    if (viewB.superview == viewA) return viewA;
    
    // 回退：双指针 O(n)
    MAS_VIEW *a = viewA;
    MAS_VIEW *b = viewB;
    while (a != b) {
        a = (a == nil) ? viewB : a.superview;
        b = (b == nil) ? viewA : b.superview;
    }
    return a;
}

// ─────────────────────────────────────────────────────────────────
// 辅助方法
// ─────────────────────────────────────────────────────────────────

/// 构建一条深度为 `depth` 的线性视图链。
/// 返回叶子节点（最深的视图）；根节点在链的顶部。
static MAS_VIEW *buildChain(NSUInteger depth) {
    MAS_VIEW *root = [MAS_VIEW new];
    MAS_VIEW *current = root;
    for (NSUInteger i = 0; i < depth - 1; i++) {
        MAS_VIEW *child = [MAS_VIEW new];
        [current addSubview:child];
        current = child;
    }
    return current;
}

/// 构建一棵树：root 有 `totalDepth` 层祖先链，
/// 两个兄弟节点挂在给定深度的公共祖先上。
/// 返回 { @"viewA": ..., @"viewB": ..., @"lca": ... }
static NSDictionary *buildSiblingTree(NSUInteger totalDepth) {
    MAS_VIEW *leaf = buildChain(totalDepth);
    NSUInteger branchDepth = totalDepth / 2;
    MAS_VIEW *commonParent = leaf;
    for (NSUInteger i = 0; i < branchDepth; i++) {
        if (!commonParent.superview) break;
        commonParent = commonParent.superview;
    }
    
    MAS_VIEW *viewA = [MAS_VIEW new];
    MAS_VIEW *viewB = [MAS_VIEW new];
    [commonParent addSubview:viewA];
    [commonParent addSubview:viewB];
    
    return @{ @"viewA": viewA, @"viewB": viewB, @"lca": commonParent };
}

/// 默认性能指标列表（墙钟时间）
static NSArray<XCTPerformanceMetric> *defaultPerformanceMetrics(void) {
    return @[XCTPerformanceMetric_WallClockTime];
}

// ─────────────────────────────────────────────────────────────────
// 测试套件
// ─────────────────────────────────────────────────────────────────

SpecBegin(MASClosestCommonSuperviewBenchmark)

#pragma mark - 正确性验证

- (void)testAllAlgorithmsSameView {
    // make.width.equalTo(view.mas_width) 触发 self == view
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *view   = [MAS_VIEW new];
    [parent addSubview:view];
    
    MAS_VIEW *r1 = algo_original(view, view);
    MAS_VIEW *r2 = algo_twoPointer(view, view);
    MAS_VIEW *r3 = algo_fastPath(view, view);
    
    // 视图与自身的 LCA 应该是自身，而非其父视图
    XCTAssertEqual(r1, view,   @"original: 同一视图应返回自身");
    XCTAssertEqual(r2, view,   @"twoPointer: 同一视图应返回自身");
    XCTAssertEqual(r3, view,   @"fastPath: 同一视图应返回自身");
}

- (void)testAllAlgorithmsAgreeSiblings {
    // 共享公共父视图的兄弟节点
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *viewA  = [MAS_VIEW new];
    MAS_VIEW *viewB  = [MAS_VIEW new];
    [parent addSubview:viewA];
    [parent addSubview:viewB];
    
    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);
    
    XCTAssertEqual(r1, parent, @"original: 兄弟节点应返回父视图");
    XCTAssertEqual(r2, parent, @"twoPointer: 兄弟节点应返回父视图");
    XCTAssertEqual(r3, parent, @"fastPath: 兄弟节点应返回父视图");
}

- (void)testAllAlgorithmsAgreeParentChild {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *child  = [MAS_VIEW new];
    [parent addSubview:child];
    
    MAS_VIEW *r1 = algo_original(child, parent);
    MAS_VIEW *r2 = algo_twoPointer(child, parent);
    MAS_VIEW *r3 = algo_fastPath(child, parent);
    
    XCTAssertEqual(r1, parent, @"original: 父子关系应返回父视图");
    XCTAssertEqual(r2, parent, @"twoPointer: 父子关系应返回父视图");
    XCTAssertEqual(r3, parent, @"fastPath: 父子关系应返回父视图");
}

- (void)testAllAlgorithmsAgreeDeepHierarchy {
    // 深层层级：root -> ... 50 层 ... -> commonParent -> branchA/branchB
    NSDictionary *tree = buildSiblingTree(50);
    MAS_VIEW *viewA = tree[@"viewA"];
    MAS_VIEW *viewB = tree[@"viewB"];
    MAS_VIEW *expectedLCA = tree[@"lca"];
    
    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);
    
    XCTAssertEqual(r1, expectedLCA, @"original: 深层层级 LCA 不匹配");
    XCTAssertEqual(r2, expectedLCA, @"twoPointer: 深层层级 LCA 不匹配");
    XCTAssertEqual(r3, expectedLCA, @"fastPath: 深层层级 LCA 不匹配");
}

- (void)testAllAlgorithmsAgreeAsymmetricDepths {
    // viewA 在层级中比 viewB 更深
    MAS_VIEW *root = [MAS_VIEW new];
    MAS_VIEW *mid  = [MAS_VIEW new];
    MAS_VIEW *viewA = [MAS_VIEW new]; // 距 root 3 层
    [root addSubview:mid];
    [mid addSubview:viewA];
    MAS_VIEW *viewB = [MAS_VIEW new]; // 距 root 1 层
    [root addSubview:viewB];
    
    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);
    
    XCTAssertEqual(r1, root, @"original: 不对称深度 LCA 应为 root");
    XCTAssertEqual(r2, root, @"twoPointer: 不对称深度 LCA 应为 root");
    XCTAssertEqual(r3, root, @"fastPath: 不对称深度 LCA 应为 root");
}

- (void)testAllAlgorithmsNoCommonAncestor {
    MAS_VIEW *viewA = [MAS_VIEW new];
    MAS_VIEW *viewB = [MAS_VIEW new];
    
    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);
    
    XCTAssertNil(r1, @"original: 无公共祖先应返回 nil");
    XCTAssertNil(r2, @"twoPointer: 无公共祖先应返回 nil");
    XCTAssertNil(r3, @"fastPath: 无公共祖先应返回 nil");
}

#pragma mark - 基准测试：最坏情况（深层层级，兄弟节点在底部附近）

/// 最坏情况说明：
/// 两个视图都是深层兄弟节点，公共父视图靠近根节点。
/// 原始 O(n²) 算法需要为每个候选节点扫描多层。
///
/// 使用 measureMetrics:automaticallyStartMeasuring:forBlock: 精确控制测量范围，
/// 通过 startMeasuring/stopMeasuring 排除视图层级构建的开销，
/// 确保只测量算法本身的性能。

- (void)testBenchmark_WorstCase_Original {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        // setup: 构建视图层级（不计入测量）
        const NSUInteger kDepth = 200;
        NSDictionary *tree = buildSiblingTree(kDepth);
        MAS_VIEW *viewA = tree[@"viewA"];
        MAS_VIEW *viewB = tree[@"viewB"];
        
        [self startMeasuring];
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = algo_original(viewA, viewB);
        }
        [self stopMeasuring];
    }];
}

- (void)testBenchmark_WorstCase_TwoPointer {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        const NSUInteger kDepth = 200;
        NSDictionary *tree = buildSiblingTree(kDepth);
        MAS_VIEW *viewA = tree[@"viewA"];
        MAS_VIEW *viewB = tree[@"viewB"];
        
        [self startMeasuring];
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = algo_twoPointer(viewA, viewB);
        }
        [self stopMeasuring];
    }];
}

- (void)testBenchmark_WorstCase_FastPath {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        const NSUInteger kDepth = 200;
        NSDictionary *tree = buildSiblingTree(kDepth);
        MAS_VIEW *viewA = tree[@"viewA"];
        MAS_VIEW *viewB = tree[@"viewB"];
        
        [self startMeasuring];
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = algo_fastPath(viewA, viewB);
        }
        [self stopMeasuring];
    }];
}

#pragma mark - 基准测试：典型情况（共享直接父视图的兄弟节点）

/// 代表最常见的真实场景：
/// 同一父视图下的两个兄弟视图（如 cell 中的 label）。

- (void)testBenchmark_TypicalCase_Siblings_Original {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        MAS_VIEW *parent = [MAS_VIEW new];
        MAS_VIEW *viewA  = [MAS_VIEW new];
        MAS_VIEW *viewB  = [MAS_VIEW new];
        [parent addSubview:viewA];
        [parent addSubview:viewB];
        
        [self startMeasuring];
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_original(viewA, viewB);
        }
        [self stopMeasuring];
    }];
}

- (void)testBenchmark_TypicalCase_Siblings_TwoPointer {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        MAS_VIEW *parent = [MAS_VIEW new];
        MAS_VIEW *viewA  = [MAS_VIEW new];
        MAS_VIEW *viewB  = [MAS_VIEW new];
        [parent addSubview:viewA];
        [parent addSubview:viewB];
        
        [self startMeasuring];
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_twoPointer(viewA, viewB);
        }
        [self stopMeasuring];
    }];
}

- (void)testBenchmark_TypicalCase_Siblings_FastPath {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        MAS_VIEW *parent = [MAS_VIEW new];
        MAS_VIEW *viewA  = [MAS_VIEW new];
        MAS_VIEW *viewB  = [MAS_VIEW new];
        [parent addSubview:viewA];
        [parent addSubview:viewB];
        
        [self startMeasuring];
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_fastPath(viewA, viewB);
        }
        [self stopMeasuring];
    }];
}

#pragma mark - 基准测试：典型情况（父子关系）

- (void)testBenchmark_TypicalCase_ParentChild_Original {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        MAS_VIEW *parent = [MAS_VIEW new];
        MAS_VIEW *child  = [MAS_VIEW new];
        [parent addSubview:child];
        
        [self startMeasuring];
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_original(child, parent);
        }
        [self stopMeasuring];
    }];
}

- (void)testBenchmark_TypicalCase_ParentChild_TwoPointer {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        MAS_VIEW *parent = [MAS_VIEW new];
        MAS_VIEW *child  = [MAS_VIEW new];
        [parent addSubview:child];
        
        [self startMeasuring];
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_twoPointer(child, parent);
        }
        [self stopMeasuring];
    }];
}

- (void)testBenchmark_TypicalCase_ParentChild_FastPath {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        MAS_VIEW *parent = [MAS_VIEW new];
        MAS_VIEW *child  = [MAS_VIEW new];
        [parent addSubview:child];
        
        [self startMeasuring];
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_fastPath(child, parent);
        }
        [self stopMeasuring];
    }];
}

#pragma mark - 基准测试：当前 mas_closestCommonSuperview: 实际实现

- (void)testBenchmark_ActualImplementation_WorstCase {
    [self measureMetrics:defaultPerformanceMetrics()
automaticallyStartMeasuring:NO
                forBlock:^{
        const NSUInteger kDepth = 200;
        NSDictionary *tree = buildSiblingTree(kDepth);
        MAS_VIEW *viewA = tree[@"viewA"];
        MAS_VIEW *viewB = tree[@"viewB"];
        
        [self startMeasuring];
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = [viewA mas_closestCommonSuperview:viewB];
        }
        [self stopMeasuring];
    }];
}

SpecEnd
