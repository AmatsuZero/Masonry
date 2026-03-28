//
//  MASClosestCommonSuperviewBenchmarkSpec.m
//  Masonry
//
//  Benchmark for mas_closestCommonSuperview: performance optimization
//  Ref: https://github.com/SnapKit/Masonry/issues/578
//
//  Tests three algorithms:
//  1. Original: O(n²) nested loop
//  2. Two-pointer: O(n), inspired by linked list intersection
//  3. Fast-path + two-pointer: O(1) for common cases, O(n) fallback
//

#import "XCTest+Spec.h"
#import "MASUtilities.h"
#import "View+MASAdditions.h"

// ─────────────────────────────────────────────────────────────────
// Local re-implementations for comparison (do not touch source yet)
// ─────────────────────────────────────────────────────────────────

/// Algorithm 1: Original O(n²) nested loop (current implementation)
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

/// Algorithm 2: Two-pointer O(n) — linked-list intersection trick
/// When a pointer hits nil it restarts at the other view's starting node.
/// Both pointers traverse exactly (depth_A + depth_B) steps and meet at LCA.
/// If no common ancestor, both end up at nil simultaneously.
static MAS_VIEW *algo_twoPointer(MAS_VIEW *viewA, MAS_VIEW *viewB) {
    MAS_VIEW *a = viewA;
    MAS_VIEW *b = viewB;
    while (a != b) {
        a = (a == nil) ? viewB : a.superview;
        b = (b == nil) ? viewA : b.superview;
    }
    return a; // nil if no common ancestor, LCA otherwise
}

/// Algorithm 3: Fast-path O(1) for siblings/parent-child + O(n) two-pointer fallback
/// In practice most constraints are between siblings or parent-child pairs,
/// so the fast path covers the vast majority of real-world calls.
static MAS_VIEW *algo_fastPath(MAS_VIEW *viewA, MAS_VIEW *viewB) {
    // Degenerate case: same view (e.g. make.width.equalTo(view.mas_width))
    if (viewA == viewB) return viewA;
    // Fast path: siblings sharing a direct parent (most common in UI layout)
    if (viewA.superview && viewA.superview == viewB.superview) {
        return viewA.superview;
    }
    // Fast path: direct parent-child relationship
    if (viewA.superview == viewB) return viewB;
    if (viewB.superview == viewA) return viewA;

    // Fallback: two-pointer O(n)
    MAS_VIEW *a = viewA;
    MAS_VIEW *b = viewB;
    while (a != b) {
        a = (a == nil) ? viewB : a.superview;
        b = (b == nil) ? viewA : b.superview;
    }
    return a;
}

// ─────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────

/// Build a linear chain of `depth` views.
/// Returns the leaf (deepest) view; root is at the top of the chain.
static MAS_VIEW *buildChain(NSUInteger depth) {
    MAS_VIEW *root = [MAS_VIEW new];
    MAS_VIEW *current = root;
    for (NSUInteger i = 0; i < depth - 1; i++) {
        MAS_VIEW *child = [MAS_VIEW new];
        [current addSubview:child];
        current = child;
    }
    return current; // leaf
}

/// Build a tree where root has a chain of `depth` ancestors,
/// and two siblings hang off a common ancestor at the given depth.
/// Returns { @"viewA": ..., @"viewB": ..., @"lca": ... }
static NSDictionary *buildSiblingTree(NSUInteger totalDepth) {
    // root -> ... -> commonParent -> (branchA, branchB)
    MAS_VIEW *leaf = buildChain(totalDepth);
    // Walk up to find the commonParent (depth/2 from the bottom)
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

// ─────────────────────────────────────────────────────────────────
// Test suite
// ─────────────────────────────────────────────────────────────────

SpecBegin(MASClosestCommonSuperviewBenchmark)

#pragma mark - Correctness

- (void)testAllAlgorithmsSameView {
    // make.width.equalTo(view.mas_width) triggers self == view
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *view   = [MAS_VIEW new];
    [parent addSubview:view];

    MAS_VIEW *r1 = algo_original(view, view);
    MAS_VIEW *r2 = algo_twoPointer(view, view);
    MAS_VIEW *r3 = algo_fastPath(view, view);

    // LCA of a view with itself is the view itself, not its superview
    XCTAssertEqual(r1, view,   @"original: same view should return self");
    XCTAssertEqual(r2, view,   @"twoPointer: same view should return self");
    XCTAssertEqual(r3, view,   @"fastPath: same view should return self");
}

- (void)testAllAlgorithmsAgreeSiblings {
    // siblings sharing a common parent
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *viewA  = [MAS_VIEW new];
    MAS_VIEW *viewB  = [MAS_VIEW new];
    [parent addSubview:viewA];
    [parent addSubview:viewB];

    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);

    XCTAssertEqual(r1, parent, @"original: siblings should return parent");
    XCTAssertEqual(r2, parent, @"twoPointer: siblings should return parent");
    XCTAssertEqual(r3, parent, @"fastPath: siblings should return parent");
}

- (void)testAllAlgorithmsAgreeParentChild {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *child  = [MAS_VIEW new];
    [parent addSubview:child];

    MAS_VIEW *r1 = algo_original(child, parent);
    MAS_VIEW *r2 = algo_twoPointer(child, parent);
    MAS_VIEW *r3 = algo_fastPath(child, parent);

    XCTAssertEqual(r1, parent, @"original: parent-child should return parent");
    XCTAssertEqual(r2, parent, @"twoPointer: parent-child should return parent");
    XCTAssertEqual(r3, parent, @"fastPath: parent-child should return parent");
}

- (void)testAllAlgorithmsAgreeDeepHierarchy {
    // Deep hierarchy: root -> ... 50 levels ... -> commonParent -> branchA/branchB
    NSDictionary *tree = buildSiblingTree(50);
    MAS_VIEW *viewA = tree[@"viewA"];
    MAS_VIEW *viewB = tree[@"viewB"];
    MAS_VIEW *expectedLCA = tree[@"lca"];

    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);

    XCTAssertEqual(r1, expectedLCA, @"original: deep hierarchy LCA mismatch");
    XCTAssertEqual(r2, expectedLCA, @"twoPointer: deep hierarchy LCA mismatch");
    XCTAssertEqual(r3, expectedLCA, @"fastPath: deep hierarchy LCA mismatch");
}

- (void)testAllAlgorithmsAgreeAsymmetricDepths {
    // viewA is deeper than viewB in the hierarchy
    MAS_VIEW *root = [MAS_VIEW new];
    MAS_VIEW *mid  = [MAS_VIEW new];
    MAS_VIEW *viewA = [MAS_VIEW new]; // 3 levels from root
    [root addSubview:mid];
    [mid addSubview:viewA];
    MAS_VIEW *viewB = [MAS_VIEW new]; // 1 level from root
    [root addSubview:viewB];

    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);

    XCTAssertEqual(r1, root, @"original: asymmetric depths LCA should be root");
    XCTAssertEqual(r2, root, @"twoPointer: asymmetric depths LCA should be root");
    XCTAssertEqual(r3, root, @"fastPath: asymmetric depths LCA should be root");
}

- (void)testAllAlgorithmsNoCommonAncestor {
    MAS_VIEW *viewA = [MAS_VIEW new];
    MAS_VIEW *viewB = [MAS_VIEW new];

    MAS_VIEW *r1 = algo_original(viewA, viewB);
    MAS_VIEW *r2 = algo_twoPointer(viewA, viewB);
    MAS_VIEW *r3 = algo_fastPath(viewA, viewB);

    XCTAssertNil(r1, @"original: no common ancestor should return nil");
    XCTAssertNil(r2, @"twoPointer: no common ancestor should return nil");
    XCTAssertNil(r3, @"fastPath: no common ancestor should return nil");
}

#pragma mark - Benchmark: Worst Case (deep hierarchy, siblings at very bottom)

/// Builds the worst case for the original algorithm:
/// Both views are deep siblings where the common parent is near the root.
/// The original O(n²) must scan many levels for each candidate.
- (void)testBenchmark_WorstCase_Original {
    const NSUInteger kDepth = 200;
    NSDictionary *tree = buildSiblingTree(kDepth);
    MAS_VIEW *viewA = tree[@"viewA"];
    MAS_VIEW *viewB = tree[@"viewB"];

    [self measureBlock:^{
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = algo_original(viewA, viewB);
        }
    }];
}

- (void)testBenchmark_WorstCase_TwoPointer {
    const NSUInteger kDepth = 200;
    NSDictionary *tree = buildSiblingTree(kDepth);
    MAS_VIEW *viewA = tree[@"viewA"];
    MAS_VIEW *viewB = tree[@"viewB"];

    [self measureBlock:^{
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = algo_twoPointer(viewA, viewB);
        }
    }];
}

- (void)testBenchmark_WorstCase_FastPath {
    const NSUInteger kDepth = 200;
    NSDictionary *tree = buildSiblingTree(kDepth);
    MAS_VIEW *viewA = tree[@"viewA"];
    MAS_VIEW *viewB = tree[@"viewB"];

    [self measureBlock:^{
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = algo_fastPath(viewA, viewB);
        }
    }];
}

#pragma mark - Benchmark: Typical Case (siblings sharing direct parent)

/// Represents the most common real-world scenario:
/// Two sibling views under the same parent (e.g., labels in a cell).
- (void)testBenchmark_TypicalCase_Siblings_Original {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *viewA  = [MAS_VIEW new];
    MAS_VIEW *viewB  = [MAS_VIEW new];
    [parent addSubview:viewA];
    [parent addSubview:viewB];

    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_original(viewA, viewB);
        }
    }];
}

- (void)testBenchmark_TypicalCase_Siblings_TwoPointer {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *viewA  = [MAS_VIEW new];
    MAS_VIEW *viewB  = [MAS_VIEW new];
    [parent addSubview:viewA];
    [parent addSubview:viewB];

    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_twoPointer(viewA, viewB);
        }
    }];
}

- (void)testBenchmark_TypicalCase_Siblings_FastPath {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *viewA  = [MAS_VIEW new];
    MAS_VIEW *viewB  = [MAS_VIEW new];
    [parent addSubview:viewA];
    [parent addSubview:viewB];

    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_fastPath(viewA, viewB);
        }
    }];
}

#pragma mark - Benchmark: Typical Case (parent-child)

- (void)testBenchmark_TypicalCase_ParentChild_Original {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *child  = [MAS_VIEW new];
    [parent addSubview:child];

    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_original(child, parent);
        }
    }];
}

- (void)testBenchmark_TypicalCase_ParentChild_TwoPointer {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *child  = [MAS_VIEW new];
    [parent addSubview:child];

    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_twoPointer(child, parent);
        }
    }];
}

- (void)testBenchmark_TypicalCase_ParentChild_FastPath {
    MAS_VIEW *parent = [MAS_VIEW new];
    MAS_VIEW *child  = [MAS_VIEW new];
    [parent addSubview:child];

    [self measureBlock:^{
        for (int i = 0; i < 10000; i++) {
            __unused MAS_VIEW *lca = algo_fastPath(child, parent);
        }
    }];
}

#pragma mark - Benchmark: Current mas_closestCommonSuperview: (actual implementation)

- (void)testBenchmark_ActualImplementation_WorstCase {
    const NSUInteger kDepth = 200;
    NSDictionary *tree = buildSiblingTree(kDepth);
    MAS_VIEW *viewA = tree[@"viewA"];
    MAS_VIEW *viewB = tree[@"viewB"];

    [self measureBlock:^{
        for (int i = 0; i < 1000; i++) {
            __unused MAS_VIEW *lca = [viewA mas_closestCommonSuperview:viewB];
        }
    }];
}

SpecEnd
