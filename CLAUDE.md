# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Masonry is a lightweight Auto Layout DSL library for iOS / macOS / tvOS, written in Objective-C with a native Swift support layer. It wraps `NSLayoutConstraint` with a chainable, block-scoped syntax that makes layout code concise and readable.

The project ships **two library products**:

| Product | Language | Description |
|---------|----------|-------------|
| `Masonry` | Objective-C | Core constraint DSL (`mas_makeConstraints:`, etc.) |
| `MasonrySwift` | Swift | Type-safe Swift DSL & operators (depends on `Masonry`) |

## Repository Layout

```
Masonry/                  # ObjC core source
├── include/              #   Public headers (MASConstraint.h, View+MASAdditions.h, …)
├── MASConstraint+Private.h  # Private header
├── *.m                   #   Implementations
MasonrySwift/             # Swift native DSL
├── ConstraintProxy.swift #   MASSwiftConstraint – chainable constraint proxy
├── MakerProxy.swift      #   MASSwiftConstraintMaker – block-scoped maker
├── MasonrySwiftCore.swift#   Core bridging utilities
├── Operators.swift       #   Operator overloads (==, >=, <=, ~)
├── Utilities.swift       #   Helper types & extensions
├── ViewDSL.swift         #   view.mas.makeConstraints { … } entry point
Tests/
├── Specs/                #   ObjC unit tests (XCTest + Expecta-style BDD macros)
├── MasonrySwiftTests/    #   Swift DSL unit tests
├── MASTestExpectation.*  #   Custom XCTest expectation helpers
├── XCTest+Spec.h         #   BDD-style SpecBegin/SpecEnd macros
Examples.swiftpm/         # Swift Playground app with ObjC & Swift examples
Package.swift             # SPM manifest (swift-tools-version: 6.0)
Masonry.podspec           # CocoaPods spec (v1.3.2)
```

## Build & Test

### Prerequisites

- **Xcode 16+** (the CI uses `macos-15` + `Xcode_16.app`)
- For CocoaPods workflow: `pod install` to generate `.xcworkspace`

### Swift Package Manager (Primary)

```bash
# Build
swift build

# Run all tests (ObjC + Swift)
swift test

# Build & test via xcodebuild (matches CI)
xcodebuild test \
  -scheme "Masonry" \
  -destination "platform=macOS" \
  -enableCodeCoverage YES

# iOS simulator
xcodebuild test \
  -scheme "Masonry" \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
  -enableCodeCoverage YES
```

### CocoaPods

```bash
pod install
xcodebuild -workspace 'Masonry.xcworkspace' -scheme 'Masonry iOS' \
  -configuration Debug -sdk iphonesimulator clean build

# Lint
pod lib lint --allow-warnings
```

## Architecture

### Core Design Pattern

The library uses a **block-scoped constraint maker + method chaining** DSL pattern:

```objc
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(superview);
    make.size.mas_equalTo(CGSizeMake(100, 50));
}];
```

### Key Components

| Component | File(s) | Responsibility |
|-----------|---------|----------------|
| `View+MASAdditions` | `View+MASAdditions.{h,m}` | Public entry API: `mas_makeConstraints:`, `mas_updateConstraints:`, `mas_remakeConstraints:` |
| `MASConstraintMaker` | `MASConstraintMaker.{h,m}` | Constraint factory; collects constraints inside the block, then batch-installs them |
| `MASConstraint` (abstract) | `MASConstraint.{h,m}` | Chainable constraint interface (`.top`, `.equalTo()`, `.offset()`, `.priority()`); `mas_equalTo()` macros auto-embed call-site file/line into `mas_key` |
| `MASConstraintConvertible` | `MASConstraintConvertible.h` | Marker protocol for valid constraint targets (`MASViewAttribute`, `UIView/NSView`, `NSValue/NSNumber`, `NSArray`) |
| `MASViewConstraint` | `MASViewConstraint.{h,m}` | Single-attribute constraint (top / left / width, etc.) |
| `MASCompositeConstraint` | `MASCompositeConstraint.{h,m}` | Multi-attribute composite (edges / size / center); expands into multiple `MASViewConstraint`s |
| `MASViewAttribute` | `MASViewAttribute.{h,m}` | `(view, NSLayoutAttribute)` tuple — the source/target of a constraint |
| `MASLayoutConstraint` | `MASLayoutConstraint.{h,m}` | `NSLayoutConstraint` subclass carrying `mas_key` for debug identification |
| `MASUtilities.h` | `MASUtilities.h` | Cross-platform macros (`MAS_VIEW`, `MASEdgeInsets`) and value-boxing utilities |
| `NSArray+MASAdditions` | `NSArray+MASAdditions.{h,m}` | Batch constraint creation on arrays of views (distribution) |
| `NSLayoutConstraint+MASDebugAdditions` | `NSLayoutConstraint+MASDebugAdditions.{h,m}` | Enhanced debug descriptions for constraints |
| `ViewController+MASAdditions` | `ViewController+MASAdditions.{h,m}` | `topLayoutGuide` / `bottomLayoutGuide` support |

### Constraint Installation Flow

1. Call `mas_makeConstraints:` → creates a `MASConstraintMaker` bound to the view
2. Inside the block, chained calls build `MASViewConstraint` / `MASCompositeConstraint` objects
3. Block returns → `MASConstraintMaker.install` converts each constraint into an `NSLayoutConstraint` and activates it on the nearest common ancestor

For `mas_updateConstraints:`, existing constraints with matching attributes are updated in-place.
For `mas_remakeConstraints:`, all existing Masonry constraints are uninstalled first.

### Swift Module (`MasonrySwift`)

ObjC macros (`mas_equalTo`, `mas_offset`) are unavailable in Swift. The `MasonrySwift` module provides a fully native alternative:

| Swift File | Role |
|------------|------|
| `ViewDSL.swift` | `view.mas.makeConstraints { … }` — main entry point via `MASViewDSL` |
| `MakerProxy.swift` | `MASSwiftConstraintMaker` — Swift-side maker proxy |
| `ConstraintProxy.swift` | `MASSwiftConstraint` — chainable constraint with `.equalTo()`, `.offset()`, `.inset()` |
| `Operators.swift` | Operator overloads: `==`, `>=`, `<=` for constraints; `~` for priority; `+`/`-` for offset |
| `Utilities.swift` | `MASSwiftAttribute`, priority helpers, edge inset utilities |
| `MasonrySwiftCore.swift` | Core bridging between Swift proxies and ObjC `MASConstraintMaker` |

Swift usage:
```swift
import MasonrySwift

view.mas.makeConstraints { make in
    make.top.equalTo(superview.mas_top).offset(20)
    make.left.right.equalTo(superview).inset(16)
    make.height.equalTo(44)
}

// Operator syntax
view.mas.makeConstraints { make in
    make.top == superview.mas_top + 20
    make.width <= 200
    make.height == 44 ~ .defaultHigh
}
```

### Platform Abstraction

Conditional compilation macros in `MASUtilities.h` unify iOS / macOS / tvOS:
- `MAS_VIEW` → `UIView` / `NSView`
- `MASEdgeInsets` → `UIEdgeInsets` / `NSEdgeInsets`
- `MAS_VIEW_CONTROLLER` → `UIViewController` / `NSViewController`

### Testing Conventions

- **ObjC tests** are in `Tests/Specs/`, using XCTest with BDD-style macros (`SpecBegin` / `SpecEnd`, `describe()`, `it()`) and custom `MASTestExpectation` matchers. Each core class has a corresponding `*Spec.m` file.
- **Swift tests** are in `Tests/MasonrySwiftTests/`, using standard XCTest assertions.
- CI runs tests on both **macOS** and **iOS Simulator** platforms.

### Coding Conventions

- ObjC files use the `MAS` prefix for all public classes and categories.
- Public headers live in `Masonry/include/` and `MasonrySwift/` respectively.
- The SPM manifest uses **Swift 6.0 tools version** with **Swift language mode v5** (`swiftLanguageModes: [.v5]`).
- Minimum deployment targets: iOS 16, macOS 13, tvOS 16 (SPM); iOS 9, macOS 10.13, tvOS 9 (CocoaPods).

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