# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目简介

Masonry 是一个 Objective-C 编写的 iOS/macOS/tvOS 自动布局 DSL 库，通过链式语法封装 `NSLayoutConstraints` API，同时提供现代 Swift 支持层。

## 构建与测试

### 环境准备

```bash
pod install  # 安装 CocoaPods 依赖，生成 .xcworkspace
```

### 构建

```bash
# iOS 框架
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry iOS' \
  -configuration Debug -sdk iphonesimulator clean build

# macOS 框架
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry OSX' \
  -configuration Debug clean build

# SPM
swift build
```

### 运行测试

```bash
# 全量测试
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry iOS Tests' \
  -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0' clean test

# SPM 测试
swift test
```

## 代码架构

### 核心设计模式

库采用**块作用域 + 方法链式调用**的 DSL 模式：

```objc
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(superview);
    make.size.equalTo(CGSizeMake(100, 50));
}];
```

### 关键组件及职责

| 组件 | 职责 |
|------|------|
| `View+MASAdditions` | 对外主 API：`mas_makeConstraints:`、`mas_updateConstraints:`、`mas_remakeConstraints:` |
| `MASConstraintMaker` | 约束工厂，在块内收集约束，最终批量安装 |
| `MASConstraint`（抽象） | 链式约束接口，定义 `.top`、`.equalTo()`、`.offset()` 等链式方法 |
| `MASViewConstraint` | 单属性约束实现（top/left/width 等） |
| `MASCompositeConstraint` | 多属性组合约束（edges/size/center），展开后生成多个 `MASViewConstraint` |
| `MASViewAttribute` | `(视图, NSLayoutAttribute)` 二元组，是约束的目标/来源 |
| `MASLayoutConstraint` | `NSLayoutConstraint` 子类，携带 `mas_key` 用于调试标识 |
| `MASUtilities.h` | 跨平台宏（`MAS_VIEW`、`MASEdgeInsets`）及值装箱工具 |
| `Masonry+Swift.swift` | Swift 包装层：`MASSwiftConstraintProxy` 替代 ObjC 宏，提供类型安全 API |

### 约束安装流程

1. 调用 `mas_makeConstraints:` → 创建 `MASConstraintMaker`
2. 块内链式调用 → 构建 `MASViewConstraint`/`MASCompositeConstraint` 集合
3. 块结束 → `MASConstraintMaker` 调用 `install` 将约束转换为 `NSLayoutConstraint` 并激活

### Swift 互操作

ObjC 宏（`mas_equalTo`、`mas_offset`）在 Swift 中不可用，由 `MASSwiftConstraintProxy` 代替：

```swift
view.mas_makeConstraints { make in
    make?.top.equalTo()(superview?.mas_top)
    make?.left.offset()(16)
}
```

### 平台抽象

通过 `MASUtilities.h` 中的条件编译宏统一 iOS/macOS/tvOS：
- `MAS_VIEW` → `UIView` / `NSView`
- `MASEdgeInsets` → `UIEdgeInsets` / `NSEdgeInsets`

### 测试规范

测试位于 `Tests/Specs/`，使用 XCTest + Expecta 断言库 + BDD 风格宏（`SpecBegin`/`SpecEnd`、`it()`/`describe()`）。每个核心类对应一个 `*Spec.m` 文件。

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (90-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk vitest run          # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%)
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->